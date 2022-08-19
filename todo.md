### TODOs:

- [ ] move gfx.pipeline_bind_rendertarget into renderbuffer and resize renderbuffers directly
    - maybe not: the pipeline should be in charge of clearing. If the buffer is not large enough is the programmer's fault.
- [ ] migrate prs stuff to logic.Transform and logic.AbstractTransform
- [ ] remove gfx.Layout and gfx.Shader and unite then in gfx.Pipeline
- [ ] do not use gfx.*_bind/*_apply functions and create gfx.Bindings
- [ ] remove texture_unit and add them to bindings
- [X] find better name for gfx.pipeline_bind
- [ ] decide what to do about gfx.Texture_Bundle (moved to gfx.old)
- [ ] make gfx.Gl_State_Manager to not bind already bound stuff
- [ ] rename gl_drawmode into gl_primitive
- [X] use DMA and DSA since I'm using opengl 4.6
- [ ] test framebuffer