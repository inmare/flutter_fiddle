#include "soundtouch_bridge.h"
#include "soundtouch/include/SoundTouch.h"

using namespace soundtouch;

void *soundtouch_create() {
  SoundTouch *st = new SoundTouch();
  return (void *)st;
}

void soundtouch_set_settings(void *handle, int sampleRate, int channels,
                             float pitch, float tempo) {
  SoundTouch *st = (SoundTouch *)handle;
  st->setSampleRate(sampleRate);
  st->setChannels(channels);
  st->setPitch(pitch);
  st->setTempo(tempo);
}

// 입력과 출력이 별개의 함수로 구분된 이유
// SoundTouch는 어느 정도 내부에 데이터가 쌓여야 처리를 시작하기 때문에
// 두 동작을 독립된 동작으로 구분시켜서 계속 스트리밍을 함

void soundtouch_put_samples(void *handle, const float *samples,
                            int numSamples) {
  SoundTouch *st = (SoundTouch *)handle;
  int channels = 2;
  st->putSamples(samples, numSamples / channels);
}

int soundtouch_receive_samples(void *handle, float *outputBuffer,
                               int maxSamples) {
  SoundTouch *st = (SoundTouch *)handle;
  int channels = 2;
  return st->receiveSamples(outputBuffer, maxSamples / channels);
}

void soundtouch_destroy(void *handle) { delete (SoundTouch *)handle; }
