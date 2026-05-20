/*import 'dart:io';

import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  String? currentPath;  // ✅ track active audio

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Future<void> play(String path) async {
    if (path.isEmpty) {
      print("❌ Empty path");
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      print("❌ File not found: $path");
      return;
    }

    if (currentPath != path) {
      currentPath = path;

      await _player.stop();
      await _player.setFilePath(path);
    }

    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}*/
import 'dart:io';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  String? currentPath;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream =>
      _player.playerStateStream;

  Future<void> play(String path) async {
    try {
      if (path.isEmpty) {
        print("❌ Empty audio path");
        return;
      }

      /// ✅ ✅ IMPORTANT FIX FOR WEB (EDGE)
      if (path.startsWith("http")) {
        print("🌐 Playing from URL: $path");

        await _player.setUrl(path);
      } else {
        print("📁 Playing from file: $path");

        final file = File(path);

        if (!await file.exists()) {
          print("❌ File not found");
          return;
        }

        await _player.setFilePath(path);
      }

      currentPath = path;

      await _player.play();
    } catch (e) {
      print("❌ Audio error: $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

