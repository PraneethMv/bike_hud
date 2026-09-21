import 'package:flutter/services.dart';

enum HandlebarAction {
  playPause,
  previousTrack,
  nextTrack,
  volumeUp,
  volumeDown,
  acceptCall,
  rejectCall,
  simulateIncomingCall,
  openHome,
  openNavigation,
  openRides,
  openDocuments,
  openSettings,
}

class HandlebarButtonService {
  HandlebarAction? actionFromKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return null;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.space) {
      return HandlebarAction.playPause;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      return HandlebarAction.previousTrack;
    }

    if (key == LogicalKeyboardKey.arrowRight) {
      return HandlebarAction.nextTrack;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      return HandlebarAction.volumeUp;
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      return HandlebarAction.volumeDown;
    }

    if (key == LogicalKeyboardKey.enter) {
      return HandlebarAction.acceptCall;
    }

    if (key == LogicalKeyboardKey.escape) {
      return HandlebarAction.rejectCall;
    }

    if (key == LogicalKeyboardKey.keyC) {
      return HandlebarAction.simulateIncomingCall;
    }

    if (key == LogicalKeyboardKey.keyH) {
      return HandlebarAction.openHome;
    }

    if (key == LogicalKeyboardKey.keyN) {
      return HandlebarAction.openNavigation;
    }

    if (key == LogicalKeyboardKey.keyR || key == LogicalKeyboardKey.keyD) {
      return HandlebarAction.openRides;
    }

    if (key == LogicalKeyboardKey.keyS) {
      return HandlebarAction.openSettings;
    }

    return null;
  }
}
