package com.example.bike_hud

import android.bluetooth.BluetoothAdapter
import android.media.AudioManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.provider.Settings
import android.service.notification.NotificationListenerService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MyNotificationListenerService : NotificationListenerService() {
    // Empty class required by Android manifest to authorize active session access.
}

class MainActivity : FlutterActivity() {
    private val CHANNEL = "bike_hud/music"
    private var mediaSessionManager: MediaSessionManager? = null
    private var activeController: MediaController? = null
    private var activeCallback: MediaController.Callback? = null

    private var currentTitle = ""
    private var currentArtist = ""
    private var currentIsPlaying = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        mediaSessionManager = getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getMediaInfo" -> {
                    val map = HashMap<String, Any>()
                    map["title"] = currentTitle
                    map["artist"] = currentArtist
                    map["isPlaying"] = currentIsPlaying
                    map["success"] = true
                    result.success(map)
                }
                "play" -> {
                    activeController?.transportControls?.play()
                    result.success(true)
                }
                "pause" -> {
                    activeController?.transportControls?.pause()
                    result.success(true)
                }
                "next" -> {
                    activeController?.transportControls?.skipToNext()
                    result.success(true)
                }
                "previous" -> {
                    activeController?.transportControls?.skipToPrevious()
                    result.success(true)
                }
                "hasNotificationAccess" -> {
                    val enabledListeners = Settings.Secure.getString(
                        contentResolver,
                        "enabled_notification_listeners"
                    )
                    val hasAccess = enabledListeners != null && enabledListeners.contains(packageName)
                    result.success(hasAccess)
                }
                "requestNotificationAccess" -> {
                    try {
                        val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open settings", e.message)
                    }
                }
                "openBluetoothSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open bluetooth settings", e.message)
                    }
                }
                "isBluetoothEnabled" -> {
                    try {
                        val adapter = BluetoothAdapter.getDefaultAdapter()
                        result.success(adapter?.isEnabled == true)
                    } catch (e: SecurityException) {
                        result.success(false)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "isBluetoothConnected" -> {
                    try {
                        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        result.success(audioManager.isBluetoothA2dpOn)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        setupMediaSessionListener()
    }

    private fun setupMediaSessionListener() {
        try {
            val componentName = ComponentName(this, MyNotificationListenerService::class.java)
            mediaSessionManager?.addOnActiveSessionsChangedListener(
                { controllers ->
                    updateActiveController(controllers)
                },
                componentName
            )
            val controllers = mediaSessionManager?.getActiveSessions(componentName)
            updateActiveController(controllers)
        } catch (e: SecurityException) {
            // Permission not granted yet
        }
    }

    private fun updateActiveController(controllers: List<MediaController>?) {
        activeController?.let { controller ->
            activeCallback?.let { callback ->
                controller.unregisterCallback(callback)
            }
        }

        activeController = controllers?.firstOrNull()
        if (activeController != null) {
            val callback = object : MediaController.Callback() {
                override fun onMetadataChanged(metadata: MediaMetadata?) {
                    super.onMetadataChanged(metadata)
                    metadata?.let {
                        currentTitle = it.getString(MediaMetadata.METADATA_KEY_TITLE) ?: ""
                        currentArtist = it.getString(MediaMetadata.METADATA_KEY_ARTIST) ?: ""
                    }
                }

                override fun onPlaybackStateChanged(state: PlaybackState?) {
                    super.onPlaybackStateChanged(state)
                    state?.let {
                        currentIsPlaying = it.state == PlaybackState.STATE_PLAYING
                    }
                }
            }

            activeCallback = callback
            activeController?.registerCallback(callback)

            activeController?.metadata?.let {
                currentTitle = it.getString(MediaMetadata.METADATA_KEY_TITLE) ?: ""
                currentArtist = it.getString(MediaMetadata.METADATA_KEY_ARTIST) ?: ""
            }
            activeController?.playbackState?.let {
                currentIsPlaying = it.state == PlaybackState.STATE_PLAYING
            }
        } else {
            activeCallback = null
        }
    }

    override fun onResume() {
        super.onResume()
        setupMediaSessionListener()
    }
}
