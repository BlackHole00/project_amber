package vx_lib_core

import "core:mem"
import "core:log"

Cell :: struct($T: typeid) {
    using ptr: ^T,
    allocator: mem.Allocator,
}

cell_init_raw :: proc(cell: ^Cell($T), allocator := context.allocator) {
    when ODIN_DEBUG {
        if cell.ptr != nil {
            log.warn("Double init of cell", cell, "(of type", typeid_of(T), ")")
        }
    } 

    cell.allocator = allocator
    cell.ptr = new(T, allocator)
}

cell_init_with_data :: proc(cell: ^Cell($T), data: T, allocator := context.allocator) {
    when ODIN_DEBUG {
        if cell.ptr != nil {
            log.warn("Double init of cell", cell, "(of type", typeid_of(T), ")")
        }
    }

    cell.allocator = allocator
    cell.ptr = new(T, allocator)
    cell.ptr^ = data
}

cell_init :: proc { cell_init_raw, cell_init_with_data }

cell_free :: proc(cell: ^Cell($T)) {
    when ODIN_DEBUG {
        if cell.ptr == nil {
            log.warn("Double free of cell", cell, "(of type", typeid_of(T), ")")
        }
    }

    free(cell.ptr, cell.allocator)
    cell.ptr = nil
}

cell_is_valid :: proc(cell: Cell($T)) -> bool {
    return cell.ptr != nil
}