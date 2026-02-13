# C++ 버전 설정
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 컴파일 명령 내보내기 (clangd에서 파일을 찾을 수 있게 함)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 네이티브 코드의 루트 경로 (이 파일이 있는 곳)
set(NATIVE_ROOT "${CMAKE_CURRENT_LIST_DIR}")

# 라이브러리 소스 파일 검색
file(GLOB_RECURSE SOUNDTOUCH_SOURCES
    "${NATIVE_ROOT}/soundtouch_bridge/soundtouch_bridge.cpp"
    "${NATIVE_ROOT}/soundtouch_bridge/soundtouch/source/SoundTouch/*.cpp"
)

# 라이브러리 정의
add_library(native_audio_plugin SHARED 
    ${SOUNDTOUCH_SOURCES}
)

# 헤더 경로 설정
target_include_directories(native_audio_plugin PUBLIC
    "${NATIVE_ROOT}/soundtouch_bridge/soundtouch/include"
)