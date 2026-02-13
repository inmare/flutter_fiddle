// lib/soundtouch.dart
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'bindings/native_audio_bindings.dart'; // ffigen이 생성한 파일 임포트

class SoundTouch {
  late NativeAudioBindings _native; // ffigen 클래스
  late Pointer<Void> _handle; // 객체 주소

  SoundTouch() {
    // 1. 라이브러리 로드
    final DynamicLibrary dylib = Platform.isWindows
        ? DynamicLibrary.open('native_audio_plugin.dll')
        : DynamicLibrary.process(); // 다른 플랫폼 대응 시

    // 2. 바인딩 클래스 초기화
    _native = NativeAudioBindings(dylib);

    // 3. 객체 생성 (ffigen이 만들어준 함수 호출)
    _handle = _native.soundtouch_create();

    print("SoundTouch Loaded with ffigen: $_handle");
  }

  void setSettings(int rate, int channels, double pitch, double tempo) {
    // ffigen은 타입 캐스팅을 자동으로 처리해줍니다.
    _native.soundtouch_set_settings(_handle, rate, channels, pitch, tempo);
  }

  List<double> process(List<double> inputSamples) {
    final int count = inputSamples.length;
    if (count == 0) return [];

    // calloc로 0으로 초기화된 C 메모리 생성
    final Pointer<Float> inputPtr = calloc<Float>(count);
    // 이를 dart의 typedList로 변환 후 데이터를 복사함
    // 이는 기존에 사용하던 for문으로 일일히 복사하는 것보다 빠름
    inputPtr.asTypedList(count).setAll(0, inputSamples);

    // SoundTouch에 데이터 넣기
    _native.soundtouch_put_samples(_handle, inputPtr, count);
    // calloc로 만들어진 메모리는 dart의 GC에서 관리하지 않기 때문에 직접 해제해 줘야 함
    calloc.free(inputPtr);

    // 결과 데이터 수집
    // 템포가 느려지거나, 연산 결과상 더 많은 데이터가 나올 수 있기 때문에 그에 대한 여유공간을 둠
    final int maxOutput = (count * 2) + 1024;
    final Pointer<Float> outputPtr = calloc<Float>(maxOutput);
    final List<double> result = [];

    while (true) {
      // soundtouch에서 receiveSamples는 프레임 값을 반환
      int framesReceived = _native.soundtouch_receive_samples(
        _handle,
        outputPtr,
        maxOutput,
      );

      if (framesReceived <= 0) break;

      // bridge.cpp에서 channels을 2로 고정했기에 frame수에 2를 곱해줌
      int samplesToRead = framesReceived * 2;

      // 결과 리스트에 한꺼번에 추가 (루프 최적화)
      result.addAll(outputPtr.asTypedList(samplesToRead));
    }

    calloc.free(outputPtr);
    return result;
  }

  void dispose() {
    _native.soundtouch_destroy(_handle);
  }
}
