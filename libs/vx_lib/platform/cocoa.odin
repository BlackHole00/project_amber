//+build darwin

package vx_lib_platform

when ODIN_OS == .Darwin {

import "vendor:glfw"
import NS "vendor:darwin/Foundation"

//id glfwGetCocoaWindow(GLFWwindow* window);
foreign import glfwlib "system:glfw"

@(default_calling_convention="c", link_prefix="glfw")
foreign glfwlib {
    GetCocoaWindow :: proc(glfw.WindowHandle) -> ^NS.Window ---
}

}