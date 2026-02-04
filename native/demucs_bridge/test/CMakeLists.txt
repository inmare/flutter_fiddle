cmake_minimum_required(VERSION 3.20)

file(GLOB DEMUCS_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/../demucs.onnx/src/*.cpp")

add_executable(demucs_test 
    "${CMAKE_CURRENT_SOURCE_DIR}/demucs_test.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/../demucs_bridge.cpp"
    ${DEMUCS_SOURCES}
)

target_compile_features(demucs_test PRIVATE cxx_std_17)

target_include_directories(demucs_test PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/.."                 # demucs_bridge.h 위치
    "${CMAKE_CURRENT_SOURCE_DIR}/../demucs.onnx/src" # demucs.hpp 위치
    "${CMAKE_CURRENT_SOURCE_DIR}/../demucs.onnx/vendor/eigen"
    "${CMAKE_CURRENT_SOURCE_DIR}/../demucs.onnx/vendor/onnxruntime/include"
)

# target_link_libraries(demucs_test PRIVATE native_audio_plugin)
set(ONNX_RUNTIME_LIB "${CMAKE_CURRENT_SOURCE_DIR}/../demucs.onnx/vendor/onnxruntime/lib/onnxruntime.lib")
target_link_libraries(demucs_test PRIVATE ${ONNX_RUNTIME_LIB})

# target_compile_definitions(demucs_test PRIVATE 
#     ORT_API_VERSION=23
#     ORT_API_MANUAL_INIT
# )

if (WIN32)
    add_custom_command(TARGET demucs_test POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/../demucs.onnx/vendor/onnxruntime/lib/onnxruntime.dll"
        "$<TARGET_FILE_DIR:demucs_test>"
    )
endif()