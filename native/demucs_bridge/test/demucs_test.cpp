#include "demucs_bridge.h"
#include <fstream>
#include <iostream>
#include <stddef.h>
#include <vector>

// using namespace nqr;

int main() {
  std::string model_path = "htdemucs.onnx";
  bool success = demucs_load_model(model_path.c_str(), 4, 1);
  if (!success) {
    std::cerr << "Failed to load model." << std::endl;
    return 1;
  }

  std::cout << "Model loaded successfully." << std::endl;

  // raw 파일 로드
  std::ifstream rawFile("audio.raw", std::ios::binary);
  if (!rawFile.is_open()) {
    std::cerr << "Failed to open raw file." << std::endl;
    return 1;
  }
  std::cout << "Raw file loaded successfully." << std::endl;

  // 파일 크기 구하기
  rawFile.seekg(0, std::ios::end);
  size_t fileSize = rawFile.tellg();
  rawFile.seekg(0, std::ios::beg);

  size_t numSamplesPerChannel = fileSize / (sizeof(float) * 2);
  std::vector<float> rawData(numSamplesPerChannel * 2);
  rawFile.read(reinterpret_cast<char *>(rawData.data()), fileSize);

  std::vector<float> outDrums(numSamplesPerChannel * 2);
  std::vector<float> outBass(numSamplesPerChannel * 2);
  std::vector<float> outOther(numSamplesPerChannel * 2);
  std::vector<float> outVocals(numSamplesPerChannel * 2);

  demucs_split_audio(rawData.data(), numSamplesPerChannel, 2, 44100,
                     outDrums.data(), outBass.data(), outOther.data(),
                     outVocals.data());

  // 검증: 첫 몇 개의 샘플 값 출력해보기
  std::cout << "--- Inference Result Check ---" << std::endl;
  std::cout << "Drums [L, R]: " << outDrums[0] << ", " << outDrums[1]
            << std::endl;
  std::cout << "Bass  [L, R]: " << outBass[0] << ", " << outBass[1]
            << std::endl;
  std::cout << "Other [L, R]: " << outOther[0] << ", " << outOther[1]
            << std::endl;
  std::cout << "Vocals[L, R]: " << outVocals[0] << ", " << outVocals[1]
            << std::endl;

  // 간단한 값 검증 (모두 0이면 문제 있음)
  float sum = 0.0f;
  for (float v : outVocals)
    sum += std::abs(v);

  if (sum > 0.0f) {
    std::cout << "Test Passed: Vocal track has non-zero data." << std::endl;
  } else {
    std::cerr
        << "Test Warning: Vocal track is all zeros (could be silence or error)."
        << std::endl;
  }

  struct OutputTrack {
    std::string filename;
    const std::vector<float> &data;
  };

  std::vector<OutputTrack> tracks = {{"out_drums.raw", outDrums},
                                     {"out_bass.raw", outBass},
                                     {"out_other.raw", outOther},
                                     {"out_vocals.raw", outVocals}};

  for (const auto &track : tracks) {
    std::ofstream outFile(track.filename, std::ios::binary);
    if (outFile.is_open()) {
      outFile.write(reinterpret_cast<const char *>(track.data.data()),
                    track.data.size() * sizeof(float));
      outFile.close();
      std::cout << "Saved track to " << track.filename << std::endl;
    } else {
      std::cerr << "Failed to open file for track: " << track.filename
                << std::endl;
    }
  }

  return 0;
}