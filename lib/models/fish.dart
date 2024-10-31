import 'package:latlong2/latlong.dart';
import 'dart:ui';

class Fish {
  LatLng position;
  bool visible;
  double angle;
  Offset circlePosition;
  String type;

  Fish(
      {required this.position,
      this.visible = false,
      this.angle = 0.0,
      this.circlePosition = Offset.zero,
      required this.type});
}
