package vx_lib_gfx_backendutils

import core "shared:vx_core"
import "shared:vx_lib/gfx"

GfxBufferAllocator_Entry :: struct {
    raw_buffer: rawptr,
    size: uint,
    usage: gfx.Buffer_Usage,
}

// The Gfx_Buffer_Allocator is a structure that keeps track of the Dynamic-allocationmode buffers created.
// TODO: make more efficient
Gfx_Buffer_Allocator :: struct {
    buffers: [dynamic]GfxBufferAllocator_Entry,
}
GFXBUFFERALLOCATOR_INSTANCE: core.Cell(Gfx_Buffer_Allocator)

gfxbufferallocator_init :: proc() {
    core.cell_init(&GFXBUFFERALLOCATOR_INSTANCE)

    GFXBUFFERALLOCATOR_INSTANCE.buffers = make([dynamic]GfxBufferAllocator_Entry)
}

gfxbufferallocator_register_buffer :: proc(entry: GfxBufferAllocator_Entry) {
    i := 0
    for i < len(GFXBUFFERALLOCATOR_INSTANCE.buffers) && GFXBUFFERALLOCATOR_INSTANCE.buffers[i].size < entry.size {
        i += 1
    }

    append(&GFXBUFFERALLOCATOR_INSTANCE.buffers, GfxBufferAllocator_Entry {})

    j := len(GFXBUFFERALLOCATOR_INSTANCE.buffers) - 2
    for j >= i {
        GFXBUFFERALLOCATOR_INSTANCE.buffers[j + 1] = GFXBUFFERALLOCATOR_INSTANCE.buffers[j]

        j -= 1
    }
    GFXBUFFERALLOCATOR_INSTANCE.buffers[i] = entry
}

gfxbufferallocator_get_buffer :: proc(size: uint, usage: gfx.Buffer_Usage) -> Maybe(GfxBufferAllocator_Entry) {
    if len(&GFXBUFFERALLOCATOR_INSTANCE.buffers) < 1 do return nil

    index := -1
    for entry, i in GFXBUFFERALLOCATOR_INSTANCE.buffers {
        if entry.size > size && entry.usage == usage {
            index = i
            break
        }
    }

    if index == -1 do return nil
    entry := GFXBUFFERALLOCATOR_INSTANCE.buffers[index]

    for i in 0..<(len(GFXBUFFERALLOCATOR_INSTANCE.buffers) - 1) {
        GFXBUFFERALLOCATOR_INSTANCE.buffers[i] = GFXBUFFERALLOCATOR_INSTANCE.buffers[i + 1]
    }

    shrink(&GFXBUFFERALLOCATOR_INSTANCE.buffers, len(GFXBUFFERALLOCATOR_INSTANCE.buffers) - 1)

    return entry
}

// Returned slice valid until gfxbufferallocator_register_buffer or gfxbufferallocator_get_buffer are called.
gfxbufferallocator_get_all :: proc() -> []GfxBufferAllocator_Entry {
    return GFXBUFFERALLOCATOR_INSTANCE.buffers[:]
}

gfxbufferallocator_deinit :: proc() {
    delete(GFXBUFFERALLOCATOR_INSTANCE.buffers)

    core.cell_free(&GFXBUFFERALLOCATOR_INSTANCE)
}