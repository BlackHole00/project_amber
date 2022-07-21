#include <vx_utils/utils.h>
#include <vx_utils/traits/traits.h>
#include <vx_utils/loggers/stream_logger.h>
#include <vx_lib/os/window.h>
#include <vx_lib/os/window_helper.h>
#include <vx_lib/os/keys.h>
#include <vx_lib/os/context/bgfx_context.h>
#include <vx_lib/gfx/bgfx/shader_utils.h>
#include <vx_lib/logic/components/components.h>
#include <bgfx/bgfx.h>
#include <bx/bx.h>
#include <bx/math.h>
#include <cmath>
#include <FastNoiseLite.h>

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_WIN32
#define GLFW_EXPOSE_NATIVE_WGL
#include <GLFW/glfw3native.h>

namespace am {

void test(const vx::Position* pos) {}

struct Vertex {
    f32 x;
    f32 y;
    f32 z;
    u32 abgr;
};
VX_CREATE_INSTANCE(bgfx::VertexLayout, VERTEX_LAYOUT);

Vertex VERTICES[] = {
    // FRONT FACE
    Vertex { -0.5, -0.5, 0.5, 0xff0000ff },
    Vertex {  0.5, -0.5, 0.5, 0xff0000ff },
    Vertex {  0.5,  0.5, 0.5, 0xff0000ff },
    Vertex { -0.5,  0.5, 0.5, 0xff0000ff },

    // REAR FACE
    Vertex { -0.5, -0.5, -0.5, 0xff00ffff },
    Vertex { -0.5,  0.5, -0.5, 0xff00ffff },
    Vertex {  0.5,  0.5, -0.5, 0xff00ffff },
    Vertex {  0.5, -0.5, -0.5, 0xff00ffff },

    // LEFT FACE
    Vertex { -0.5, -0.5, -0.5, 0xff00ff00 },
    Vertex { -0.5, -0.5,  0.5, 0xff00ff00 },
    Vertex { -0.5,  0.5,  0.5, 0xff00ff00 },
    Vertex { -0.5,  0.5, -0.5, 0xff00ff00 },

    // RIGHT FACE
    Vertex {  0.5, -0.5, -0.5, 0xffffff00 },
    Vertex {  0.5,  0.5, -0.5, 0xffffff00 },
    Vertex {  0.5,  0.5,  0.5, 0xffffff00 },
    Vertex {  0.5, -0.5,  0.5, 0xffffff00 },

    // TOP FACE
    Vertex { -0.5,  0.5, -0.5, 0xffff0000 },
    Vertex { -0.5,  0.5,  0.5, 0xffff0000 },
    Vertex {  0.5,  0.5,  0.5, 0xffff0000 },
    Vertex {  0.5,  0.5, -0.5, 0xffff0000 },

    // BOTTOM FACE
    Vertex { -0.5, -0.5, -0.5, 0xffff00ff },
    Vertex {  0.5, -0.5, -0.5, 0xffff00ff },
    Vertex {  0.5, -0.5,  0.5, 0xffff00ff },
    Vertex { -0.5, -0.5,  0.5, 0xffff00ff },

};
u16 INDICES[] = {
    // FRONT FACE
    0, 1, 2, 2, 3, 0,

    // REAR FACE
    4, 5, 6, 6, 7, 4,

    // LEFT FACE
    8, 9, 10, 10, 11, 8,

    // RIGHT FACE
    12, 13, 14, 14, 15, 12,

    // TOP FACE
    16, 17, 18, 18, 19, 16,

    // BOTTOM FACE
    20, 21, 22, 22, 23, 20
};

struct GameData {
    static constexpr bx::Vec3 at  = { 0.0f, 0.0f,  0.0f };
    static constexpr bx::Vec3 eye = { 0.0f, 0.0f,  3.0f };

    fnl_state noise;

//    f32 x_rot = 0.0f;
//    f32 y_rot = 0.0f;
//    f32 z_rot = 0.0f;
//
//    f32 x_pos = 0.0f;
//    f32 y_pos = 0.0f;
//    f32 z_pos = 0.0f;
    //vx::Transform transform;
    vx::Position position;
    vx::Rotation rotation;
    vx::Scale scale;

    bgfx::VertexBufferHandle v_buffer;
    bgfx::IndexBufferHandle i_buffer;
    bgfx::ShaderHandle v_shader;
    bgfx::ShaderHandle f_shader;
    bgfx::ProgramHandle program;
    u64 state;
};
VX_CREATE_INSTANCE(GameData, GAMEDATA_INSTANCE);

void init() {
    vx::Vec2<i32> window_size = vx::windowhelper_state_get_window_size();

    GAMEDATA_INSTANCE.noise = fnlCreateState();
    GAMEDATA_INSTANCE.noise.noise_type = FNL_NOISE_OPENSIMPLEX2;
    GAMEDATA_INSTANCE.noise.frequency = 0.2;
    GAMEDATA_INSTANCE.noise.seed = vx::windowhelper_system_time();

    float view[16];
	bx::mtxLookAt(view, GAMEDATA_INSTANCE.eye, GAMEDATA_INSTANCE.at);

	float proj[16];
	bx::mtxProj(proj, 60.0f, (f32)(window_size.width) / (f32)(window_size.height), 0.1f, 100.0f, bgfx::getCaps()->homogeneousDepth);
	bgfx::setViewTransform(0, view, proj);

    float model[16];
    bx::mtxIdentity(model);
    bgfx::setTransform(model);

	// Set view 0 default viewport.
	bgfx::setViewRect(0, 0, 0, (u16)(window_size.width), (u16)(window_size.height));

    GAMEDATA_INSTANCE.state = 0
		| BGFX_STATE_WRITE_R
		| BGFX_STATE_WRITE_G
		| BGFX_STATE_WRITE_B
		| BGFX_STATE_WRITE_A
		| BGFX_STATE_WRITE_Z
        | BGFX_STATE_DEPTH_TEST_LESS
		| BGFX_STATE_CULL_CCW
		| BGFX_STATE_MSAA;

    VERTEX_LAYOUT.begin()
        .add(bgfx::Attrib::Position, 3, bgfx::AttribType::Float)
		.add(bgfx::Attrib::Color0,   4, bgfx::AttribType::Uint8, true)
    .end();
    VERTEX_LAYOUT_VALID = true;

    GAMEDATA_INSTANCE.v_buffer = bgfx::createVertexBuffer(bgfx::makeRef(VERTICES, VX_ARRAY_ELEMENT_COUNT(VERTICES) * sizeof(Vertex)), VERTEX_LAYOUT);
    GAMEDATA_INSTANCE.i_buffer = bgfx::createIndexBuffer (bgfx::makeRef(INDICES, VX_ARRAY_ELEMENT_COUNT(INDICES) * sizeof(u16)));
    GAMEDATA_INSTANCE.v_shader = vx::option_unwrap(vx::load_bgfx_shader("basic", "vs_basic"));
    GAMEDATA_INSTANCE.f_shader = vx::option_unwrap(vx::load_bgfx_shader("basic", "fs_basic"));
    GAMEDATA_INSTANCE.program  = bgfx::createProgram(GAMEDATA_INSTANCE.v_shader, GAMEDATA_INSTANCE.f_shader, true);

    GAMEDATA_INSTANCE_VALID = true;
}

void logic() {
    if (vx::windowhelper_input_get_keystate(vx::Key::Escape).pressed) {
        vx::windowhelper_close_window();
    }
    if (vx::windowhelper_input_get_keystate(vx::Key::LeftAlt).pressed &&
        vx::windowhelper_input_get_keystate(vx::Key::Enter).just_pressed
    ) {
        vx::windowhelper_state_set_fullscreen(!vx::windowhelper_state_is_fullscreen());
    }

    GAMEDATA_INSTANCE.rotation.x = std::remainder(vx::windowhelper_time(), 2 * VX_PI);
    GAMEDATA_INSTANCE.rotation.y = std::remainder(vx::windowhelper_time() + 0.5 * VX_PI, 2 * VX_PI);
    GAMEDATA_INSTANCE.rotation.z = std::remainder(vx::windowhelper_time() + VX_PI, 2 * VX_PI);

    GAMEDATA_INSTANCE.position.x = fnlGetNoise2D(&GAMEDATA_INSTANCE.noise,  vx::windowhelper_time(),  0) * 3.0f;
    GAMEDATA_INSTANCE.position.y = fnlGetNoise2D(&GAMEDATA_INSTANCE.noise,  0,  vx::windowhelper_time()) * 3.0f;
    GAMEDATA_INSTANCE.position.z = -4.0f;

    f32 scale = fnlGetNoise2D(&GAMEDATA_INSTANCE.noise, vx::windowhelper_time(), vx::windowhelper_time()) + 1.1f;
    GAMEDATA_INSTANCE.scale.x = scale;
    GAMEDATA_INSTANCE.scale.y = scale;
    GAMEDATA_INSTANCE.scale.z = scale;
}

void draw() {
    bgfx::setViewClear(0, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH, 0x00000000, 1.0f, 0);
    bgfx::setState(GAMEDATA_INSTANCE.state);

    bgfx::setVertexBuffer(0, GAMEDATA_INSTANCE.v_buffer);
    bgfx::setIndexBuffer(GAMEDATA_INSTANCE.i_buffer);

    float model[16];
    //float tmp[16], tmp2[16];
    //bx::mtxFromQuaternion(tmp2, bx::fromEuler(bx::Vec3(GAMEDATA_INSTANCE.x_rot, GAMEDATA_INSTANCE.y_rot, GAMEDATA_INSTANCE.z_rot)));
    //bx::mtxTranslate(tmp, GAMEDATA_INSTANCE.x_pos, GAMEDATA_INSTANCE.y_pos, GAMEDATA_INSTANCE.z_pos);
    //bx::mtxMul(model, tmp2, tmp);
    //vx::to_matrix(&GAMEDATA_INSTANCE.transform, model);
    //bgfx::setTransform(model);

    bgfx::submit(0, GAMEDATA_INSTANCE.program);

    bgfx::frame();
}

void resize() {
    vx::Vec2<i32> window_size = vx::windowhelper_state_get_window_size();
    vx::log(vx::LogMessageLevel::INFO, "Window resized to %dx%d", window_size.width, window_size.height);

    bgfx::setViewRect(0, 0, 0, (u16)(window_size.width), (u16)(window_size.height));

    float view[16];
	bx::mtxLookAt(view, GAMEDATA_INSTANCE.eye, GAMEDATA_INSTANCE.at);

	float proj[16];
	bx::mtxProj(proj, 60.0f, (f32)(window_size.width) / (f32)(window_size.height), 0.1f, 100.0f, bgfx::getCaps()->homogeneousDepth);
	bgfx::setViewTransform(0, view, proj);
}

void close() {
    bgfx::destroy(GAMEDATA_INSTANCE.v_buffer);
    bgfx::destroy(GAMEDATA_INSTANCE.i_buffer);
    bgfx::destroy(GAMEDATA_INSTANCE.program);
}

};

int main() {
    vx::stream_logger_init(stdout, vx::LogMessageLevel::DEBUG);
    vx::allocator_stack_init();

    VX_DEFER(vx::stream_logger_free());
    VX_DEFER(vx::allocator_stack_free());

    vx::windowcontext_init_with_bgfx();

    vx::WindowDescriptor descriptor;
    descriptor.resizable = true;
    descriptor.title = "Project Amber";
    descriptor.init_fn  = am::init;
    descriptor.logic_fn = am::logic;
    descriptor.draw_fn  = am::draw;
    descriptor.close_fn = am::close;
    descriptor.resize_fn = am::resize;
    //descriptor.size = vx::vec2_new<i32>(1024, 480);
    descriptor.size = vx::vec2_new<i32>(1024, 768);

    vx::window_init(&descriptor);
    vx::window_run();

    vx::allocator_stack_get_current_allocator()->memory_report();

    return 0;
}

