#include "camera.h"

#if 0

vx_Camera vx_camera_new(vx_CameraDescriptor* descriptor) {
    vx_Camera camera;

    camera.camera_type = descriptor->camera_type;

    camera.position = vx_position_new(descriptor->position);
    camera.rotation = vx_rotation_new(HMM_Vec3(
        descriptor->rotation.X,
        descriptor->rotation.Y,
        0.0f
    ));

    camera.viewport_width = descriptor->viewport_width;
    camera.viewport_height = descriptor->viewport_height;

    camera.near = descriptor->near;
    camera.far = descriptor->far;

    if (camera.camera_type == VX_CAMERATYPE_ORTHOGRAPHIC) {
        camera.left = descriptor->left;
        camera.right = descriptor->right;
        camera.top = descriptor->top;
        camera.bottom = descriptor->bottom;
    } else {
        camera.fov = descriptor->fov;
    }

    camera.needs_proj_update = true;
    camera.needs_view_update = true;

    return camera;
}

hmm_mat4 vx_camera_get_view_matrix(vx_Camera* camera) {
    return HMM_LookAt(camera->position.position_vector, HMM_AddVec3(camera->position.position_vector, camera->rotation.front_vector), HMM_Vec3(0.0, 1.0, 0.0));
}

hmm_mat4 vx_camera_get_proj_matrix(vx_Camera* camera) {
    if (camera->camera_type == VX_CAMERATYPE_ORTHOGRAPHIC) {
        return HMM_Orthographic(camera->left, camera->right, camera->bottom, camera->top, camera->near, camera->far);
    } else {
        return HMM_Perspective(camera->fov, (f32)camera->viewport_width / (f32)camera->viewport_height, camera->near, camera->far);
    }
}

void vx_camera_set_viewport_size(vx_Camera* camera, u32 viewport_width, u32 viewport_height) {
    camera->viewport_width = viewport_width;
    camera->viewport_height = viewport_height;

    camera->needs_proj_update = true;
}

void vx_camera_apply(vx_Camera* camera, hmm_mat4* proj_mat, hmm_mat4* view_mat, bool ignore_flags) {
    if (ignore_flags) {
        *(proj_mat) = vx_camera_get_proj_matrix(camera);
        *(view_mat) = vx_camera_get_view_matrix(camera);
    } else {
        if (camera->needs_proj_update) {
            *(proj_mat) = vx_camera_get_proj_matrix(camera);
            camera->needs_proj_update = false;
        }
        if (camera->needs_view_update) {
            *(view_mat) = vx_camera_get_view_matrix(camera);
            camera->needs_view_update = false;
        }
    }
}

#endif
