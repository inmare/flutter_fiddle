import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:dart_pcm/audio_player/ffmpeg_audio.dart';
import 'package:dart_pcm/audio_player/queue_manager.dart';
import 'package:dart_pcm/ui/queue_song_item.dart';
import 'package:flutter/material.dart';

import 'audio_button.dart';

class AudioPlayer extends StatefulWidget {
  const AudioPlayer({super.key});

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

// 오디오 플레이를 담당하는 위젯
class _AudioPlayerState extends State<AudioPlayer> {
  @override
  void initState() {
    super.initState();

    FFmpegAudio().init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// FFmpeg로 노래 재생하기
  void _playMusic() async {
    QueueManager().startSong();
  }

  void _cancelMusic() {
    QueueManager().cancelSong();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          StreamBuilder(
            stream: FFmpegAudio().currentTimeStream,
            builder: (context, snapshot) {
              double progress = snapshot.data ?? 0.0;
              return ProgressBar(
                progress: Duration(seconds: progress.toInt()),
                total: Duration(seconds: FFmpegAudio().totalTime.toInt()),
              );
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              AudioButton(label: '시작', onPressed: _playMusic),
              AudioButton(label: '취소', onPressed: _cancelMusic),
              AudioButton(label: '간주 점프', onPressed: () {}),
              AudioButton(label: '음정 +1', onPressed: () {}),
              AudioButton(label: '음정 -1', onPressed: () {}),
            ],
          ),
          Expanded(
            // ListenableBuilder를 사용하여 AudioManager의 상태 변화를 감지하여 리스트 업데이트
            child: ListenableBuilder(
              listenable: QueueManager(),
              builder: (context, child) {
                // builder 내부에서 AudioManager 호출
                final queueSong = QueueManager().queueSongs;
                return ListView.builder(
                  itemCount: queueSong.length,
                  itemBuilder: (context, index) {
                    return QueueSongItem(
                      id: queueSong[index].id,
                      name: queueSong[index].localPath,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
