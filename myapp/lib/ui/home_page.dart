import 'package:flutter/material.dart';
import 'package:myapp/ui/widgets/glass_container.dart';
import 'package:myapp/ui/widgets/voice_bubble.dart';
import 'package:myapp/ui/widgets/voice_mic.dart';
import 'package:myapp/state/chat_controller.dart';
import 'package:myapp/services/audio_player_service.dart';
import 'package:myapp/services/backend_service.dart';

import '../models/voice_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatController chatController = ChatController();
  final AudioPlayerService audioPlayer = AudioPlayerService();
  final BackendService backend = BackendService();

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
                              onTap: () async {

                                final text = chatController
                                    .queryController.text
                                    .trim();

                                if (text.isEmpty) return;

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

                                /// ✅ BACKEND CALL
                                final responsePath =
                                await backend.sendText(text);

                                /// ✅ REMOVE LOADING
                                chatController.removeLastMessage();

                                /// ✅ ASSISTANT MESSAGE
                                chatController.addMessage(
                                  VoiceMessage(
                                    audioPath: responsePath,
                                    sender: Sender.assistant,
                                    duration:
                                    const Duration(seconds: 5),
                                  ),
                                );

                                /// ✅ PLAY AUDIO
                                await audioPlayer.play(responsePath);
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
                                    message: message,
                                    player: audioPlayer,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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