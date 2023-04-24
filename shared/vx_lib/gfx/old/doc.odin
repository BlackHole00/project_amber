//+build ignore

// This package provides a bindless OpenGL abstraction layer. It can use OpenGL
// 4.6 with DSA or OpenGL 3.3 (see common.MODERN_OPENGL for more info).  
// By design most objects are not mutable after their creation, so if a 
// modification is needed, a new object should be created.
// This table represents the OpenGL primitives and corrisponding vx_lib 
// counterparts.  
// |-------------------------|-------------------------|
// |OpenGl                   |vx_lib                   |
// |-------------------------|-------------------------|
// |Vertex Buffer Object     |Buffer                   |
// |Element Buffer Object    |Buffer                   |
// |Vertex Array Object      |Pipeline                 |
// |Program                  |Pipeline                 |
// |Texture                  |Texture                  |
// |Framebuffer Object       |Framebuffer              |
// |Renderbuffer Object      |Renderbuffer (TODO)      |
// |-------------------------|-------------------------|
package vx_lib_gfx