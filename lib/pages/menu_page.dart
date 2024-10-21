import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MenuPage extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playClickSound() async {
    await _audioPlayer.play(AssetSource('cartoon_sounds.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 40.0),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  size: 24.0,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Clique ici pour rire XDDDDDD'),
            onTap: () {
              _playClickSound();
            },
          ),
        ],
      ),
    );
  }
}
