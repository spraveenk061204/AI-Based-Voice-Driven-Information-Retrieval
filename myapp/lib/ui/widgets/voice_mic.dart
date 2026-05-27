import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../state/chat_controller.dart';

class VoiceMic extends StatefulWidget {
  final ChatController controller;

  const VoiceMic({super.key, required this.controller});


  @override
  State<VoiceMic> createState() => _VoiceMicState();
}

class _VoiceMicState extends State<VoiceMic>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller =
  AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool isRecording = false;
  String recognizedText = "";
  @override
  void initState() {
    super.initState();

    _speech.initialize(
      onStatus: (status) => print("STATUS: $status"),
      onError: (error) => print("ERROR: ${error.errorMsg}"),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Column(
        children: [

          Text(
            isRecording ? 'Speak now!' : 'Tap to speak!',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),

          const SizedBox(height: 12),

          ClipRect(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [

                  /// ✅ Glow animation
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
                              color: isRecording
                                  ? Colors.green
                                  : Colors.redAccent,
                              blurRadius: 28 * _controller.value,
                              spreadRadius: 12 * _controller.value,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  /// ✅ MIC BUTTON
                  GestureDetector(
                    onTap: () async {

                      /// ✅ START LISTENING
                      if (!isRecording) {

                        // ✅ Reset speech engine
                        if (_speech.isListening) {
                          await _speech.stop();
                        }

                        await Future.delayed(const Duration(milliseconds: 200));

                        setState(() {
                          isRecording = true;
                          recognizedText = "";
                        });

                        await _speech.listen(
                          listenMode: stt.ListenMode.dictation,
                          partialResults: true,
                          localeId: "en-US",   // ✅ IMPORTANT FIX

                            onResult: (result) {
                              print("RESULT: ${result.recognizedWords}");

                              if (result.recognizedWords.isNotEmpty) {
                                setState(() {   // ✅ ✅ THIS FIXES LIVE UPDATE
                                  recognizedText = result.recognizedWords;

                                  widget.controller.queryController.text = recognizedText;
                                });
                              }
                            },
                        );
                      }

                      /// ✅ STOP LISTENING
                      else {
                        setState(() => isRecording = false);

                        await _speech.stop();

                        print("✅ FINAL TEXT: $recognizedText");

                        /// ✅ ✅ AUTO SEND AFTER STOP
                        if (recognizedText.isNotEmpty) {

                          widget.controller.queryController.text = recognizedText;

                          /// ✅ CALL SEND FUNCTION
                          widget.controller.onAutoSend?.call(recognizedText);
                        }
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
                        isRecording
                            ? Icons.mic
                            : Icons.mic_none,
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