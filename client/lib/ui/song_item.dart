import 'dart:io';

import 'package:dart_pcm/audio_player/queue_manager.dart';
import 'package:dart_pcm/audio_player/song_model.dart';
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
      var url = Uri.parse(mrLink);
      var response = await http.get(url);
      // String? contentType = response.headers['content-type'];
      String? contentDisposition = response.headers['content-disposition'];
      debugPrint(contentDisposition);
      String? filename = contentDisposition
          ?.split('filename=')[1]
          .replaceAll('"', '');
      // 파일 확장자 추출, 없는 경우에는 .mp3로 설정
      // TODO: 파일 확장자 추출 로직 추가
      String extension = filename?.split('.').last ?? 'mp3';
      debugPrint(filename);
      debugPrint(extension);
      Directory directory = await getApplicationCacheDirectory();
      String filePath = path.join(directory.path, 'songs', '$name.$extension');

      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      debugPrint('$filePath의 파일을 다운로드 완료했습니다');

      // 파일 추가
      DownloadedSong song = DownloadedSong(
        id: id,
        title: name,
        localPath: filePath,
      );
      QueueManager().addSong(song);
      debugPrint('파일을 추가했습니다');
      debugPrint('현재 큐에 있는 노래: ${QueueManager().queueSongs.length}개');
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
