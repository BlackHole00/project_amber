package fmod

when ODIN_OS == .Windows do foreign import fmod "fmod64.lib"
else do #panic("no fmod support yet!")

@(default_calling_convention="c", link_prefix="FMOD_")
foreign fmod {
    // FMOD_RESULT F_API FMOD_System_Create               (FMOD_SYSTEM **system, unsigned int headerversion); 
    System_Create :: proc(system: ^SYSTEM, headerversion: u32) -> RESULT ---
    // FMOD_RESULT F_API FMOD_System_Init                      (FMOD_SYSTEM *system, int maxchannels, FMOD_INITFLAGS flags, void *extradriverdata);
    System_Init :: proc(system: SYSTEM, maxchannels: i32, falgs: INITFLAGS, extradriverdata: rawptr) -> RESULT ---
    // FMOD_RESULT F_API FMOD_System_Release              (FMOD_SYSTEM *system); 
    System_Release :: proc(system: SYSTEM) -> RESULT ---
    // FMOD_RESULT F_API FMOD_System_Close                     (FMOD_SYSTEM *system);
    System_Close :: proc(system: SYSTEM) -> RESULT ---
    // FMOD_RESULT F_API FMOD_System_CreateSound               (FMOD_SYSTEM *system, const char *name_or_data, FMOD_MODE mode, FMOD_CREATESOUNDEXINFO *exinfo, FMOD_SOUND **sound);
    System_CreateSound :: proc(system: SYSTEM, name_or_data: cstring, mode: MODE, exinfo: ^CREATESOUNDEXINFO, sound: ^SOUND) -> RESULT ---
    // FMOD_RESULT F_API FMOD_System_Update                    (FMOD_SYSTEM *system);
    System_Update :: proc(system : SYSTEM) -> RESULT ---
    // FMOD_RESULT F_API FMOD_System_PlaySound                 (FMOD_SYSTEM *system, FMOD_SOUND *sound, FMOD_CHANNELGROUP *channelgroup, FMOD_BOOL paused, FMOD_CHANNEL **channel);
    System_PlaySound :: proc(system: SYSTEM, sound: SOUND, channelgroup: CHANNELGROUP, paused: bool, channel: ^CHANNEL) -> RESULT ---

    // FMOD_RESULT F_API FMOD_Sound_Release                    (FMOD_SOUND *sound);
    Sound_Release :: proc(sound: SOUND) -> RESULT ---
    // FMOD_RESULT F_API FMOD_Sound_SetMode                    (FMOD_SOUND *sound, FMOD_MODE mode);
    Sound_SetMode :: proc(sound: SOUND, mode: MODE) -> RESULT ---
}