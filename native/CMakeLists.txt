# 컴파일 명령 내보내기 (clangd가 파일을 찾을 수 있게 해줍니다)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 네이티브 코드의 루트 경로 (이 파일이 있는 곳)
set(NATIVE_ROOT "${CMAKE_CURRENT_LIST_DIR}")

# 라이브러리 소스 파일 검색
file(GLOB_RECURSE SOUNDTOUCH_SOURCES
    "${NATIVE_ROOT}/soundtouch_bridge/soundtouch_bridge.cpp"
    "${NATIVE_ROOT}/soundtouch_bridge/soundtouch/source/SoundTouch/*.cpp"
)

file(GLOB_RECURSE DEMUCS_SOURCES
    "${NATIVE_ROOT}/demucs_bridge/demucs_bridge.cpp"
    "${NATIVE_ROOT}/demucs_bridge/demucs.onnx/src/*.cpp"
)

# 라이브러리 정의
add_library(native_audio_plugin SHARED 
    ${SOUNDTOUCH_SOURCES}
    ${DEMUCS_SOURCES}
)

# 헤더 경로 설정
target_include_directories(native_audio_plugin PUBLIC
    "${NATIVE_ROOT}/soundtouch_bridge/soundtouch/include"
    "${NATIVE_ROOT}/demucs_bridge"
    "${NATIVE_ROOT}/demucs_bridge/demucs.onnx/src"
    "${NATIVE_ROOT}/demucs_bridge/demucs.onnx/vendor/eigen"
    "${NATIVE_ROOT}/demucs_bridge/demucs.onnx/vendor/onnxruntime/include"
    "${NATIVE_ROOT}/demucs_bridge/demucs.onnx/vendor/libnyquist/include" # 나중에 주석 처리하기
)

# === [수정] ONNX Runtime 라이브러리 링크 ===
# 1. 라이브러리 파일 (.lib) 위치 지정
set(ONNX_RUNTIME_LIB "${NATIVE_ROOT}/demucs_bridge/demucs.onnx/vendor/onnxruntime/lib/onnxruntime.lib")

# 2. 링크 연결
target_link_libraries(native_audio_plugin PRIVATE ${ONNX_RUNTIME_LIB})