#ifndef DEMUCS_BRIDGE_H
#define DEMUCS_BRIDGE_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>
#include <stdbool.h>

#ifdef _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT
#endif
    
    typedef struct {
        const char* error_message;
        bool success;
    } LoadResult ;

    FFI_EXPORT LoadResult demucs_load_model(
        const char* htdemucs_model_path,
        int32_t intraNumThreads,
        int32_t interNumThreads
    );

#ifdef __cplusplus
}
#endif

#endif // DEMUCS_BRIDGE_H