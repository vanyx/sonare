import 'Alert.dart';
import 'dart:ui';

class AlertSonareWrapper {
  final Alert alert;
  bool visible;
  double angle;
  Offset circlePosition;
  double size;
  /**
   * Police       1: urgent, 2: medium, 3: far
   * ControlZone  1: dedans, 2: medium, 3: far 
   */
  int level;

  AlertSonareWrapper({
    required this.alert,
    required this.level,
    required this.size,
    this.visible = false,
    this.angle = 0.0,
    this.circlePosition = Offset.zero,
  });
}
