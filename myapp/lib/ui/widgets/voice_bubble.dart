import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/voice_message.dart';
import '../../services/audio_player_service.dart';

class VoiceBubble extends StatefulWidget {
  final VoiceMessage message;
  final FlutterTts tts;   // ✅ ADD THIS

  const VoiceBubble({
    super.key,
    required this.message,
    required this.tts,   // ✅ ADD THIS
  });


  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  /*Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 1);
  bool isPlaying = false;*/

  @override
  void initState() {
    super.initState();

    /// ✅ Track current playback position
    /* widget.player.positionStream.listen((pos) {
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
    });*/
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.sender == Sender.user;
    if (widget.message.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
              ),
            ),
            SizedBox(width: 8),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ✅ LEFT SIDE (Assistant avatar)
          if (!isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),

          if (!isUser) const SizedBox(width: 8),

          /// ✅ CENTER (Label + bubble)
          Column(
            crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [

              /// ✅ Label
              Text(
                isUser ? "You" : "Assistant",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              /// ✅ YOUR EXISTING BUBBLE (unchanged logic)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: isUser

                /// ✅ USER → TEXT MESSAGE
                    ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.message.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                )

                /// ✅ ASSISTANT → TEXT MESSAGE
                    : Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// ✅ ASSISTANT TEXT
                      Text(
                        widget.message.text,
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 8),

                      /// ✅ 🔊 REPLAY BUTTON
                      GestureDetector(
                        onTap: () async {
                          await widget.tts.setLanguage("en-US");
                          await widget.tts.setSpeechRate(0.85);

                          await widget.tts.stop();
                          await widget.tts.speak(widget.message.text);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.volume_up, size: 18, color: Colors.white70),
                            SizedBox(width: 4),
                            Text(
                              "Replay",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (isUser) const SizedBox(width: 8),

          /// ✅ RIGHT SIDE (User avatar)
          if (isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueGrey,
              child:
              Icon(Icons.person, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }

/*String _format(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds =
    (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }*/
}