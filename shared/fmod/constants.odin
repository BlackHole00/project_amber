package fmod

// #define FMOD_VERSION    0x00020211
VERSION :: 0x00020211

// initialization
INIT_NORMAL                            :: 0x00000000
INIT_STREAM_FROM_UPDATE                :: 0x00000001
INIT_MIX_FROM_UPDATE                   :: 0x00000002
INIT_3D_RIGHTHANDED                    :: 0x00000004
INIT_CLIP_OUTPUT                       :: 0x00000008
INIT_CHANNEL_LOWPASS                   :: 0x00000100
INIT_CHANNEL_DISTANCEFILTER            :: 0x00000200
INIT_PROFILE_ENABLE                    :: 0x00010000
INIT_VOL0_BECOMES_VIRTUAL              :: 0x00020000
INIT_GEOMETRY_USECLOSEST               :: 0x00040000
INIT_PREFER_DOLBY_DOWNMIX              :: 0x00080000
INIT_THREAD_UNSAFE                     :: 0x00100000
INIT_PROFILE_METER_ALL                 :: 0x00200000
INIT_MEMORY_TRACKING                   :: 0x00400000

// debug flags
DEBUG_LEVEL_NONE                       :: 0x00000000
DEBUG_LEVEL_ERROR                      :: 0x00000001
DEBUG_LEVEL_WARNING                    :: 0x00000002
DEBUG_LEVEL_LOG                        :: 0x00000004
DEBUG_TYPE_MEMORY                      :: 0x00000100
DEBUG_TYPE_FILE                        :: 0x00000200
DEBUG_TYPE_CODEC                       :: 0x00000400
DEBUG_TYPE_TRACE                       :: 0x00000800
DEBUG_DISPLAY_TIMESTAMPS               :: 0x00010000
DEBUG_DISPLAY_LINENUMBERS              :: 0x00020000
DEBUG_DISPLAY_THREAD                   :: 0x00040000

// system callback type
SYSTEM_CALLBACK_DEVICELISTCHANGED      :: 0x00000001
SYSTEM_CALLBACK_DEVICELOST             :: 0x00000002
SYSTEM_CALLBACK_MEMORYALLOCATIONFAILED :: 0x00000004
SYSTEM_CALLBACK_THREADCREATED          :: 0x00000008
SYSTEM_CALLBACK_BADDSPCONNECTION       :: 0x00000010
SYSTEM_CALLBACK_PREMIX                 :: 0x00000020
SYSTEM_CALLBACK_POSTMIX                :: 0x00000040
SYSTEM_CALLBACK_ERROR                  :: 0x00000080
SYSTEM_CALLBACK_MIDMIX                 :: 0x00000100
SYSTEM_CALLBACK_THREADDESTROYED        :: 0x00000200
SYSTEM_CALLBACK_PREUPDATE              :: 0x00000400
SYSTEM_CALLBACK_POSTUPDATE             :: 0x00000800
SYSTEM_CALLBACK_RECORDLISTCHANGED      :: 0x00001000
SYSTEM_CALLBACK_BUFFEREDNOMIX          :: 0x00002000
SYSTEM_CALLBACK_DEVICEREINITIALIZE     :: 0x00004000
SYSTEM_CALLBACK_OUTPUTUNDERRUN         :: 0x00008000
SYSTEM_CALLBACK_RECORDPOSITIONCHANGED  :: 0x00010000
SYSTEM_CALLBACK_ALL                    :: 0xFFFFFFFF

// time unit
TIMEUNIT_MS                            :: 0x00000001
TIMEUNIT_PCM                           :: 0x00000002
TIMEUNIT_PCMBYTES                      :: 0x00000004
TIMEUNIT_RAWBYTES                      :: 0x00000008
TIMEUNIT_PCMFRACTION                   :: 0x00000010
TIMEUNIT_MODORDER                      :: 0x00000100
TIMEUNIT_MODROW                        :: 0x00000200
TIMEUNIT_MODPATTERN                    :: 0x00000400

// memory type
MEMORY_NORMAL                          :: 0x00000000
MEMORY_STREAM_FILE                     :: 0x00000001
MEMORY_STREAM_DECODE                   :: 0x00000002
MEMORY_SAMPLEDATA                      :: 0x00000004
MEMORY_DSP_BUFFER                      :: 0x00000008
MEMORY_PLUGIN                          :: 0x00000010
MEMORY_PERSISTENT                      :: 0x00200000
MEMORY_ALL                             :: 0xFFFFFFFF

// mode
DEFAULT                                :: 0x00000000
LOOP_OFF                               :: 0x00000001
LOOP_NORMAL                            :: 0x00000002
LOOP_BIDI                              :: 0x00000004
FMOD_2D                                :: 0x00000008
FMOD_3D                                :: 0x00000010
CREATESTREAM                           :: 0x00000080
CREATESAMPLE                           :: 0x00000100
CREATECOMPRESSEDSAMPLE                 :: 0x00000200
OPENUSER                               :: 0x00000400
OPENMEMORY                             :: 0x00000800
OPENMEMORY_POINT                       :: 0x10000000
OPENRAW                                :: 0x00001000
OPENONLY                               :: 0x00002000
ACCURATETIME                           :: 0x00004000
MPEGSEARCH                             :: 0x00008000
NONBLOCKING                            :: 0x00010000
UNIQUE                                 :: 0x00020000
FMOD_3D_HEADRELATIVE                   :: 0x00040000
FMOD_3D_WORLDRELATIVE                  :: 0x00080000
FMOD_3D_INVERSEROLLOFF                 :: 0x00100000
FMOD_3D_LINEARROLLOFF                  :: 0x00200000
FMOD_3D_LINEARSQUAREROLLOFF            :: 0x00400000
FMOD_3D_INVERSETAPEREDROLLOFF          :: 0x00800000
FMOD_3D_CUSTOMROLLOFF                  :: 0x04000000
FMOD_3D_IGNOREGEOMETRY                 :: 0x40000000
IGNORETAGS                             :: 0x02000000
LOWMEM                                 :: 0x08000000
VIRTUAL_PLAYFROMSTART                  :: 0x80000000
