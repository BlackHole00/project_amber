package vx_lib_platform

import core "shared:vx_core"

Platform_Extension_Identifier :: distinct string

Platform_Extension :: struct {
    name: Platform_Extension_Identifier,
    version: core.Version,

    init_proc: proc() -> (result: Platform_Operation_Result, message: string),
    preframe_proc: proc() -> (result: Platform_Operation_Result, message: string),
    postframe_proc: proc() -> (result: Platform_Operation_Result, message: string),
    deinit_proc: proc() -> (result: Platform_Operation_Result, message: string),

    // A list of extensions that must be completed **before** the execution of this extensions'procedures.
    dependencies: []Platform_Extension_Identifier,
    // A list of extensions that must be executed **after** the exectution of this extensions'procedures.
    dependants: []Platform_Extension_Identifier,
}

Platform_Extension_Info :: struct {
    name: Platform_Extension_Identifier,
    version: core.Version,
    dependencies: []Platform_Extension_Identifier,
    dependants: []Platform_Extension_Identifier,
}