import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_pcm/utils/audio_utils.dart';
import 'package:flutter/material.dart';
import 'package:mp_audio_stream/mp_audio_stream.dart';

import 'audio_button.dart';

class AudioPlayer extends StatefulWidget {
  const AudioPlayer({super.key});

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

// 오디오 플레이를 담당하는 위젯
class _AudioPlayerState extends State<AudioPlayer> {
  // 오디오 스트림은 나중에 채워 넣음
  final AudioStream _audioStream = getAudioStream();
  bool _isPlaying = false; // 재생 중인지 여부
  double _currentTime = 0.0; // 현재 재생 위치

  @override
  void initState() {
    super.initState();

    // AudioStream 초기화
    _audioStream.init(
      bufferMilliSec: 200,
      waitingBufferMilliSec: 100,
      channels: 2,
      sampleRate: 44100,
    );
  }

  @override
  void dispose() {
    // 상태 변화
    setState(() {
      _isPlaying = false;
    });
    // AudioStream 해제
    _audioStream.uninit();
    super.dispose();
  }

  /// FFmpeg로 노래 재생하기
  void _playMusic() async {
    // 상태 변화
    setState(() {
      _isPlaying = true;
    });

    final process = await Process.start('assets/ffmpeg.exe', [
      '-re', // Read input at native frame rate
      '-i', 'assets/Miku-Ringtone.mp3', // Input file
      '-f', 'f32le', // PCM 32-bit float little-endian
      '-ar', '44100', // Sample rate
      '-ac', '2', // Number of channels
      '-vn', // No video
      'pipe:1', // Output to stdout
    ]);

    // 32bit float 데이터로 변환 후 스피커로 전송
    process.stdout.listen((List<int> byteChunk) {
      Float32List rawSamples = bytesToFloat32(byteChunk);
      if (rawSamples.isNotEmpty) {
        _audioStream.push(rawSamples);
      }
    });

    // FFmpeg 에러, 로그 출력
    process.stderr.transform(utf8.decoder).listen((msg) {
      debugPrint(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        AudioButton(label: '시작', onPressed: _playMusic),
        AudioButton(label: '간주 점프', onPressed: () {}),
        AudioButton(label: '음정 +1', onPressed: () {}),
        AudioButton(label: '음정 -1', onPressed: () {}),
      ],
    );
  }
}
