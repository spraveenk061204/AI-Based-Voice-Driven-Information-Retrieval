import 'package:flutter/material.dart';
import 'package:myapp/ui/widgets/glass_container.dart';
import 'package:myapp/ui/widgets/voice_bubble.dart';
import 'package:myapp/ui/widgets/voice_mic.dart';
import 'package:myapp/state/chat_controller.dart';
import 'package:myapp/services/audio_player_service.dart';

import '../models/voice_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatController chatController = ChatController();
  final AudioPlayerService audioPlayer = AudioPlayerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                'User Manual Guide',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              /// ✅ Glass chat container
              Expanded(
                child: GlassContainer(
                  child: Column(
                    children: [
                      /// 🎤 Voice Mic
                      VoiceMic(controller: chatController),

                      const SizedBox(height: 24),

                      /// 💬 Chat list
                      Expanded(
                        child: AnimatedBuilder(
                          animation: chatController,
                          builder: (context, _) {
                            return ListView.builder(
                              itemCount: chatController.messages.length,
                              itemBuilder: (context, index) {
                                final message =
                                chatController.messages[index];

                                return Align(
                                  alignment: message.sender == Sender.user
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