#ifndef SOUNDTOUCH_BRIDGE_H
#define SOUNDTOUCH_BRIDGE_H

// C언어 규칙으로 이름을 고정해서 ffigen이 읽을 수 있도록 함
#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

// Windows에서 DLL 함수를 외부에 공개하기 위한 선언
#ifdef _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT
#endif

FFI_EXPORT bool demucs_load_model(const char *htdemucs_model_path,
                                  int intraNumThreads, int interNumThreads);
FFI_EXPORT void demucs_split_audio(const float *audioData,
                                   const int numSamplesPerChannel,
                                   const int numChannels, const int sampleRate,
                                   float *outDrums, float *outBass,
                                   float *outOther, float *outVocals);

#ifdef __cplusplus
}
#endif

#endif // SOUNDTOUCH_BRIDGE_H