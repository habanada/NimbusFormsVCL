#ifndef NIMBUS_CODE_EDITOR_RENDERER_ABI_H
#define NIMBUS_CODE_EDITOR_RENDERER_ABI_H
#include <windows.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef struct NimbusCodeFontV1 {
    uint32_t struct_size;
    const wchar_t* name;
    uint32_t name_length;
    int32_t pixel_height;
    uint32_t style;
    uint32_t ppi;
} NimbusCodeFontV1;
typedef struct NimbusCodeRendererAPIV1 {
    uint32_t struct_size;
    uint32_t version;
    void* (__cdecl *create_instance)(void);
    void (__cdecl *destroy_instance)(void*);
    int32_t (__cdecl *begin_frame)(void*, HDC, const RECT*, uint32_t);
    int32_t (__cdecl *end_frame)(void*);
    int32_t (__cdecl *fill_rectangle)(void*, const RECT*, uint32_t);
    int32_t (__cdecl *stroke_rectangle)(void*, const RECT*, uint32_t, float);
    int32_t (__cdecl *draw_line)(void*, int32_t, int32_t, int32_t, int32_t, uint32_t, float);
    int32_t (__cdecl *draw_text)(void*, const wchar_t*, uint32_t, const NimbusCodeFontV1*, const RECT*, uint32_t);
    int32_t (__cdecl *measure_text)(void*, const wchar_t*, uint32_t, const NimbusCodeFontV1*, int32_t*, int32_t*);
    int32_t (__cdecl *push_clip)(void*, const RECT*);
    int32_t (__cdecl *pop_clip)(void*);
} NimbusCodeRendererAPIV1;
__declspec(dllexport) int32_t __cdecl NimbusCodeRendererGetAPI(uint32_t version, NimbusCodeRendererAPIV1* api, uint32_t api_size);
#ifdef __cplusplus
}
#endif
#endif
