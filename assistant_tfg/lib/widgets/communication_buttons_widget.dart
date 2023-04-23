import 'dart:async';
import 'package:assistant_tfg/themes/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:record/record.dart';
import 'package:assistant_tfg/services/api_service.dart';
import 'package:assistant_tfg/providers/chats_provider.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class CommunicationButtons extends StatefulWidget {
  final void Function(String path) onStop;
  final void Function(bool value) setIsTyping;
  final VoidCallback onShortPress;
  final VoidCallback toggleChatVisibility;
  final ChatProvider chatProvider;

  const CommunicationButtons({
    Key? key,
    required this.toggleChatVisibility,
    required this.onStop,
    required this.chatProvider,
    required this.setIsTyping,
    required this.onShortPress,
  }) : super(key: key);

  @override
  State<CommunicationButtons> createState() => _CommunicationButtonsState();
}

class _CommunicationButtonsState extends State<CommunicationButtons> {
  bool isListening = false;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  
  @override
  void initState() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    super.initState();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<String> _stop() async {
    final path = await _audioRecorder.stop();

    if (path != null) {
      widget.onStop(path);
    }

    return path ?? '';
  }

  void playSoundAndVibrate() async {
    final player = AudioPlayer();
    await player.play(AssetSource('recording_sound_effect.mp3'));

    bool hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(duration: 150);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
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
            const SizedBox(width: 40.0),
            AvatarGlow(
              endRadius: 75.0,
              animate: isListening,
              duration: const Duration(milliseconds: 1500),
              glowColor: Primary,
              repeatPauseDuration: const Duration(milliseconds: 0),
              repeat: true,
              showTwoGlows: true,
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isListening ? Secondary : Primary,
                      isListening ? AccentFour : Secondary,
                    ],
                  ),
                ),
                child: GestureDetector(
                  onTap: widget.onShortPress,
                  onDoubleTap: widget.onShortPress,
                  onLongPressStart: (details) {
                    if (_recordState != RecordState.stop) {
                      return;
                    }
                    playSoundAndVibrate();
                    _start();
                    setState(() {
                      isListening = true;
                    });
                  },
                  onLongPressEnd: (details) {
                    if (_recordState != RecordState.stop) {
                      _stop().then((path) {
                        if (path.isNotEmpty) {
                          _sendAudioMessage(path);
                        }
                      });
                    }
                    setState(() {
                      isListening = false;
                    });
                  },
                  child: Icon(
                    isListening ? Icons.stop_circle_outlined : Icons.mic,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40.0),
            IconButton(
              icon: const Icon(Icons.keyboard, color: Colors.white),
              iconSize: 30,
              onPressed: widget.toggleChatVisibility,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendAudioMessage(String audioPath) async {
    try {
      // Espera a que la transcripción esté completa antes de continuar
      widget.setIsTyping(true);

      String transcribedText =
          await ApiService.sendAudioMessage(audioPath: audioPath);

      if (transcribedText.isNotEmpty) {
        // Agrega el texto transcrito como un mensaje de usuario y envíalo a ChatGPT
        widget.chatProvider.addUserMessage(msg: transcribedText);
        await widget.chatProvider
            .sendMessageAndGetAnswers(msg: transcribedText);
      }

      widget.setIsTyping(false);
    } catch (error) {
      // Muestra un SnackBar con el mensaje de error y un fondo rojo
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Error en el envío',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void dispose() {
    _recordSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }
}
