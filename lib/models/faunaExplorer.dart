import 'package:latlong2/latlong.dart';

class FaunaExplorer {
  final LatLng position;
  final String type;

  static const List<String> allowedTypes = ['fish', 'shell'];

  FaunaExplorer({required this.position, required this.type}) {
    if (!allowedTypes.contains(type)) {
      throw ArgumentError('Incorrect type.');
    }
  }
}
