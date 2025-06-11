import 'Alert.dart';
import 'package:latlong2/latlong.dart';

class ControlZone extends Alert {
  final double radius;
  final bool centroid;

  ControlZone({
    required LatLng position,
    required this.radius,
    this.centroid = false,
  }) : super(position: position);
}
