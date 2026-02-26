import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SongItem extends StatelessWidget {
  final String name;
  // final String artist;
  final String songLink;
  final String mrLink;
  const SongItem({
    super.key,
    required this.name,
    // required this.artist,
    required this.songLink,
    required this.mrLink,
  });

  void _downloadSong() async {
    final response = await http.get(Uri.parse(mrLink));
    final directory = await getApplicationCacheDirectory();
    final filePath = path.join(directory.path, 'songs', '$name.mp3');

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    debugPrint(filePath);
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
