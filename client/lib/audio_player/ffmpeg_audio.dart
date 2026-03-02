import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_pcm/utils/audio_utils.dart';
import 'package:flutter/rendering.dart';
import 'package:mp_audio_stream/mp_audio_stream.dart';

class FFmpegAudio {
  // 이것도 싱글턴임... 온 세상이 싱글턴이다
  static final FFmpegAudio _instance = FFmpegAudio._internal();
  factory FFmpegAudio() => _instance;
  FFmpegAudio._internal();

  /// 오디오 스트림
  final AudioStream _audioStream = getAudioStream();

  /// ffmpeg process
  Process? _process;

  /// 샘플링 레이트
  final int _sampleRate = 44100;

  /// 채널 수
  final int _channels = 2;

  double _currentTime = 0.0;
  double get currentTime => _currentTime;

  final StreamController<double> _currentTimeController =
      StreamController<double>.broadcast();
  Stream<double> get currentTimeStream => _currentTimeController.stream;

  double _totalTime = 0.0;
  double get totalTime => _totalTime;

  /// AudioStream 초기화 함수
  void init() {
    _audioStream.init(
      bufferMilliSec: 5000,
      waitingBufferMilliSec: 500,
      channels: _channels,
      sampleRate: _sampleRate,
    );
  }

  /// AudioStream 해제 함수
  void stop() {
    _process?.kill();
    _process = null;
    _currentTimeController.add(0.0);
    _currentTime = 0.0;
    _totalTime = 0.0;
  }

  void dispose() {
    stop();
    _audioStream.uninit();
    _currentTimeController.close();
  }

  /// FFmpeg로 노래 재생하기
  /// [url] 노래 파일 경로
  /// [startTime] 재생 시작 시간
  void play(String url, double startTime) async {
    // 기존에 process가 존재하면 종료
    _process?.kill();
    _currentTime = startTime;

    // 전체 시간 계산
    ProcessResult probeProcess = await Process.run("assets/ffprobe.exe", [
      '-i', url, // Input file
      '-v', 'quiet', // 로그 출력 없음
      '-print_format', 'json', // 출력 형식 json
      '-show_format', // 포맷 정보 출력
    ]);

    Map<String, dynamic> probeResult = jsonDecode(probeProcess.stdout);
    debugPrint(probeResult.toString());
    double totalTime = double.parse(probeResult['format']['duration'] ?? '0');
    _totalTime = totalTime;

    // 새로운 프로세스 시작
    _process = await Process.start('assets/ffmpeg.exe', [
      '-ss', '$startTime', // Start time
      '-re', // Read input at native frame rate
      '-i', url, // Input file
      '-f', 'f32le', // PCM 32-bit float little-endian
      '-ar', '$_sampleRate', // Sample rate
      '-ac', '$_channels', // Number of channels
      '-vn', // No video
      'pipe:1', // Output to stdout
    ]);

    // 32bit float 데이터로 변환 후 스피커로 전송
    _process?.stdout.listen((List<int> byteChunk) {
      Float32List rawSamples = bytesToFloat32(byteChunk);
      if (rawSamples.isNotEmpty) {
        _audioStream.push(rawSamples);
        _currentTime += rawSamples.length / _sampleRate / _channels;
        // 1초 이상 차이가 날 때만 업데이트

        _currentTimeController.add(_currentTime);
      }
    });

    // FFmpeg 에러, 로그 출력
    _process?.stderr.transform(utf8.decoder).listen((msg) => debugPrint(msg));
  }
}
