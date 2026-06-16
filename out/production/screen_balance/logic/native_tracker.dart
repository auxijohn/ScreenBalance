import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class NativeTracker {
  static const EventChannel _eventChannel = EventChannel('com.screenbalance.tracker/events');
  static StreamSubscription? _subscription;
  
  // Expose a stream so our Intervention Engine can listen
  static final StreamController<String> appOpenStream = StreamController<String>.broadcast();

  static void initialize() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      debugPrint('NativeTracker: Background platform tracking stream is only supported on Android. Web/simulated console remains active.');
      return;
    }
    
    try {
      _subscription = _eventChannel.receiveBroadcastStream().listen((dynamic event) {
        if (event is String) {
          appOpenStream.add(event);
        }
      }, onError: (dynamic error) {
        debugPrint('NativeTracker Error: $error');
      });
    } catch (e) {
      debugPrint('NativeTracker Exception during initialization: $e');
    }
  }

  static void dispose() {
    _subscription?.cancel();
    appOpenStream.close();
  }
}
