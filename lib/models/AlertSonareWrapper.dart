import 'Alert.dart';
import 'dart:ui';

class AlertSonareWrapper {
  final Alert alert;
  bool visible;
  double angle;
  Offset circlePosition;
  double size;
  int level; // 1: urgent, 2: medium, 3: far

  AlertSonareWrapper({
    required this.alert,
    required this.level,
    required this.size,
    this.visible = false,
    this.angle = 0.0,
    this.circlePosition = Offset.zero,
  });
}
