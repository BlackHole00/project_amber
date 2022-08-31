package vx_lib_platform

import "vendor:glfw"
import NS "vendor:darwin/foundation"

when ODIN_OS == .Darwin {
//id glfwGetCocoaWindow(GLFWwindow* window);
foreign import glfwlib "system:glfw"

@(default_calling_convention="c", link_prefix="glfw")
foreign glfwlib {
    GetCocoaWindow :: proc(glfw.WindowHandle) -> ^NS.Window ---
}

}