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

# =========================================================
# [수정됨] 공통 Native CMakeLists.txt 불러오기
# =========================================================

# 1. native 폴더의 CMakeLists.txt 실행
# (windows/runner 기준: ../../native/CMakeLists.txt)
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../../native" native_build)

# 2. 메인 실행 파일에 라이브러리 링크
target_link_libraries(${BINARY_NAME} PRIVATE native_audio_plugin)

# 3. DLL 파일 복사 (Windows 전용)
# 빌드 후 생성된 .dll 파일들을 실행 파일(.exe) 옆으로 복사해야 실행됩니다.
add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<TARGET_FILE:native_audio_plugin>
    $<TARGET_FILE_DIR:${BINARY_NAME}>
)

# # ONNX Runtime DLL 복사
# 빌드 후 onnxruntime.dll을 실행 파일 옆으로 복사
file(GLOB ONNX_DLLS "${CMAKE_CURRENT_SOURCE_DIR}/../../native/demucs_bridge/demucs.onnx/vendor/onnxruntime/lib/*.dll")

foreach(dll_file ${ONNX_DLLS})
  add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${dll_file}"
    $<TARGET_FILE_DIR:${BINARY_NAME}>
  )
endforeach()