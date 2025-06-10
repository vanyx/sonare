import 'package:latlong2/latlong.dart';
import 'dart:ui';
import 'Fauna.dart';

class FaunaSonare extends Fauna {
  bool visible;
  double angle;
  Offset circlePosition;
  double size;
  int level; // 1: urgent, 2: medium, 3: far

  static const double minSize = 10.0;
  static const double maxSize = 30.0;
  static const double defaultSize = 15.0;

  // Utilisation du constructeur de Fauna avec super()
  FaunaSonare({
    required LatLng position,
    required String type,
    required this.level,
    this.visible = false,
    this.angle = 0.0,
    this.circlePosition = Offset.zero,
    this.size = defaultSize,
  }) : super(position: position, type: type) {
    if (level > 3) {
      throw ArgumentError('Level must be less than or equal to 3.');
    }
  }

  factory FaunaSonare.fromJson(Map<String, dynamic> json, String type) {
    return FaunaSonare(
      position: LatLng(json['latitude'], json['longitude']),
      type: type,
      level: json['level'] ?? 3, // Valeur par defaut
    );
  }

  // Getters statiques pour minSize et maxSize
  static double get minSizeValue => minSize;
  static double get maxSizeValue => maxSize;
}
