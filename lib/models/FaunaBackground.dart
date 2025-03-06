import 'package:latlong2/latlong.dart';
import 'Fauna.dart';

class FaunaBackground extends Fauna {
  int level;

  FaunaBackground({
    required LatLng position,
    required String type,
    required this.level,
  }) : super(position: position, type: type);

  factory FaunaBackground.fromJson(Map<String, dynamic> json, String type) {
    return FaunaBackground(
      position: LatLng(json['latitude'], json['longitude']),
      type: type,
      level: json['level'] ?? 3, // Valeur par defaut
    );
  }
}
