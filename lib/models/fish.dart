import 'package:latlong2/latlong.dart';
import 'dart:ui';

class Fish {
  LatLng position;
  bool visible;
  double angle;
  Offset circlePosition;
  String type;
  double size;

  static const List<String> allowedTypes = ['wish', 'sonare'];

  static const double minSize = 10.0;
  static const double maxSize = 30.0;
  static const double defaultSize = 15.0;

  Fish(
      {required this.position,
      this.visible = false,
      this.angle = 0.0,
      this.circlePosition = Offset.zero,
      required this.type,
      this.size = defaultSize}) {
    if (!allowedTypes.contains(type)) {
      throw ArgumentError('Incorrect type.');
    }
  }

  // Getter
  static double get minSizeValue => minSize;
  static double get maxSizeValue => maxSize;
}
