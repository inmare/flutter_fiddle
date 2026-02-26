import 'dart:io';

import 'package:dart_pcm/audio/audio_manager.dart';
import 'package:dart_pcm/audio/song_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SongItem extends StatelessWidget {
  final int id;
  final String name;
  // final String artist;
  final String songLink;
  final String mrLink;
  const SongItem({
    super.key,
    required this.id,
    required this.name,
    // required this.artist,
    required this.songLink,
    required this.mrLink,
  });

  void _downloadSong() async {
    try {
      // 파일 다운로드
      final response = await http.get(Uri.parse(mrLink));
      final directory = await getApplicationCacheDirectory();
      final filePath = path.join(directory.path, 'songs', '$name.mp3');

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      debugPrint('$filePath의 파일을 다운로드 완료했습니다');

      // 파일 추가
      final song = DownloadedSong(id: id, title: name, localPath: filePath);
      AudioManager().addSong(song);
      debugPrint('파일을 추가했습니다');
      debugPrint('현재 큐에 있는 노래: ${AudioManager().queueSongs.length}개');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(name),
        // Text(artist),
        Text(songLink), Text(mrLink),
        ElevatedButton(
          onPressed: () {
            _downloadSong();
          },
          child: Text("추가"),
        ),
      ],
    );
  }
}
