#include "demucs_bridge.h"
#include "demucs.hpp"
#include "tensor.hpp"
#include <chrono>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stddef.h>
#include <vector>

static demucsonnx::demucs_model model;
static bool model_loaded;

extern "C" {

FFI_EXPORT bool
demucs_load_model(const char *htdemucs_model_path, int intraNumThreads,
                  int interNumThreads) { // create Ort::SessionOptions
  Ort::SessionOptions session_options;

  // max out threads and increase performance to the max on my beefy
  // desktop CPU
  session_options.SetExecutionMode(ExecutionMode::ORT_PARALLEL);
  session_options.SetIntraOpNumThreads(intraNumThreads);
  session_options.SetInterOpNumThreads(interNumThreads);

  // General optimizations
  // ORT_ENABLE_ALL: 모든 최적화 수행
  // ORT_ENABLE_BASIC: 기본 최적화 수행
  // ORT_DISABLE_ALL: 최적화 수행 안함
  session_options.SetGraphOptimizationLevel(
      GraphOptimizationLevel::ORT_ENABLE_ALL);

  // struct demucsonnx::demucs_model model;

  std::ifstream file(htdemucs_model_path, std::ios::binary | std::ios::ate);
  if (!file) {
    model_loaded = false;
    std::cerr << "Failed to open model file: " << htdemucs_model_path
              << std::endl;
    return model_loaded;
    // throw std::runtime_error("Failed to open model file: " +
    // htdemucs_model_path);
  }

  std::streamsize size = file.tellg();
  file.seekg(0, std::ios::beg);

  std::vector<char> file_data(size);
  if (!file.read(file_data.data(), size)) {
    // throw std::runtime_error("Failed to read model file.");
    model_loaded = false;
    std::cerr << "Failed to read model file: " << htdemucs_model_path
              << std::endl;
    return model_loaded;
  }

  // std::string model_path_string

  bool success = demucsonnx::load_model(file_data, model, session_options);
  if (!success) {
    // throw std::runtime_error("Failed to load model.");
    model_loaded = false;
    std::cerr << "Failed to load model: " << htdemucs_model_path << std::endl;
    return false;
  }

  model_loaded = true;
  return model_loaded;
}

FFI_EXPORT void demucs_split_audio(const float *audioData,
                                   const int numSamplesPerChannel,
                                   const int numChannels, const int sampleRate,
                                   float *outDrums, float *outBass,
                                   float *outOther, float *outVocals) {
  if (!model_loaded) {
    std::cerr << "Model not loaded." << std::endl;
    return;
  }

  // 파일 데이터를 eigen matrix로 변환환
  Eigen::MatrixXf audio(2, numSamplesPerChannel);

  if (numChannels == 1) {
    // Mono case
    for (std::size_t i = 0; i < numSamplesPerChannel; ++i) {
      audio(0, i) = audioData[i]; // left channel
      audio(1, i) = audioData[i]; // right channel
    }
  } else {
    // Stereo case
    for (std::size_t i = 0; i < numSamplesPerChannel; ++i) {
      audio(0, i) = audioData[2 * i];     // left channel
      audio(1, i) = audioData[2 * i + 1]; // right channel
    }
  }

  // 읽어온 데이터를 기반으로 inference 수행행
  // Eigen::MatrixXf audio = load_audio_file(wav_file);
  std::cout << "Running Demucs.onnx inference." << std::endl;

  // set output precision to 3 decimal places
  std::cout << std::fixed << std::setprecision(3);

  demucsonnx::ProgressCallback progressCallback =
      [](float progress, const std::string &log_message) {
        std::cout << "(" << std::setw(3) << std::setfill(' ')
                  << progress * 100.0f << "%) " << log_message << std::endl;
      };

  // create 4 audio matrix same size, to hold output
  Eigen::Tensor3dXf out_targets;
  auto start_time = std::chrono::high_resolution_clock::now();

  try {
    Eigen::Tensor3dXf audio_targets =
        demucsonnx::demucs_inference(model, audio, progressCallback);

    if (audio_targets.size() == 0) {
      std::cerr << "Inference failed! No output." << std::endl;
      return;
    }

    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
        end_time - start_time);

    std::cout << "Inference time: " << duration.count() << " ms" << std::endl;

    std::cout << "Inference successful! Shape: " << audio_targets.dimension(0)
              << "x" << audio_targets.dimension(1) << "x"
              << audio_targets.dimension(2) << std::endl;

    out_targets = audio_targets;
  } catch (const std::exception &e) {
    std::cerr << "Inference failed with exception: " << e.what() << std::endl;
    return;
  } catch (...) {
    std::cerr << "Inference failed with unknown exception." << std::endl;
    return;
  }

  int nb_out_sources = model.nb_sources;
  int output_samples = out_targets.dimension(2);
  int loop_samples = (output_samples < numSamplesPerChannel)
                         ? output_samples
                         : numSamplesPerChannel;

  for (int target = 0; target < nb_out_sources; ++target) {
    std::string target_name;
    float *target_buffer = nullptr;

    switch (target) {
    case 0:
      target_name = "drums";
      target_buffer = outDrums;
      break;
    case 1:
      target_name = "bass";
      target_buffer = outBass;
      break;
    case 2:
      target_name = "other";
      target_buffer = outOther;
      break;
    case 3:
      target_name = "vocals";
      target_buffer = outVocals;
      break;
    default:
      continue;
    }

    if (target_buffer == nullptr) {
      continue;
    }

    Eigen::MatrixXf target_waveform(2, audio.cols());

    // copy the input stereo wav file into all 4 targets
    for (int i = 0; i < loop_samples; ++i) {
      target_buffer[2 * i] = out_targets(target, 0, i);
      target_buffer[2 * i + 1] = out_targets(target, 1, i);
    }
  }

  std::cout << "Processing complete. Audio data copied to output buffers."
            << std::endl;
}
}
