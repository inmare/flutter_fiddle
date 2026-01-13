import 'dart:convert';
import 'dart:typed_data';
import 'dart:math'; // [필수] pow 함수 사용을 위해 추가
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mp_audio_stream/mp_audio_stream.dart';

import 'soundtouch.dart'; // [추가]

void main(List<String> arguments) async {
  runApp(const MaterialApp(home: AudioPlayerScreen()));
}

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioStream _audioStream = getAudioStream();
  bool _isPlaying = false;
  List<int> _leftoverBytes = [];
  // [추가 1] SoundTouch 인스턴스
  late SoundTouch _soundTouch;
  // [추가] 현재 피치(반음 단위) 상태 관리
  int _currentSemitone = 0;

  @override
  void initState() {
    super.initState();

    _audioStream.init(
      bufferMilliSec: 200,
      waitingBufferMilliSec: 100,
      channels: 2,
      sampleRate: 44100,
    );

    // SoundTouch 초기화 및 설정
    _soundTouch = SoundTouch();
    _soundTouch.setSettings(44100, 2, 1.0, 1.0);
  }

  // 반음을 변경하고 SoundTouch에 즉시 적용하는 함수
  void _changePitch(int semitoneDelta) {
    setState(() {
      _currentSemitone += semitoneDelta;
    });

    // 공식: 2^(반음/12)
    double newPitch = pow(2, _currentSemitone / 12.0).toDouble();

    // 실시간으로 SoundTouch 설정 업데이트!
    // (재생 중인 루프에서 다음 청크를 처리할 때 이 값이 바로 반영됩니다)
    _soundTouch.setSettings(44100, 2, newPitch, 1.0);

    print("피치 변경: $_currentSemitone 반음 (배율: $newPitch)");
  }

  void playMusicWithFFmpeg() async {
    setState(() {
      _isPlaying = true;
    });

    _currentSemitone = 0; // 피치 초기화

    final process = await Process.start('assets/ffmpeg.exe', [
      '-re', // Read input at native frame rate
      '-i', 'assets/Miku-Ringtone.mp3', // Input file
      '-f', 'f32le', // PCM 32-bit float little-endian
      '-ar', '44100', // Sample rate
      '-ac', '2', // Number of channels
      '-vn', // No video
      'pipe:1', // Output to stdout
    ]);

    process.stdout.listen(
      (List<int> byteChunk) {
        List<int> currentBatch = [..._leftoverBytes, ...byteChunk];

        // 정수 바이트 데이터를 4바이트 단위로 나누기
        int remainder = currentBatch.length % 4;
        int processableLength = currentBatch.length - remainder;

        // 현재 남아있는 데이터가 너무 적으면 그냥 전체를 저장하기
        if (processableLength == 0) {
          _leftoverBytes = currentBatch;
          return;
        }

        // 남는 데이터는 다음 청크로 넘기기
        List<int> bytesToProcess = currentBatch.sublist(0, processableLength);
        _leftoverBytes = currentBatch.sublist(processableLength);

        // 1. 바이트 -> Float32 변환 (원본 오디오)
        Float32List rawSamples = _bytesToFloat32(bytesToProcess);

        // ========================================================
        // [추가 3] SoundTouch 프로세싱 (여기가 결합 포인트!)
        // 원본 데이터를 넣고, 변조된 데이터를 받습니다.
        // ========================================================
        List<double> processedData = _soundTouch.process(rawSamples);

        // 2. 결과물 -> Float32List로 변환하여 스피커로 전송
        // (SoundTouch에서 아무것도 안 나오면 건너뜀)
        if (processedData.isNotEmpty) {
          _audioStream.push(Float32List.fromList(processedData));
        }
      },
      onDone: () {
        print('재생 끝!');
        setState(() {
          _isPlaying = false;
        });
      },
    );

    // FFmpeg 에러 출력 처리
    process.stderr.transform(utf8.decoder).listen((msg) {
      print('FFmpeg Log: $msg');
    });
  }

  Float32List _bytesToFloat32(List<int> bytes) {
    // 파이프를 통해서 전달받은 바이트 데이터를 리스트로 변환
    Uint8List byteList = Uint8List.fromList(bytes);
    // 정수 리스트를 float32 리스트로 변환
    return Float32List.view(byteList.buffer);
  }

  @override
  void dispose() {
    _audioStream.uninit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("실시간 피치 조절기")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 현재 상태 표시
            Text(
              "현재 피치: ${_currentSemitone > 0 ? '+' : ''}$_currentSemitone 키",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // 컨트롤 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _changePitch(-1), // 1키 내림
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text("-1", style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isPlaying ? null : playMusicWithFFmpeg,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlaying ? Colors.grey : Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                  ),
                  child: Text(
                    _isPlaying ? "재생 중" : "재생 시작",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _changePitch(1), // 1키 올림
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text("+1", style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _changePitch(-_currentSemitone), // 초기화
              child: const Text("피치 초기화 (0)"),
            ),
          ],
        ),
      ),
    );
  }
}
