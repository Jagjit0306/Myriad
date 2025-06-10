import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class FallDetectionService {
  static final FallDetectionService _instance = FallDetectionService._internal();

  factory FallDetectionService() => _instance;

  FallDetectionService._internal();

  final double freeFallThreshold = 3.0;
  final double impactThreshold = 20.0;
  final int confirmationDelay = 1500;

  bool freeFallDetected = false;
  bool impactDetected = false;
  bool orientationChanged = false;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  void startMonitoring(Function onFallDetected) {
    _accelSub = accelerometerEvents.listen((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude < freeFallThreshold) {
        freeFallDetected = true;
      } else if (magnitude > impactThreshold && freeFallDetected) {
        impactDetected = true;
        Future.delayed(Duration(milliseconds: confirmationDelay), () {
          if (impactDetected && freeFallDetected && orientationChanged) {
            onFallDetected();
            _resetFlags();
          }
        });
      }
    });

    _gyroSub = gyroscopeEvents.listen((event) {
      final angle = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (angle > 1.0) {
        orientationChanged = true;
      }
    });
  }

  void _resetFlags() {
    freeFallDetected = false;
    impactDetected = false;
    orientationChanged = false;
  }

  void stopMonitoring() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
  }
}