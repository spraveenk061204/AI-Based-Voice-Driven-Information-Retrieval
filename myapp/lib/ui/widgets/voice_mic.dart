import 'dart:io';

import 'package:flutter/material.dart';
import '../../services/audio_player_service.dart';
import '../../services/audio_recorder_service.dart';
import '../../services/backend_service.dart';
import '../../models/voice_message.dart';
import '../../state/chat_controller.dart';

class VoiceMic extends StatefulWidget {
  final ChatController controller;

  const VoiceMic({super.key, required this.controller});

  @override
  State<VoiceMic> createState() => _VoiceMicState();
}

class _VoiceMicState extends State<VoiceMic> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
  AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..repeat();
  final AudioRecorderService recorder = AudioRecorderService();
  final AudioPlayerService player = AudioPlayerService();

  final BackendService backend = BackendService();
  bool isRecording = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 260, // ✅ HARD MIC ZONE
      child: Column(
        children: [
          Text(
            isRecording ? 'Speak now!' : 'Tap to speak!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          /// ✅ MIC GLOW CLIPPED
          ClipRect(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      return Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isRecording
                                  ? Colors.green
                                  : Colors.redAccent),
                              blurRadius: 28 * _controller.value,
                              spreadRadius: 12 * _controller.value,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              GestureDetector(

                onTap: () async {
                  if (!isRecording) {
                    setState(() => isRecording = true);
                    await recorder.start();
                  } else {
                    setState(() => isRecording = false);

                    await Future.delayed(const Duration(milliseconds: 500)); // ✅ IMPORTANT
                    final path = await recorder.stop();

                    if (path == null) return;

// ✅ validate file
                    final file = File(path);
                    final size = await file.length();
                    print("File size: $size");
                    print("Recorded file path: $path");
// ✅ ignore bad recordings
                    if (size < 5000) {
                      print("Recording too short / silent");
                      return;
                    }



                   // if (path == null) return;

                    /// 1️⃣ Add user voice bubble
                    widget.controller.addMessage(
                      VoiceMessage(
                        audioPath: path,
                        duration: const Duration(seconds: 5),
                        sender: Sender.user,
                      ),
                    );

                    /// 2️⃣ Send to backend

                    final responsePath = await backend.sendAudio(File(path));

                    /// ✅ Add assistant message FIRST
                    widget.controller.addMessage(
                      VoiceMessage(
                        audioPath: responsePath,
                        duration: const Duration(seconds: 5),
                        sender: Sender.assistant,
                      ),
                    );

                    /// ✅ THEN play audio automatically
                    await player.play(responsePath);

                  }
                },
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: isRecording
                          ? [Colors.greenAccent, Colors.green]
                          : [Colors.redAccent, Colors.deepOrangeAccent],
                    ),
                  ),
                  child: Icon(
                    isRecording ? Icons.mic : Icons.mic_none,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
        ],
      ),
    );


  }
}