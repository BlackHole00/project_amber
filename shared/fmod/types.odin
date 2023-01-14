package fmod

SYSTEM      :: distinct rawptr
SOUND       :: distinct rawptr
CHANNEL     :: distinct rawptr
CHANNELCONTROL :: distinct rawptr
CHANNELGROUP :: distinct rawptr
DSP         :: distinct rawptr
SOUNDGROUP  :: distinct rawptr

//typedef FMOD_RESULT (F_CALL *FMOD_SOUND_PCMREAD_CALLBACK)   (FMOD_SOUND *sound, void *data, unsigned int datalen);
SOUND_PCMREAD_CALLBACK :: #type proc(sound: SOUND, data: rawptr, datalen: u32) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_DEBUG_CALLBACK)           (FMOD_DEBUG_FLAGS flags, const char *file, int line, const char* func, const char* message);
DEBUG_CALLBACK :: #type proc(flags: DEBUG_FLAGS, file: cstring, line: i32, fund: cstring, message: cstring) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_SYSTEM_CALLBACK)          (FMOD_SYSTEM *system, FMOD_SYSTEM_CALLBACK_TYPE type, void *commanddata1, void* commanddata2, void *userdata);
SYSTEM_CALLBACK :: #type proc(system: SYSTEM, type: SYSTEM_CALLBACK_TYPE, commanddata1: rawptr, commanddata2: rawptr, user_data: rawptr) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_CHANNELCONTROL_CALLBACK)  (FMOD_CHANNELCONTROL *channelcontrol, FMOD_CHANNELCONTROL_TYPE controltype, FMOD_CHANNELCONTROL_CALLBACK_TYPE callbacktype, void *commanddata1, void *commanddata2);
CHANNELCONTROL_CALLBACK :: #type proc(channelcontrol: CHANNELCONTROL, controltype: CHANNELCONTROL_TYPE, callbacktype: CHANNELCONTROL_CALLBACK_TYPE, commanddata1: rawptr, commanddata2: rawptr) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_DSP_CALLBACK)             (FMOD_DSP *dsp, FMOD_DSP_CALLBACK_TYPE type, void *data);
DSP_CALLBACK :: #type proc(sdp: DSP, type: DSP_CALLBACK_TYPE, data: rawptr) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_SOUND_NONBLOCK_CALLBACK)  (FMOD_SOUND *sound, FMOD_RESULT result);
SOUND_NONBLOCK_CALLBACK :: #type proc(sound: SOUND, result: RESULT) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_SOUND_PCMSETPOS_CALLBACK) (FMOD_SOUND *sound, int subsound, unsigned int position, FMOD_TIMEUNIT postype);
SOUND_PCMSETPOS_CALLBACK :: #type proc(sound: SOUND, subsound: i32, position: u32, postype: TIMEUNIT) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_FILE_OPEN_CALLBACK)       (const char *name, unsigned int *filesize, void **handle, void *userdata);
FILE_OPEN_CALLBACK :: #type proc(name: cstring, filesize: ^u32, handle: ^rawptr, user_data: rawptr) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_FILE_CLOSE_CALLBACK)      (void *handle, void *userdata);
FILE_CLOSE_CALLBACK :: #type proc(handle: rawptr, userdata: rawptr) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_FILE_READ_CALLBACK)       (void *handle, void *buffer, unsigned int sizebytes, unsigned int *bytesread, void *userdata);
FILE_READ_CALLBACK :: #type proc(handle: rawptr, buffer: rawptr, sizebytes: u32, bytesread: ^u32, userdata: rawptr) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_FILE_SEEK_CALLBACK)       (void *handle, unsigned int pos, void *userdata);
FILE_SEEK_CALLBACK :: #type proc(handle: rawptr, pos: u32, userdata: rawptr) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_FILE_ASYNCREAD_CALLBACK)  (FMOD_ASYNCREADINFO *info, void *userdata);
FILE_ASYNCREAD_CALLBACK :: #type proc(info: ^ASYNCREADINFO, userdata: rawptr) -> RESULT
// typedef FMOD_RESULT (F_CALL *FMOD_FILE_ASYNCCANCEL_CALLBACK)(FMOD_ASYNCREADINFO *info, void *userdata);
FILE_ASYNCCANCEL_CALLBACK :: #type proc(info: ^ASYNCREADINFO, userdata: rawptr) -> RESULT
// typedef void        (F_CALL *FMOD_FILE_ASYNCDONE_FUNC)      (FMOD_ASYNCREADINFO *info, FMOD_RESULT result);
FILE_ASYNCDONE_FUNC :: #type proc(info: ^ASYNCREADINFO, result: RESULT)
// typedef void*       (F_CALL *FMOD_MEMORY_ALLOC_CALLBACK)    (unsigned int size, FMOD_MEMORY_TYPE type, const char *sourcestr);
MEMORY_ALLOC_CALLBACK :: #type proc(size: u32, type: MEMORY_TYPE, sourcestr: cstring) -> rawptr
// typedef void*       (F_CALL *FMOD_MEMORY_REALLOC_CALLBACK)  (void *ptr, unsigned int size, FMOD_MEMORY_TYPE type, const char *sourcestr);
MEMORY_REALLOC_CALLBACK :: #type proc(ptr: rawptr, size: u32, type: MEMORY_TYPE, sourcestr: cstring) -> rawptr
// typedef void        (F_CALL *FMOD_MEMORY_FREE_CALLBACK)     (void *ptr, FMOD_MEMORY_TYPE type, const char *sourcestr);
MEMORY_FREE_CALLBACK :: #type proc(ptr: rawptr, type: MEMORY_TYPE, sourcestr: cstring)
// typedef float       (F_CALL *FMOD_3D_ROLLOFF_CALLBACK)      (FMOD_CHANNELCONTROL *channelcontrol, float distance);
FMOD_3D_ROLLOFF_CALLBACK :: #type proc(channel_control: CHANNELCONTROL, distance: f32) -> f32

INITFLAGS   :: u32
DEBUG_FLAGS :: u32
SYSTEM_CALLBACK_TYPE :: u32
TIMEUNIT :: u32
MEMORY_TYPE :: u32
MODE :: u32


RESULT      :: enum {
    OK,
    ERR_BADCOMMAND,
    ERR_CHANNEL_ALLOC,
    ERR_CHANNEL_STOLEN,
    ERR_DMA,
    ERR_DSP_CONNECTION,
    ERR_DSP_DONTPROCESS,
    ERR_DSP_FORMAT,
    ERR_DSP_INUSE,
    ERR_DSP_NOTFOUND,
    ERR_DSP_RESERVED,
    ERR_DSP_SILENCE,
    ERR_DSP_TYPE,
    ERR_FILE_BAD,
    ERR_FILE_COULDNOTSEEK,
    ERR_FILE_DISKEJECTED,
    ERR_FILE_EOF,
    ERR_FILE_ENDOFDATA,
    ERR_FILE_NOTFOUND,
    ERR_FORMAT,
    ERR_HEADER_MISMATCH,
    ERR_HTTP,
    ERR_HTTP_ACCESS,
    ERR_HTTP_PROXY_AUTH,
    ERR_HTTP_SERVER_ERROR,
    ERR_HTTP_TIMEOUT,
    ERR_INITIALIZATION,
    ERR_INITIALIZED,
    ERR_INTERNAL,
    ERR_INVALID_FLOAT,
    ERR_INVALID_HANDLE,
    ERR_INVALID_PARAM,
    ERR_INVALID_POSITION,
    ERR_INVALID_SPEAKER,
    ERR_INVALID_SYNCPOINT,
    ERR_INVALID_THREAD,
    ERR_INVALID_VECTOR,
    ERR_MAXAUDIBLE,
    ERR_MEMORY,
    ERR_MEMORY_CANTPOINT,
    ERR_NEEDS3D,
    ERR_NEEDSHARDWARE,
    ERR_NET_CONNECT,
    ERR_NET_SOCKET_ERROR,
    ERR_NET_URL,
    ERR_NET_WOULD_BLOCK,
    ERR_NOTREADY,
    ERR_OUTPUT_ALLOCATED,
    ERR_OUTPUT_CREATEBUFFER,
    ERR_OUTPUT_DRIVERCALL,
    ERR_OUTPUT_FORMAT,
    ERR_OUTPUT_INIT,
    ERR_OUTPUT_NODRIVERS,
    ERR_PLUGIN,
    ERR_PLUGIN_MISSING,
    ERR_PLUGIN_RESOURCE,
    ERR_PLUGIN_VERSION,
    ERR_RECORD,
    ERR_REVERB_CHANNELGROUP,
    ERR_REVERB_INSTANCE,
    ERR_SUBSOUNDS,
    ERR_SUBSOUND_ALLOCATED,
    ERR_SUBSOUND_CANTMOVE,
    ERR_TAGNOTFOUND,
    ERR_TOOMANYCHANNELS,
    ERR_TRUNCATED,
    ERR_UNIMPLEMENTED,
    ERR_UNINITIALIZED,
    ERR_UNSUPPORTED,
    ERR_VERSION,
    ERR_EVENT_ALREADY_LOADED,
    ERR_EVENT_LIVEUPDATE_BUSY,
    ERR_EVENT_LIVEUPDATE_MISMATCH,
    ERR_EVENT_LIVEUPDATE_TIMEOUT,
    ERR_EVENT_NOTFOUND,
    ERR_STUDIO_UNINITIALIZED,
    ERR_STUDIO_NOT_LOADED,
    ERR_INVALID_STRING,
    ERR_ALREADY_LOCKED,
    ERR_NOT_LOCKED,
    ERR_RECORD_DISCONNECTED,
    ERR_TOOMANYSAMPLES,

    RESULT_FORCEINT = 65536,
}

SOUND_FORMAT :: enum {
    SOUND_FORMAT_NONE,
    SOUND_FORMAT_PCM8,
    SOUND_FORMAT_PCM16,
    SOUND_FORMAT_PCM24,
    SOUND_FORMAT_PCM32,
    SOUND_FORMAT_PCMFLOAT,
    SOUND_FORMAT_BITSTREAM,

    SOUND_FORMAT_MAX,
    SOUND_FORMAT_FORCEINT = 65536,
}

CHANNELCONTROL_TYPE :: enum {
    CHANNELCONTROL_CHANNEL,
    CHANNELCONTROL_CHANNELGROUP,

    CHANNELCONTROL_MAX,
    CHANNELCONTROL_FORCEINT = 65536,
}

CHANNELCONTROL_CALLBACK_TYPE :: enum {
    CHANNELCONTROL_CALLBACK_END,
    CHANNELCONTROL_CALLBACK_VIRTUALVOICE,
    CHANNELCONTROL_CALLBACK_SYNCPOINT,
    CHANNELCONTROL_CALLBACK_OCCLUSION,

    CHANNELCONTROL_CALLBACK_MAX,
    CHANNELCONTROL_CALLBACK_FORCEINT = 65536,
}

DSP_CALLBACK_TYPE :: enum {
    DSP_CALLBACK_DATAPARAMETERRELEASE,

    DSP_CALLBACK_MAX,
    DSP_CALLBACK_FORCEINT = 65536,
}

SOUND_TYPE :: enum {
    SOUND_TYPE_UNKNOWN,
    SOUND_TYPE_AIFF,
    SOUND_TYPE_ASF,
    SOUND_TYPE_DLS,
    SOUND_TYPE_FLAC,
    SOUND_TYPE_FSB,
    SOUND_TYPE_IT,
    SOUND_TYPE_MIDI,
    SOUND_TYPE_MOD,
    SOUND_TYPE_MPEG,
    SOUND_TYPE_OGGVORBIS,
    SOUND_TYPE_PLAYLIST,
    SOUND_TYPE_RAW,
    SOUND_TYPE_S3M,
    SOUND_TYPE_USER,
    SOUND_TYPE_WAV,
    SOUND_TYPE_XM,
    SOUND_TYPE_XMA,
    SOUND_TYPE_AUDIOQUEUE,
    SOUND_TYPE_AT9,
    SOUND_TYPE_VORBIS,
    SOUND_TYPE_MEDIA_FOUNDATION,
    SOUND_TYPE_MEDIACODEC,
    SOUND_TYPE_FADPCM,
    SOUND_TYPE_OPUS,

    SOUND_TYPE_MAX,
    SOUND_TYPE_FORCEINT = 65536,
}

CHANNELORDER :: enum {
    FMOD_CHANNELORDER_DEFAULT,
    FMOD_CHANNELORDER_WAVEFORMAT,
    FMOD_CHANNELORDER_PROTOOLS,
    FMOD_CHANNELORDER_ALLMONO,
    FMOD_CHANNELORDER_ALLSTEREO,
    FMOD_CHANNELORDER_ALSA,

    FMOD_CHANNELORDER_MAX,
    FMOD_CHANNELORDER_FORCEINT = 65536,
}

CREATESOUNDEXINFO :: struct {
    cbsize: i32,
    length: u32,
    fileoffset: u32,
    numchannels: i32,
    defaultfrequency: i32,
    format: SOUND_FORMAT,
    decodebuffersize: u32,
    initialsubsound: i32,
    numsubsounds: i32,
    inclusionlist: [^]i32,
    inclusionlistnum: i32,
    pcmreadcallback: SOUND_PCMREAD_CALLBACK,
    pcmsetposcallback: SOUND_PCMSETPOS_CALLBACK,
    nonblockcallback: SOUND_NONBLOCK_CALLBACK,
    dlsname: cstring,
    encryptionkey: cstring,
    maxpolyphony: i32,
    userdata: rawptr,
    suggestedsoundtype: SOUND_TYPE,
    fileuseropen: FILE_OPEN_CALLBACK,
    fileuserclose: FILE_CLOSE_CALLBACK,
    fileuserread: FILE_READ_CALLBACK,
    fileuserseek: FILE_SEEK_CALLBACK,
    fileuserasyncread: FILE_ASYNCREAD_CALLBACK,
    fileuserasynccancel: FILE_ASYNCCANCEL_CALLBACK,
    fileuserdata: rawptr,
    filebuffersize: i32,
    channelorder: CHANNELORDER,
    initialsoundgroup: SOUNDGROUP,
    initialseekposition: u32,
    initialseekpostype: TIMEUNIT,
    ignoresetfilesystem: i32,
    audioqueuepolicy: u32,
    minmidigranularity: u32,
    nonblockthreadid: i32,
    fsbguid: ^GUID,
}

ASYNCREADINFO :: struct {
    handle: rawptr,
    offset: u32,
    sizebytes: u32,
    priority: i32,
    userdata: rawptr,
    buffer: rawptr,
    bytesread: u32,
    done: FILE_ASYNCDONE_FUNC,
}

GUID :: struct {
    Data1: u32,
    Data2: u16,
    Data3: u16,
    Data4: [8]u8,
}