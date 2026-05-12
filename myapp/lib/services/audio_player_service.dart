import 'package:just_audio/just_audio.dart';


class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String path) async {
    await _player.setFilePath(path);
    await _player.play();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}