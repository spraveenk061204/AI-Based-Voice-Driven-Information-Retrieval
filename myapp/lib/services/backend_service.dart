import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

class BackendService {
      static const String _endpoint =
      'http://10.0.2.2:8000/process-audio';

  Future<String> sendAudio(File audioFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(_endpoint),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        contentType: MediaType('audio', 'm4a'),
      ),
    );

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.statusCode}');
    }

    final responseBody = await response.stream.bytesToString();
    final json = jsonDecode(responseBody);

    final audioUrl = json['audio_url'] as String;

    return await _downloadAudio(audioUrl);
  }

  /// Downloads assistant audio and saves locally
  Future<String> _downloadAudio(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('Failed to download audio');
    }

    final dir = await getTemporaryDirectory();
    print('${dir.path}');
    final filePath =
        '${dir.path}/assistant_${DateTime.now().millisecondsSinceEpoch}.m4a';

    final file = File(filePath);
    await file.writeAsBytes(res.bodyBytes);
    return file.path;
  }
}