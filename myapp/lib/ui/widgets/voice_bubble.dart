import 'package:flutter/material.dart';
import '../../models/voice_message.dart';
import '../../services/audio_player_service.dart';

class VoiceBubble extends StatelessWidget {
  final VoiceMessage message;
  final AudioPlayerService player;

  const VoiceBubble({
    super.key,
    required this.message,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: GestureDetector(
        onTap: () => player.play(message.audioPath),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
              SizedBox(width: 12),
              Container(
                width: 90,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              const Text('0:05', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}