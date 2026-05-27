import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:myapp/ui/widgets/glass_container.dart';
import 'package:myapp/ui/widgets/voice_bubble.dart';
import 'package:myapp/ui/widgets/voice_mic.dart';
import 'package:myapp/state/chat_controller.dart';
import 'package:myapp/services/backend_service.dart';

import '../models/voice_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatController chatController = ChatController();
  final FlutterTts tts = FlutterTts();
  final BackendService backend = BackendService();
  Future<void> handleSend(String text) async {

    if (text.trim().isEmpty) return;

    /// ✅ USER MESSAGE
    chatController.addMessage(
      VoiceMessage(
        text: text,
        sender: Sender.user,
        duration: Duration.zero,
      ),
    );

    chatController.queryController.clear();

    /// ✅ LOADING
    chatController.addMessage(
      VoiceMessage(
        isLoading: true,
        sender: Sender.assistant,
        duration: Duration.zero,
      ),
    );

    /// ✅ BACKEND
    final answerText = await backend.sendText(text);

    chatController.removeLastMessage();

    /// ✅ SHOW RESULT
    chatController.addMessage(
      VoiceMessage(
        text: answerText,
        sender: Sender.assistant,
        duration: Duration.zero,
      ),
    );

    /// ✅ SPEAK
    await tts.stop();
    await tts.speak(answerText);
  }
  @override
  void initState() {
    super.initState();

    tts.setLanguage("en-US");
    tts.setPitch(1.1);
    tts.setSpeechRate(0.55);
    chatController.onAutoSend = handleSend;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 16),

              const Text(
                'AI-Based Voice Information Retrieval',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GlassContainer(
                  child: Column(
                    children: [

                      /// ✅ VOICE MIC
                      VoiceMic(controller: chatController),

                      const SizedBox(height: 12),
                      /// ✅ CHAT LIST
                      Expanded(
                        child: AnimatedBuilder(
                          animation: chatController,
                          builder: (context, _) {
                            return ListView.builder(
                              itemCount:
                              chatController.messages.length,
                              itemBuilder: (context, index) {
                                final message =
                                chatController.messages[index];

                                return Align(
                                  alignment: message.sender ==
                                      Sender.user
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: VoiceBubble(
                                    message: message,tts:tts
                                    //player: audioPlayer,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),


                    ],
                  ),
                ),


              ),
              const SizedBox(height: 16),
              /// ✅ QUERY BOX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [

                    Expanded(
                      child: TextField(
                        controller: chatController.queryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Speak or type...",
                          hintStyle:
                          const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// ✅ SEND BUTTON
                    GestureDetector(
                      onTap: () {
                        handleSend(chatController.queryController.text);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.send,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),



            ],
          ),
        ),
      ),
    );
  }
}































