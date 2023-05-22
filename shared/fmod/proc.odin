package fmod

when #config(ENABLE_FMOD, false) {

when ODIN_OS == .Windows do foreign import fmod "libs/fmod64.lib"
else do #panic("no fmod support yet!")

@(default_calling_convention="c", link_prefix="FMOD_")
foreign fmod {
    System_Create :: proc(system: ^SYSTEM, headerversion: u32) -> RESULT ---
    System_Init :: proc(system: SYSTEM, maxchannels: i32, falgs: INITFLAGS, extradriverdata: rawptr) -> RESULT ---
    System_Release :: proc(system: SYSTEM) -> RESULT ---
    System_Close :: proc(system: SYSTEM) -> RESULT ---
    System_CreateSound :: proc(system: SYSTEM, name_or_data: cstring, mode: MODE, exinfo: ^CREATESOUNDEXINFO, sound: ^SOUND) -> RESULT ---
    System_Update :: proc(system : SYSTEM) -> RESULT ---
    System_PlaySound :: proc(system: SYSTEM, sound: SOUND, channelgroup: CHANNELGROUP, paused: bool, channel: ^CHANNEL) -> RESULT ---
    System_Set3DSettings :: proc(system: SYSTEM, dopplerscale: f32, distancefactor: f32, rolloffscale: f32) -> RESULT ---

    Sound_Release :: proc(sound: SOUND) -> RESULT ---
    Sound_SetMode :: proc(sound: SOUND, mode: MODE) -> RESULT ---
    Sound_Set3DMinMaxDistance :: proc(sound: SOUND, min: f32, max: f32) -> RESULT ---
// FMOD_RESULT F_API FMOD_Channel_Set3DAttributes          (FMOD_CHANNEL *channel, const FMOD_VECTOR *pos, const FMOD_VECTOR *vel);
    Channel_Set3DAttributes :: proc(channel: CHANNEL, pos: ^VECTOR, vel: ^VECTOR) -> RESULT ---
}

}
