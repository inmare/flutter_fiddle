#include "demucs_bridge.h"
#include <iostream>


// 만약 demucs_load_model 함수가 static으로 선언되어 있다면
// 테스트 파일에서 include "demucs_bridge.cpp"를 직접 해서 테스트하거나
// static을 잠시 풀고 링크해야 합니다.
// 여기서는 헤더를 통해 링크된다고 가정합니다.

int main() {
  std::cout << "Starting Demucs Test..." << std::endl;

  // 1. 모델 경로 설정 (실제 경로로 수정 필요)
  const char *modelPath = "D:/Fiddles/dart_pcm/assets/htdemucs.onnx";

  // 2. 함수 호출
  std::cout << "Loading model from: " << modelPath << std::endl;
  LoadResult result = demucs_load_model(modelPath, 4, 4);

  // 3. 결과 확인
  if (result.success) {
    std::cout << "[SUCCESS] Model loaded successfully!" << std::endl;
  } else {
    std::cout << "[FAILED] Model loading failed." << std::endl;
    std::cout << "Error message: " << result.error_message << std::endl;
  }

  return 0;
}