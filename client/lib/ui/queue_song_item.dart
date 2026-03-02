import 'package:dart_pcm/audio_player/queue_manager.dart';
import 'package:flutter/material.dart';

class QueueSongItem extends StatelessWidget {
  final int id;
  final String name;
  const QueueSongItem({super.key, required this.id, required this.name});

  void _removeSong() {
    QueueManager().removeSong(id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(name),
        ElevatedButton(
          onPressed: () {
            _removeSong();
          },
          child: Icon(Icons.delete),
        ),
      ],
    );
  }
}
