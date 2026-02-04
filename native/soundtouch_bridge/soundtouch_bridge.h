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

typedef void *handle;

// 모든 함수 앞에 FFI_EXPORT를 붙여줍니다.
FFI_EXPORT handle soundtouch_create();
FFI_EXPORT void soundtouch_set_settings(handle handle, int32_t sampleRate,
                                        int32_t channels, float pitch,
                                        float tempo);
FFI_EXPORT void soundtouch_put_samples(handle handle, const float *samples,
                                       int32_t numSamples);
FFI_EXPORT int32_t soundtouch_receive_samples(handle handle,
                                              float *outputBuffer,
                                              int32_t maxSamples);
FFI_EXPORT void soundtouch_destroy(handle handle);

#ifdef __cplusplus
}
#endif

#endif // SOUNDTOUCH_BRIDGE_H