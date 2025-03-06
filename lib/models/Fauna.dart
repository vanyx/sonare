import 'package:latlong2/latlong.dart';

class Fauna {
  final LatLng position;
  final String type;

  static const List<String> allowedTypes = ['fish', 'shell'];

  Fauna({required this.position, required this.type}) {
    if (!allowedTypes.contains(type)) {
      throw ArgumentError('Incorrect type.');
    }
  }

  factory Fauna.fromJson(Map<String, dynamic> json, String type) {
    return Fauna(
      position: LatLng(json['latitude'], json['longitude']),
      type: type,
    );
  }
}
