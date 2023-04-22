import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class CommunicationButtons extends StatelessWidget {
  final VoidCallback toggleChatVisibility;
  final recorder = FlutterSoundRecorder();

  CommunicationButtons({
    Key? key,
    required this.toggleChatVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 85, top: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: () {
                // Implementa la función de la cámara
              },
            ),
            const SizedBox(width: 50.0),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.greenAccent,
                    Colors.purpleAccent,
                  ],
                ),
              ),
              child: IconButton(
                iconSize: 60,
                icon: const Icon(Icons.mic_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 50.0),
            IconButton(
              icon: const Icon(Icons.keyboard, color: Colors.white),
              iconSize: 30,
              onPressed: toggleChatVisibility,
            ),
          ],
        ),
      ),
    );
  }
}
