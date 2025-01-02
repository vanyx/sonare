import 'package:flutter/material.dart';
import './customMarker.dart';
import 'package:latlong2/latlong.dart';

class ExplorerExpandableMarker extends StatelessWidget {
  final double zoom;
  final String type;
  final Color color;
  final LatLng position;
  final double rotationAngle;
  final double markerSize;
  final double miniMarkerSize;
  final double zoomThreshold;

  const ExplorerExpandableMarker({
    Key? key,
    required this.zoom,
    required this.type,
    required this.color,
    required this.position,
    required this.rotationAngle,
    required this.markerSize,
    required this.miniMarkerSize,
    required this.zoomThreshold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return zoom > zoomThreshold
        ? Transform.rotate(
            angle: -rotationAngle * (pi / 180),
            child: CustomMarker(
              size: markerSize,
              type: type,
            ),
          )
        : Container(
            width: miniMarkerSize,
            height: miniMarkerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 3.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
          );
  }
}
