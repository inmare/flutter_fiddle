cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# 1. 현재 파일(windows/runner/CMakeLists.txt) 기준으로 프로젝트 루트 경로 계산
# (runner -> windows -> project_root)
get_filename_component(PROJECT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)

# 디버깅용 메시지 출력 (빌드할 때 터미널에 경로가 찍힙니다)
message(STATUS ">>> 프로젝트 루트 경로 확인: ${PROJECT_ROOT}")

# 2. 소스 파일 검색 (절대 경로 사용)
file(GLOB_RECURSE SOUNDTOUCH_SOURCES
  "${PROJECT_ROOT}/native/bridge.cpp"
  "${PROJECT_ROOT}/native/soundtouch/source/SoundTouch/*.cpp"
)

# 3. [안전장치] 만약 소스 파일을 못 찾았으면 에러를 띄우고 멈춤
if(NOT SOUNDTOUCH_SOURCES)
  message(FATAL_ERROR "SoundTouch 소스 파일을 찾을 수 없습니다! 위 경로에 실제 파일이 있는지 확인해주세요.")
endif()

# soundtouch_plugin 이라는 이름의 라이브러리 생성
add_library(soundtouch_plugin SHARED ${SOUNDTOUCH_SOURCES})

# 헤더파일의 경로 지정
target_include_directories(soundtouch_plugin PUBLIC
  "../../native/soundtouch/include"
)

# flutter에서 soundtouch_plugin 라이브러리를 링크하도록 지정
target_link_libraries(${BINARY_NAME} PRIVATE soundtouch_plugin)

# 빌드된 dll 파일을 실행 파일 옆으로 복사
add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<TARGET_FILE:soundtouch_plugin>
    $<TARGET_FILE_DIR:${BINARY_NAME}>
)