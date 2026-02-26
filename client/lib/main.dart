import 'dart:io';

import 'package:dart_pcm/ui/audio_player.dart';
import 'package:dart_pcm/ui/song_search.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  runApp(const MaterialApp(home: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  void _initCacheDir() async {
    final cacheDir = await getApplicationCacheDirectory();
    debugPrint(cacheDir.path);
    // song 폴더가 존재하는지 확인 후 없으면 생성하기
    final songDir = Directory(path.join(cacheDir.path, 'songs'));
    if (!await songDir.exists()) {
      await songDir.create(recursive: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _initCacheDir();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: <Widget>[
              Tab(text: "노래방", icon: Icon(Icons.play_circle_outline)),
              Tab(text: "검색", icon: Icon(Icons.search)),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: const TabBarView(children: [AudioPlayer(), SongSearch()]),
        ),
      ),
    );
  }
}
