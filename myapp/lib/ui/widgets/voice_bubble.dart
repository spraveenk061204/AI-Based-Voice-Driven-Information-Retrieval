import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/voice_message.dart';
import '../../services/audio_player_service.dart';

class VoiceBubble extends StatefulWidget {
  final VoiceMessage message;
  final AudioPlayerService player;

  const VoiceBubble({
    super.key,
    required this.message,
    required this.player,
  });

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 1);
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    /// ✅ Track current playback position
    widget.player.positionStream.listen((pos) {
      if (widget.player.currentPath == widget.message.audioPath) {
        setState(() => _position = pos);
      }
    });

    /// ✅ Track total audio duration
    widget.player.durationStream.listen((dur) {
      if (dur != null &&
          widget.player.currentPath == widget.message.audioPath) {
        setState(() => _duration = dur);
      }
    });

    /// ✅ Track playing / paused state
    widget.player.playerStateStream.listen((state) {
      final isThisBubblePlaying =
          state.playing &&
              widget.player.currentPath == widget.message.audioPath;

      setState(() {
        isPlaying = isThisBubblePlaying;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.sender == Sender.user;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isUser ? Colors.white10: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            /// ✅ Play / Pause button
            GestureDetector(
              onTap: () async {
                if (isPlaying) {
                  await widget.player.pause();
                } else {
                  await widget.player.play(widget.message.audioPath);
                }
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isUser ? Colors.white : Colors.black,
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isUser ? Colors.black : Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// ✅ Progress + Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ✅ Progress bar
                  Slider(
                    activeColor: isUser ? Colors.white : Colors.black,
                    inactiveColor: Colors.grey,
                    value: _position.inMilliseconds
                        .clamp(0, _duration.inMilliseconds)
                        .toDouble(),
                    max: _duration.inMilliseconds.toDouble(),
                    onChanged: (value) async {
                      await widget.player.seek(
                        Duration(milliseconds: value.toInt()),
                      );
                    },
                  ),

                  /// ✅ Time display
                  Text(
                    "${_format(_position)} / ${_format(_duration)}",
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds =
    (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}