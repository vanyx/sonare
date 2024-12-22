import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:audioplayers/audioplayers.dart';

class Common {
  /**************** FISHS ****************/
  int maxRetry = 3;

  bool errorWishRequest = false;
  String wishUrl = 'https://www.waze.com/live-map/api/georss';

  Future<List<LatLng>> fetchWish(
      double north, double south, double west, double east, int retries) async {
    String wishUrl = 'https://www.waze.com/live-map/api/georss';

    Map<String, String> queryParams = {
      "top": north.toString(),
      "bottom": south.toString(),
      "left": west.toString(),
      "right": east.toString(),
      "env": "row",
      "types": "alerts"
    };

    try {
      Uri uri = Uri.parse(wishUrl);
      final finalUri = uri.replace(queryParameters: queryParams);

      final response = await http.get(finalUri);

      if (response.statusCode == 200) {
        if (errorWishRequest) {
          errorWishRequest = false;
        }

        var data = json.decode(response.body);
        List<LatLng> newFish = [];

        if (data['alerts'] != null) {
          for (var alert in data['alerts']) {
            var location = alert['location'];
            if (location != null && alert['type'] == 'POLICE') {
              LatLng fishPosition = LatLng(location['y'], location['x']);
              newFish.add(fishPosition);
            }
          }
        }
        return newFish;
      } else {
        if (retries > 0) {
          await Future.delayed(Duration(milliseconds: 200));
          return await fetchWish(north, south, west, east, retries - 1);
        } else {
          errorWishRequest = true;
          return [];
        }
      }
    } catch (e) {
      if (retries > 0) {
        await Future.delayed(Duration(milliseconds: 200));
        return await fetchWish(north, south, west, east, retries - 1);
      } else {
        errorWishRequest = true;
        return [];
      }
    }
  }

  // Future<void> _fetchSonare(
  //     double north, double south, double west, double east, int retries) async {
  //   String url =
  //       'http://192.168.1.40:8000/sonare/all/${north}/${south}/${west}/${east}';

  //   try {
  //     Uri uri = Uri.parse(url);

  //     final response = await http.get(uri);
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body) as List;
  //       List<LatLng> newFish = [];

  //       for (var item in data) {
  //         double latitude = item['latitude'];
  //         double longitude = item['longitude'];
  //         LatLng fishPosition = LatLng(latitude, longitude);
  //         newFish.add(fishPosition);
  //       }

  //       if (mounted) {
  //         setState(() {
  //           _shell = newFish;
  //         });
  //       }
  //     } else {
  //       if (retries > 0) {
  //         await Future.delayed(Duration(milliseconds: 200));
  //         _fetchSonare(north, south, west, east, retries - 1);
  //       }
  //     }
  //   } catch (e) {
  //     if (retries > 0) {
  //       await Future.delayed(Duration(milliseconds: 200));
  //       _fetchSonare(north, south, west, east, retries - 1);
  //     }
  //   }
  // }

  /**************** SOUNDS ****************/

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> play5kmWarning() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/5km.mp3'));
    } catch (e) {}
  }

  Future<void> play500mWarning() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/500m.mp3'));
    } catch (e) {}
  }

  Future<void> play100mWarning() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/100m.mp3'));
    } catch (e) {}
  }
}
