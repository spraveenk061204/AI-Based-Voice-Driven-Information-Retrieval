enum Sender { user, assistant }

class VoiceMessage {
  final String audioPath;
  final String text;
  final bool isLoading;
  final Duration duration;
  final Sender sender;

  VoiceMessage({
    this.audioPath = '',
    this.text = '',
    this.isLoading = false,
    required this.duration,
    required this.sender,
  });
}
