//+build ignore

// This package provides interfaces for the platform (that is the operating 
// system and libraries).  
// It provides a Platform (singleton) that can be used to easily initialize
// external libraries.  
// If GLFW is initialized it is possible to use an abstraction layer over
// the window and the user input, using Window (singleton), Window_Context
// (singleton) and Window_Helper (singleton). 
package vx_lib_window