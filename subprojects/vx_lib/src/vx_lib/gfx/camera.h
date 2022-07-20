#pragma once

#if 0

#include <vx_types.h>
#include <vx_default.h>
#include <HandmadeMath.h>
#include <logic/components/components.h>
#include <logic/transform.h>

typedef enum vx_CameraType {
    VX_CAMERATYPE_ORTHOGRAPHIC,
    VX_CAMERATYPE_PERSPECTIVE
} vx_CameraType;

typedef struct vx_CameraDescriptor {
    vx_CameraType camera_type;
    hmm_vec3 position;
    hmm_vec2 rotation;

    union {
        struct {
            f32 fov;
            u32 viewport_width;
            u32 viewport_height;
        };
        struct {
            f32 right;
            f32 left;
            f32 top;
            f32 bottom;
        };
    };

    f32 near;
    f32 far;
} vx_CameraDescriptor;
//VX_CREATE_DEFAULT(vx_CameraDescriptor,
//    .camera_type = VX_DEFAULT(vx_CameraType),
//    .position = { 0.0, 0.0, 0.0 },
//    .rotation = { -90.0, 0.0 },
//    .left = -1.0f,
//    .right = 1.0f,
//    .top = 1.0,
//    .bottom = -1.0f,
//    .near = 0.001f,
//    .far = 100.0f
//)

typedef struct vx_Camera {
    vx_CameraType camera_type;

    vx_Position position;
    vx_Rotation rotation;

    union {
        struct {
            f32 fov;
            u32 viewport_width;
            u32 viewport_height;
        };
        struct {
            f32 right;
            f32 left;
            f32 top;
            f32 bottom;
        };
    };

    f32 near;
    f32 far;

    bool needs_view_update;
    bool needs_proj_update;
} vx_Camera;

vx_Camera vx_camera_new(vx_CameraDescriptor* descriptor);

hmm_mat4 vx_camera_get_view_matrix(vx_Camera* camera);
hmm_mat4 vx_camera_get_proj_matrix(vx_Camera* camera);

void vx_camera_set_viewport_size(vx_Camera* camera, u32 viewport_width, u32 viewport_height);

void vx_camera_apply(vx_Camera* camera, hmm_mat4* proj_mat, hmm_mat4* view_mat, bool ignore_flags);

#endif