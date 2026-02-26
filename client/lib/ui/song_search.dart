import 'dart:convert';
import 'package:dart_pcm/ui/song_item.dart';
import 'package:flutter/material.dart';
import '../api/server.dart';

class SongSearch extends StatefulWidget {
  const SongSearch({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SongSearchState();
  }
}

class _SongSearchState extends State<SongSearch> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> _songs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: "검색어",
            border: OutlineInputBorder(),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final res = await getResponse(_textController.text);
            debugPrint(res.toString());
            setState(() {
              _songs = res;
            });
          },
          child: const Text("검색"),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _songs.length,
            itemBuilder: (context, index) {
              return SongItem(
                name: _songs[index]["title"],
                // artist: _songs[index]["artist"],
                songLink: _songs[index]["songLink"],
                mrLink: _songs[index]["mrLink"],
              );
            },
          ),
        ),
      ],
    );
  }
}
