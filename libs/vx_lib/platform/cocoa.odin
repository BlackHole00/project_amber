//+build darwin

package vx_lib_platform

when ODIN_OS == .Darwin {

import "vendor:glfw"
import NS "vendor:darwin/Foundation"

foreign import glfwlib "system:glfw"

@(default_calling_convention="c", link_prefix="glfw")
foreign glfwlib {
    //id glfwGetCocoaWindow(GLFWwindow* window);
    GetCocoaWindow :: proc(glfw.WindowHandle) -> ^NS.Window ---
}

}