enum Sender { user, assistant }

class VoiceMessage {
  final String audioPath;
  final Duration duration;
  final Sender sender;

  VoiceMessage({
    required this.audioPath,
    required this.duration,
    required this.sender,
  });
}