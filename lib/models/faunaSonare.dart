import 'package:latlong2/latlong.dart';
import 'dart:ui';

// Pour le mode Sonare

class FaunaSonare {
  LatLng position;
  bool visible;
  double angle;
  Offset circlePosition;
  String type;
  double size;
  int level; // 1: urgent, 2: medium, 3: far

  static const List<String> allowedTypes = ['fish', 'shell'];

  static const double minSize = 10.0;
  static const double maxSize = 30.0;
  static const double defaultSize = 15.0;

  FaunaSonare(
      {required this.position,
      this.visible = false,
      this.angle = 0.0,
      this.circlePosition = Offset.zero,
      required this.type,
      required this.level,
      this.size = defaultSize}) {
    if (!allowedTypes.contains(type)) {
      throw ArgumentError('Incorrect type.');
    }
    if (level > 3) {
      throw ArgumentError('Level must be less than or equal to 3.');
    }
  }

  // Getter
  static double get minSizeValue => minSize;
  static double get maxSizeValue => maxSize;
}
