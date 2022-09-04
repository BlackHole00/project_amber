### TODOs:

- [ ] move gfx.pipeline_bind_rendertarget into renderbuffer and resize renderbuffers directly
    - maybe not: the pipeline should be in charge of clearing. If the buffer is not large enough is the programmer's fault.
- [ ] migrate prs stuff to logic.Transform and logic.AbstractTransform
- [X] remove gfx.Layout and gfx.Shader and unite then in gfx.Pipeline
- [X] do not use gfx.*_bind/*_apply functions and create gfx.Bindings
- [X] remove texture_unit and add them to bindings
- [X] find better name for gfx.pipeline_bind
- [X] decide what to do about gfx.Texture_Bundle (moved to gfx.old) -> removed
- [X] make gfx.Gl_State_Manager to not bind already bound stuff
- [ ] rename gl_drawmode into gl_primitive
- [X] use DMA and DSA since I'm using opengl 4.6
- [ ] test framebuffer
- [X] layout should not need gl.VertexArrayAttribFormat for every bind. Fix.

- [ ] light stuff

- [ ] text rendering
- [X] immediate mode graphics
- [ ] microui

- [X] figure out why the skybox pipeline needs to have the depth disabled

- [ ] chunk should have different meshes, depending on the type of the block
- [ ] chunk should not own a mesh, instead should own an abstract mesh and the renderer will apply it to a real mesh.

- [ ] allow creating an empty buffer with defined size
- [ ] buffer resizing in a better way

- [ ] OpenGL: Implement BlendColor
- [ ] Common: Add remaining Src1 blend functions