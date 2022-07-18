#include <vx_utils/utils.h>
#include <vx_utils/traits/traits.h>
#include <vx_utils/loggers/stream_logger.h>
#include <vx_lib/os/window.h>
#include <vx_lib/os/window_helper.h>
#include <vx_lib/os/keys.h>
#include <vx_lib/os/context/bgfx_context.h>
#include <vx_lib/gfx/bgfx/shader_utils.h>
#include <bgfx/bgfx.h>
#include <bx/bx.h>
#include <bx/math.h>

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_WIN32
#define GLFW_EXPOSE_NATIVE_WGL
#include <GLFW/glfw3native.h>

namespace am {

struct Vertex {
    f32 x;
    f32 y;
    f32 z;
    u32 abgr;
};
VX_CREATE_INSTANCE(bgfx::VertexLayout, VERTEX_LAYOUT);

Vertex VERTICES[] = {
    Vertex { -0.5, -0.5, 0.0, 0xff0000ff },
    Vertex {  0.5, -0.5, 0.0, 0xff00ff00 },
    Vertex {  0.0,  0.5, 0.0, 0xffff0000 }
};

struct GameData {
    bgfx::VertexBufferHandle v_buffer;
    bgfx::ShaderHandle v_shader;
    bgfx::ShaderHandle f_shader;
    bgfx::ProgramHandle program;
    u64 state;
};
VX_CREATE_INSTANCE(GameData, GAMEDATA_INSTANCE);

void init() {
    const bx::Vec3 at  = { 0.0f, 0.0f,   0.0f };
    const bx::Vec3 eye = { 0.0f, 0.0f, -35.0f };

    vx::Vec2<i32> window_size = vx::windowhelper_state_get_window_size();

    float view[16];
	bx::mtxLookAt(view, eye, at);

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
		| BGFX_STATE_CULL_CW
		| BGFX_STATE_MSAA;

    VERTEX_LAYOUT.begin()
        .add(bgfx::Attrib::Position, 3, bgfx::AttribType::Float)
		.add(bgfx::Attrib::Color0,   4, bgfx::AttribType::Uint8, true)
    .end();
    VERTEX_LAYOUT_VALID = true;

    GAMEDATA_INSTANCE.v_buffer = bgfx::createVertexBuffer(bgfx::makeRef(VERTICES, 3 * sizeof(Vertex)), VERTEX_LAYOUT);
    GAMEDATA_INSTANCE.v_shader = vx::option_unwrap(vx::load_bgfx_shader("basic", "vs_basic"));
    GAMEDATA_INSTANCE.f_shader = vx::option_unwrap(vx::load_bgfx_shader("basic", "fs_basic"));
    GAMEDATA_INSTANCE.program  = bgfx::createProgram(GAMEDATA_INSTANCE.v_shader, GAMEDATA_INSTANCE.f_shader, true);

    GAMEDATA_INSTANCE_VALID = true;
}

void logic() {
    if (vx::windowhelper_input_get_keystate(vx::Key::Escape).pressed) {
        vx::windowhelper_close_window();
    }
}

void draw() {
    bgfx::setViewRect(0, 0, 0, uint16_t(640), uint16_t(480) );
    bgfx::setViewClear(0, BGFX_CLEAR_COLOR, 0);

	// This dummy draw call is here to make sure that view 0 is cleared
	// if no other draw calls are submitted to view 0.
	//bgfx::touch(0);

    bgfx::setVertexBuffer(0, GAMEDATA_INSTANCE.v_buffer);
    bgfx::setState(GAMEDATA_INSTANCE.state);
    bgfx::submit(0, GAMEDATA_INSTANCE.program);

    bgfx::frame();
    //bgfx::renderFrame(-1);
}

void resize() {
    var size = vx::windowhelper_state_get_window_size();
    vx::log(vx::LogMessageLevel::INFO, "Window resized to %dx%d", size.width, size.height);

    bgfx::setViewRect(0, 0, 0, (u16)(size.width), (u16)(size.height));
}

void close() {
    bgfx::destroy(GAMEDATA_INSTANCE.v_buffer);
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

    vx::window_init(&descriptor);
    vx::window_run();

    vx::allocator_stack_get_current_allocator()->memory_report();

    return 0;
}

