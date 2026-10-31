option casemap:none
.data
extern p_CloseDriver:QWORD
extern p_DefDriverProc:QWORD
extern p_DriverCallback:QWORD
extern p_DrvGetModuleHandle:QWORD
extern p_GetDriverModuleHandle:QWORD
extern p_OpenDriver:QWORD
extern p_PlaySound:QWORD
extern p_PlaySoundA:QWORD
extern p_PlaySoundW:QWORD
extern p_SendDriverMessage:QWORD
extern p_WOWAppExit:QWORD
extern p_auxGetDevCapsA:QWORD
extern p_auxGetDevCapsW:QWORD
extern p_auxGetNumDevs:QWORD
extern p_auxGetVolume:QWORD
extern p_auxOutMessage:QWORD
extern p_auxSetVolume:QWORD
extern p_joyConfigChanged:QWORD
extern p_joyGetDevCapsA:QWORD
extern p_joyGetDevCapsW:QWORD
extern p_joyGetNumDevs:QWORD
extern p_joyGetPos:QWORD
extern p_joyGetPosEx:QWORD
extern p_joyGetThreshold:QWORD
extern p_joyReleaseCapture:QWORD
extern p_joySetCapture:QWORD
extern p_joySetThreshold:QWORD
extern p_mciDriverNotify:QWORD
extern p_mciDriverYield:QWORD
extern p_mciExecute:QWORD
extern p_mciFreeCommandResource:QWORD
extern p_mciGetCreatorTask:QWORD
extern p_mciGetDeviceIDA:QWORD
extern p_mciGetDeviceIDFromElementIDA:QWORD
extern p_mciGetDeviceIDFromElementIDW:QWORD
extern p_mciGetDeviceIDW:QWORD
extern p_mciGetDriverData:QWORD
extern p_mciGetErrorStringA:QWORD
extern p_mciGetErrorStringW:QWORD
extern p_mciGetYieldProc:QWORD
extern p_mciLoadCommandResource:QWORD
extern p_mciSendCommandA:QWORD
extern p_mciSendCommandW:QWORD
extern p_mciSendStringA:QWORD
extern p_mciSendStringW:QWORD
extern p_mciSetDriverData:QWORD
extern p_mciSetYieldProc:QWORD
extern p_midiConnect:QWORD
extern p_midiDisconnect:QWORD
extern p_midiInAddBuffer:QWORD
extern p_midiInClose:QWORD
extern p_midiInGetDevCapsA:QWORD
extern p_midiInGetDevCapsW:QWORD
extern p_midiInGetErrorTextA:QWORD
extern p_midiInGetErrorTextW:QWORD
extern p_midiInGetID:QWORD
extern p_midiInGetNumDevs:QWORD
extern p_midiInMessage:QWORD
extern p_midiInOpen:QWORD
extern p_midiInPrepareHeader:QWORD
extern p_midiInReset:QWORD
extern p_midiInStart:QWORD
extern p_midiInStop:QWORD
extern p_midiInUnprepareHeader:QWORD
extern p_midiOutCacheDrumPatches:QWORD
extern p_midiOutCachePatches:QWORD
extern p_midiOutClose:QWORD
extern p_midiOutGetDevCapsA:QWORD
extern p_midiOutGetDevCapsW:QWORD
extern p_midiOutGetErrorTextA:QWORD
extern p_midiOutGetErrorTextW:QWORD
extern p_midiOutGetID:QWORD
extern p_midiOutGetNumDevs:QWORD
extern p_midiOutGetVolume:QWORD
extern p_midiOutLongMsg:QWORD
extern p_midiOutMessage:QWORD
extern p_midiOutOpen:QWORD
extern p_midiOutPrepareHeader:QWORD
extern p_midiOutReset:QWORD
extern p_midiOutSetVolume:QWORD
extern p_midiOutShortMsg:QWORD
extern p_midiOutUnprepareHeader:QWORD
extern p_midiStreamClose:QWORD
extern p_midiStreamOpen:QWORD
extern p_midiStreamOut:QWORD
extern p_midiStreamPause:QWORD
extern p_midiStreamPosition:QWORD
extern p_midiStreamProperty:QWORD
extern p_midiStreamRestart:QWORD
extern p_midiStreamStop:QWORD
extern p_mixerClose:QWORD
extern p_mixerGetControlDetailsA:QWORD
extern p_mixerGetControlDetailsW:QWORD
extern p_mixerGetDevCapsA:QWORD
extern p_mixerGetDevCapsW:QWORD
extern p_mixerGetID:QWORD
extern p_mixerGetLineControlsA:QWORD
extern p_mixerGetLineControlsW:QWORD
extern p_mixerGetLineInfoA:QWORD
extern p_mixerGetLineInfoW:QWORD
extern p_mixerGetNumDevs:QWORD
extern p_mixerMessage:QWORD
extern p_mixerOpen:QWORD
extern p_mixerSetControlDetails:QWORD
extern p_mmDrvInstall:QWORD
extern p_mmGetCurrentTask:QWORD
extern p_mmTaskBlock:QWORD
extern p_mmTaskCreate:QWORD
extern p_mmTaskSignal:QWORD
extern p_mmTaskYield:QWORD
extern p_mmioAdvance:QWORD
extern p_mmioAscend:QWORD
extern p_mmioClose:QWORD
extern p_mmioCreateChunk:QWORD
extern p_mmioDescend:QWORD
extern p_mmioFlush:QWORD
extern p_mmioGetInfo:QWORD
extern p_mmioInstallIOProcA:QWORD
extern p_mmioInstallIOProcW:QWORD
extern p_mmioOpenA:QWORD
extern p_mmioOpenW:QWORD
extern p_mmioRead:QWORD
extern p_mmioRenameA:QWORD
extern p_mmioRenameW:QWORD
extern p_mmioSeek:QWORD
extern p_mmioSendMessage:QWORD
extern p_mmioSetBuffer:QWORD
extern p_mmioSetInfo:QWORD
extern p_mmioStringToFOURCCA:QWORD
extern p_mmioStringToFOURCCW:QWORD
extern p_mmioWrite:QWORD
extern p_mmsystemGetVersion:QWORD
extern p_sndPlaySoundA:QWORD
extern p_sndPlaySoundW:QWORD
extern p_timeBeginPeriod:QWORD
extern p_timeEndPeriod:QWORD
extern p_timeGetDevCaps:QWORD
extern p_timeGetSystemTime:QWORD
extern p_timeGetTime:QWORD
extern p_timeKillEvent:QWORD
extern p_timeSetEvent:QWORD
extern p_waveInAddBuffer:QWORD
extern p_waveInClose:QWORD
extern p_waveInGetDevCapsA:QWORD
extern p_waveInGetDevCapsW:QWORD
extern p_waveInGetErrorTextA:QWORD
extern p_waveInGetErrorTextW:QWORD
extern p_waveInGetID:QWORD
extern p_waveInGetNumDevs:QWORD
extern p_waveInGetPosition:QWORD
extern p_waveInMessage:QWORD
extern p_waveInOpen:QWORD
extern p_waveInPrepareHeader:QWORD
extern p_waveInReset:QWORD
extern p_waveInStart:QWORD
extern p_waveInStop:QWORD
extern p_waveInUnprepareHeader:QWORD
extern p_waveOutBreakLoop:QWORD
extern p_waveOutClose:QWORD
extern p_waveOutGetDevCapsA:QWORD
extern p_waveOutGetDevCapsW:QWORD
extern p_waveOutGetErrorTextA:QWORD
extern p_waveOutGetErrorTextW:QWORD
extern p_waveOutGetID:QWORD
extern p_waveOutGetNumDevs:QWORD
extern p_waveOutGetPitch:QWORD
extern p_waveOutGetPlaybackRate:QWORD
extern p_waveOutGetPosition:QWORD
extern p_waveOutGetVolume:QWORD
extern p_waveOutMessage:QWORD
extern p_waveOutOpen:QWORD
extern p_waveOutPause:QWORD
extern p_waveOutPrepareHeader:QWORD
extern p_waveOutReset:QWORD
extern p_waveOutRestart:QWORD
extern p_waveOutSetPitch:QWORD
extern p_waveOutSetPlaybackRate:QWORD
extern p_waveOutSetVolume:QWORD
extern p_waveOutUnprepareHeader:QWORD
extern p_waveOutWrite:QWORD

.code
CloseDriver PROC PUBLIC
    jmp QWORD PTR [p_CloseDriver]
CloseDriver ENDP
DefDriverProc PROC PUBLIC
    jmp QWORD PTR [p_DefDriverProc]
DefDriverProc ENDP
DriverCallback PROC PUBLIC
    jmp QWORD PTR [p_DriverCallback]
DriverCallback ENDP
DrvGetModuleHandle PROC PUBLIC
    jmp QWORD PTR [p_DrvGetModuleHandle]
DrvGetModuleHandle ENDP
GetDriverModuleHandle PROC PUBLIC
    jmp QWORD PTR [p_GetDriverModuleHandle]
GetDriverModuleHandle ENDP
OpenDriver PROC PUBLIC
    jmp QWORD PTR [p_OpenDriver]
OpenDriver ENDP
PlaySound PROC PUBLIC
    jmp QWORD PTR [p_PlaySound]
PlaySound ENDP
PlaySoundA PROC PUBLIC
    jmp QWORD PTR [p_PlaySoundA]
PlaySoundA ENDP
PlaySoundW PROC PUBLIC
    jmp QWORD PTR [p_PlaySoundW]
PlaySoundW ENDP
SendDriverMessage PROC PUBLIC
    jmp QWORD PTR [p_SendDriverMessage]
SendDriverMessage ENDP
WOWAppExit PROC PUBLIC
    jmp QWORD PTR [p_WOWAppExit]
WOWAppExit ENDP
auxGetDevCapsA PROC PUBLIC
    jmp QWORD PTR [p_auxGetDevCapsA]
auxGetDevCapsA ENDP
auxGetDevCapsW PROC PUBLIC
    jmp QWORD PTR [p_auxGetDevCapsW]
auxGetDevCapsW ENDP
auxGetNumDevs PROC PUBLIC
    jmp QWORD PTR [p_auxGetNumDevs]
auxGetNumDevs ENDP
auxGetVolume PROC PUBLIC
    jmp QWORD PTR [p_auxGetVolume]
auxGetVolume ENDP
auxOutMessage PROC PUBLIC
    jmp QWORD PTR [p_auxOutMessage]
auxOutMessage ENDP
auxSetVolume PROC PUBLIC
    jmp QWORD PTR [p_auxSetVolume]
auxSetVolume ENDP
joyConfigChanged PROC PUBLIC
    jmp QWORD PTR [p_joyConfigChanged]
joyConfigChanged ENDP
joyGetDevCapsA PROC PUBLIC
    jmp QWORD PTR [p_joyGetDevCapsA]
joyGetDevCapsA ENDP
joyGetDevCapsW PROC PUBLIC
    jmp QWORD PTR [p_joyGetDevCapsW]
joyGetDevCapsW ENDP
joyGetNumDevs PROC PUBLIC
    jmp QWORD PTR [p_joyGetNumDevs]
joyGetNumDevs ENDP
joyGetPos PROC PUBLIC
    jmp QWORD PTR [p_joyGetPos]
joyGetPos ENDP
joyGetPosEx PROC PUBLIC
    jmp QWORD PTR [p_joyGetPosEx]
joyGetPosEx ENDP
joyGetThreshold PROC PUBLIC
    jmp QWORD PTR [p_joyGetThreshold]
joyGetThreshold ENDP
joyReleaseCapture PROC PUBLIC
    jmp QWORD PTR [p_joyReleaseCapture]
joyReleaseCapture ENDP
joySetCapture PROC PUBLIC
    jmp QWORD PTR [p_joySetCapture]
joySetCapture ENDP
joySetThreshold PROC PUBLIC
    jmp QWORD PTR [p_joySetThreshold]
joySetThreshold ENDP
mciDriverNotify PROC PUBLIC
    jmp QWORD PTR [p_mciDriverNotify]
mciDriverNotify ENDP
mciDriverYield PROC PUBLIC
    jmp QWORD PTR [p_mciDriverYield]
mciDriverYield ENDP
mciExecute PROC PUBLIC
    jmp QWORD PTR [p_mciExecute]
mciExecute ENDP
mciFreeCommandResource PROC PUBLIC
    jmp QWORD PTR [p_mciFreeCommandResource]
mciFreeCommandResource ENDP
mciGetCreatorTask PROC PUBLIC
    jmp QWORD PTR [p_mciGetCreatorTask]
mciGetCreatorTask ENDP
mciGetDeviceIDA PROC PUBLIC
    jmp QWORD PTR [p_mciGetDeviceIDA]
mciGetDeviceIDA ENDP
mciGetDeviceIDFromElementIDA PROC PUBLIC
    jmp QWORD PTR [p_mciGetDeviceIDFromElementIDA]
mciGetDeviceIDFromElementIDA ENDP
mciGetDeviceIDFromElementIDW PROC PUBLIC
    jmp QWORD PTR [p_mciGetDeviceIDFromElementIDW]
mciGetDeviceIDFromElementIDW ENDP
mciGetDeviceIDW PROC PUBLIC
    jmp QWORD PTR [p_mciGetDeviceIDW]
mciGetDeviceIDW ENDP
mciGetDriverData PROC PUBLIC
    jmp QWORD PTR [p_mciGetDriverData]
mciGetDriverData ENDP
mciGetErrorStringA PROC PUBLIC
    jmp QWORD PTR [p_mciGetErrorStringA]
mciGetErrorStringA ENDP
mciGetErrorStringW PROC PUBLIC
    jmp QWORD PTR [p_mciGetErrorStringW]
mciGetErrorStringW ENDP
mciGetYieldProc PROC PUBLIC
    jmp QWORD PTR [p_mciGetYieldProc]
mciGetYieldProc ENDP
mciLoadCommandResource PROC PUBLIC
    jmp QWORD PTR [p_mciLoadCommandResource]
mciLoadCommandResource ENDP
mciSendCommandA PROC PUBLIC
    jmp QWORD PTR [p_mciSendCommandA]
mciSendCommandA ENDP
mciSendCommandW PROC PUBLIC
    jmp QWORD PTR [p_mciSendCommandW]
mciSendCommandW ENDP
mciSendStringA PROC PUBLIC
    jmp QWORD PTR [p_mciSendStringA]
mciSendStringA ENDP
mciSendStringW PROC PUBLIC
    jmp QWORD PTR [p_mciSendStringW]
mciSendStringW ENDP
mciSetDriverData PROC PUBLIC
    jmp QWORD PTR [p_mciSetDriverData]
mciSetDriverData ENDP
mciSetYieldProc PROC PUBLIC
    jmp QWORD PTR [p_mciSetYieldProc]
mciSetYieldProc ENDP
midiConnect PROC PUBLIC
    jmp QWORD PTR [p_midiConnect]
midiConnect ENDP
midiDisconnect PROC PUBLIC
    jmp QWORD PTR [p_midiDisconnect]
midiDisconnect ENDP
midiInAddBuffer PROC PUBLIC
    jmp QWORD PTR [p_midiInAddBuffer]
midiInAddBuffer ENDP
midiInClose PROC PUBLIC
    jmp QWORD PTR [p_midiInClose]
midiInClose ENDP
midiInGetDevCapsA PROC PUBLIC
    jmp QWORD PTR [p_midiInGetDevCapsA]
midiInGetDevCapsA ENDP
midiInGetDevCapsW PROC PUBLIC
    jmp QWORD PTR [p_midiInGetDevCapsW]
midiInGetDevCapsW ENDP
midiInGetErrorTextA PROC PUBLIC
    jmp QWORD PTR [p_midiInGetErrorTextA]
midiInGetErrorTextA ENDP
midiInGetErrorTextW PROC PUBLIC
    jmp QWORD PTR [p_midiInGetErrorTextW]
midiInGetErrorTextW ENDP
midiInGetID PROC PUBLIC
    jmp QWORD PTR [p_midiInGetID]
midiInGetID ENDP
midiInGetNumDevs PROC PUBLIC
    jmp QWORD PTR [p_midiInGetNumDevs]
midiInGetNumDevs ENDP
midiInMessage PROC PUBLIC
    jmp QWORD PTR [p_midiInMessage]
midiInMessage ENDP
midiInOpen PROC PUBLIC
    jmp QWORD PTR [p_midiInOpen]
midiInOpen ENDP
midiInPrepareHeader PROC PUBLIC
    jmp QWORD PTR [p_midiInPrepareHeader]
midiInPrepareHeader ENDP
midiInReset PROC PUBLIC
    jmp QWORD PTR [p_midiInReset]
midiInReset ENDP
midiInStart PROC PUBLIC
    jmp QWORD PTR [p_midiInStart]
midiInStart ENDP
midiInStop PROC PUBLIC
    jmp QWORD PTR [p_midiInStop]
midiInStop ENDP
midiInUnprepareHeader PROC PUBLIC
    jmp QWORD PTR [p_midiInUnprepareHeader]
midiInUnprepareHeader ENDP
midiOutCacheDrumPatches PROC PUBLIC
    jmp QWORD PTR [p_midiOutCacheDrumPatches]
midiOutCacheDrumPatches ENDP
midiOutCachePatches PROC PUBLIC
    jmp QWORD PTR [p_midiOutCachePatches]
midiOutCachePatches ENDP
midiOutClose PROC PUBLIC
    jmp QWORD PTR [p_midiOutClose]
midiOutClose ENDP
midiOutGetDevCapsA PROC PUBLIC
    jmp QWORD PTR [p_midiOutGetDevCapsA]
midiOutGetDevCapsA ENDP
midiOutGetDevCapsW PROC PUBLIC
    jmp QWORD PTR [p_midiOutGetDevCapsW]
midiOutGetDevCapsW ENDP
midiOutGetErrorTextA PROC PUBLIC
    jmp QWORD PTR [p_midiOutGetErrorTextA]
midiOutGetErrorTextA ENDP
midiOutGetErrorTextW PROC PUBLIC
    jmp QWORD PTR [p_midiOutGetErrorTextW]
midiOutGetErrorTextW ENDP
midiOutGetID PROC PUBLIC
    jmp QWORD PTR [p_midiOutGetID]
midiOutGetID ENDP
midiOutGetNumDevs PROC PUBLIC
    jmp QWORD PTR [p_midiOutGetNumDevs]
midiOutGetNumDevs ENDP
midiOutGetVolume PROC PUBLIC
    jmp QWORD PTR [p_midiOutGetVolume]
midiOutGetVolume ENDP
midiOutLongMsg PROC PUBLIC
    jmp QWORD PTR [p_midiOutLongMsg]
midiOutLongMsg ENDP
midiOutMessage PROC PUBLIC
    jmp QWORD PTR [p_midiOutMessage]
midiOutMessage ENDP
midiOutOpen PROC PUBLIC
    jmp QWORD PTR [p_midiOutOpen]
midiOutOpen ENDP
midiOutPrepareHeader PROC PUBLIC
    jmp QWORD PTR [p_midiOutPrepareHeader]
midiOutPrepareHeader ENDP
midiOutReset PROC PUBLIC
    jmp QWORD PTR [p_midiOutReset]
midiOutReset ENDP
midiOutSetVolume PROC PUBLIC
    jmp QWORD PTR [p_midiOutSetVolume]
midiOutSetVolume ENDP
midiOutShortMsg PROC PUBLIC
    jmp QWORD PTR [p_midiOutShortMsg]
midiOutShortMsg ENDP
midiOutUnprepareHeader PROC PUBLIC
    jmp QWORD PTR [p_midiOutUnprepareHeader]
midiOutUnprepareHeader ENDP
midiStreamClose PROC PUBLIC
    jmp QWORD PTR [p_midiStreamClose]
midiStreamClose ENDP
midiStreamOpen PROC PUBLIC
    jmp QWORD PTR [p_midiStreamOpen]
midiStreamOpen ENDP
midiStreamOut PROC PUBLIC
    jmp QWORD PTR [p_midiStreamOut]
midiStreamOut ENDP
midiStreamPause PROC PUBLIC
    jmp QWORD PTR [p_midiStreamPause]
midiStreamPause ENDP
midiStreamPosition PROC PUBLIC
    jmp QWORD PTR [p_midiStreamPosition]
midiStreamPosition ENDP
midiStreamProperty PROC PUBLIC
    jmp QWORD PTR [p_midiStreamProperty]
midiStreamProperty ENDP
midiStreamRestart PROC PUBLIC
    jmp QWORD PTR [p_midiStreamRestart]
midiStreamRestart ENDP
midiStreamStop PROC PUBLIC
    jmp QWORD PTR [p_midiStreamStop]
midiStreamStop ENDP
mixerClose PROC PUBLIC
    jmp QWORD PTR [p_mixerClose]
mixerClose ENDP
mixerGetControlDetailsA PROC PUBLIC
    jmp QWORD PTR [p_mixerGetControlDetailsA]
mixerGetControlDetailsA ENDP
mixerGetControlDetailsW PROC PUBLIC
    jmp QWORD PTR [p_mixerGetControlDetailsW]
mixerGetControlDetailsW ENDP
mixerGetDevCapsA PROC PUBLIC
    jmp QWORD PTR [p_mixerGetDevCapsA]
mixerGetDevCapsA ENDP
mixerGetDevCapsW PROC PUBLIC
    jmp QWORD PTR [p_mixerGetDevCapsW]
mixerGetDevCapsW ENDP
mixerGetID PROC PUBLIC
    jmp QWORD PTR [p_mixerGetID]
mixerGetID ENDP
mixerGetLineControlsA PROC PUBLIC
    jmp QWORD PTR [p_mixerGetLineControlsA]
mixerGetLineControlsA ENDP
mixerGetLineControlsW PROC PUBLIC
    jmp QWORD PTR [p_mixerGetLineControlsW]
mixerGetLineControlsW ENDP
mixerGetLineInfoA PROC PUBLIC
    jmp QWORD PTR [p_mixerGetLineInfoA]
mixerGetLineInfoA ENDP
mixerGetLineInfoW PROC PUBLIC
    jmp QWORD PTR [p_mixerGetLineInfoW]
mixerGetLineInfoW ENDP
mixerGetNumDevs PROC PUBLIC
    jmp QWORD PTR [p_mixerGetNumDevs]
mixerGetNumDevs ENDP
mixerMessage PROC PUBLIC
    jmp QWORD PTR [p_mixerMessage]
mixerMessage ENDP
mixerOpen PROC PUBLIC
    jmp QWORD PTR [p_mixerOpen]
mixerOpen ENDP
mixerSetControlDetails PROC PUBLIC
    jmp QWORD PTR [p_mixerSetControlDetails]
mixerSetControlDetails ENDP
mmDrvInstall PROC PUBLIC
    jmp QWORD PTR [p_mmDrvInstall]
mmDrvInstall ENDP
mmGetCurrentTask PROC PUBLIC
    jmp QWORD PTR [p_mmGetCurrentTask]
mmGetCurrentTask ENDP
mmTaskBlock PROC PUBLIC
    jmp QWORD PTR [p_mmTaskBlock]
mmTaskBlock ENDP
mmTaskCreate PROC PUBLIC
    jmp QWORD PTR [p_mmTaskCreate]
mmTaskCreate ENDP
mmTaskSignal PROC PUBLIC
    jmp QWORD PTR [p_mmTaskSignal]
mmTaskSignal ENDP
mmTaskYield PROC PUBLIC
    jmp QWORD PTR [p_mmTaskYield]
mmTaskYield ENDP
mmioAdvance PROC PUBLIC
    jmp QWORD PTR [p_mmioAdvance]
mmioAdvance ENDP
mmioAscend PROC PUBLIC
    jmp QWORD PTR [p_mmioAscend]
mmioAscend ENDP
mmioClose PROC PUBLIC
    jmp QWORD PTR [p_mmioClose]
mmioClose ENDP
mmioCreateChunk PROC PUBLIC
    jmp QWORD PTR [p_mmioCreateChunk]
mmioCreateChunk ENDP
mmioDescend PROC PUBLIC
    jmp QWORD PTR [p_mmioDescend]
mmioDescend ENDP
mmioFlush PROC PUBLIC
    jmp QWORD PTR [p_mmioFlush]
mmioFlush ENDP
mmioGetInfo PROC PUBLIC
    jmp QWORD PTR [p_mmioGetInfo]
mmioGetInfo ENDP
mmioInstallIOProcA PROC PUBLIC
    jmp QWORD PTR [p_mmioInstallIOProcA]
mmioInstallIOProcA ENDP
mmioInstallIOProcW PROC PUBLIC
    jmp QWORD PTR [p_mmioInstallIOProcW]
mmioInstallIOProcW ENDP
mmioOpenA PROC PUBLIC
    jmp QWORD PTR [p_mmioOpenA]
mmioOpenA ENDP
mmioOpenW PROC PUBLIC
    jmp QWORD PTR [p_mmioOpenW]
mmioOpenW ENDP
mmioRead PROC PUBLIC
    jmp QWORD PTR [p_mmioRead]
mmioRead ENDP
mmioRenameA PROC PUBLIC
    jmp QWORD PTR [p_mmioRenameA]
mmioRenameA ENDP
mmioRenameW PROC PUBLIC
    jmp QWORD PTR [p_mmioRenameW]
mmioRenameW ENDP
mmioSeek PROC PUBLIC
    jmp QWORD PTR [p_mmioSeek]
mmioSeek ENDP
mmioSendMessage PROC PUBLIC
    jmp QWORD PTR [p_mmioSendMessage]
mmioSendMessage ENDP
mmioSetBuffer PROC PUBLIC
    jmp QWORD PTR [p_mmioSetBuffer]
mmioSetBuffer ENDP
mmioSetInfo PROC PUBLIC
    jmp QWORD PTR [p_mmioSetInfo]
mmioSetInfo ENDP
mmioStringToFOURCCA PROC PUBLIC
    jmp QWORD PTR [p_mmioStringToFOURCCA]
mmioStringToFOURCCA ENDP
mmioStringToFOURCCW PROC PUBLIC
    jmp QWORD PTR [p_mmioStringToFOURCCW]
mmioStringToFOURCCW ENDP
mmioWrite PROC PUBLIC
    jmp QWORD PTR [p_mmioWrite]
mmioWrite ENDP
mmsystemGetVersion PROC PUBLIC
    jmp QWORD PTR [p_mmsystemGetVersion]
mmsystemGetVersion ENDP
sndPlaySoundA PROC PUBLIC
    jmp QWORD PTR [p_sndPlaySoundA]
sndPlaySoundA ENDP
sndPlaySoundW PROC PUBLIC
    jmp QWORD PTR [p_sndPlaySoundW]
sndPlaySoundW ENDP
timeBeginPeriod PROC PUBLIC
    jmp QWORD PTR [p_timeBeginPeriod]
timeBeginPeriod ENDP
timeEndPeriod PROC PUBLIC
    jmp QWORD PTR [p_timeEndPeriod]
timeEndPeriod ENDP
timeGetDevCaps PROC PUBLIC
    jmp QWORD PTR [p_timeGetDevCaps]
timeGetDevCaps ENDP
timeGetSystemTime PROC PUBLIC
    jmp QWORD PTR [p_timeGetSystemTime]
timeGetSystemTime ENDP
timeGetTime PROC PUBLIC
    jmp QWORD PTR [p_timeGetTime]
timeGetTime ENDP
timeKillEvent PROC PUBLIC
    jmp QWORD PTR [p_timeKillEvent]
timeKillEvent ENDP
timeSetEvent PROC PUBLIC
    jmp QWORD PTR [p_timeSetEvent]
timeSetEvent ENDP
waveInAddBuffer PROC PUBLIC
    jmp QWORD PTR [p_waveInAddBuffer]
waveInAddBuffer ENDP
waveInClose PROC PUBLIC
    jmp QWORD PTR [p_waveInClose]
waveInClose ENDP
waveInGetDevCapsA PROC PUBLIC
    jmp QWORD PTR [p_waveInGetDevCapsA]
waveInGetDevCapsA ENDP
waveInGetDevCapsW PROC PUBLIC
    jmp QWORD PTR [p_waveInGetDevCapsW]
waveInGetDevCapsW ENDP
waveInGetErrorTextA PROC PUBLIC
    jmp QWORD PTR [p_waveInGetErrorTextA]
waveInGetErrorTextA ENDP
waveInGetErrorTextW PROC PUBLIC
    jmp QWORD PTR [p_waveInGetErrorTextW]
waveInGetErrorTextW ENDP
waveInGetID PROC PUBLIC
    jmp QWORD PTR [p_waveInGetID]
waveInGetID ENDP
waveInGetNumDevs PROC PUBLIC
    jmp QWORD PTR [p_waveInGetNumDevs]
waveInGetNumDevs ENDP
waveInGetPosition PROC PUBLIC
    jmp QWORD PTR [p_waveInGetPosition]
waveInGetPosition ENDP
waveInMessage PROC PUBLIC
    jmp QWORD PTR [p_waveInMessage]
waveInMessage ENDP
waveInOpen PROC PUBLIC
    jmp QWORD PTR [p_waveInOpen]
waveInOpen ENDP
waveInPrepareHeader PROC PUBLIC
    jmp QWORD PTR [p_waveInPrepareHeader]
waveInPrepareHeader ENDP
waveInReset PROC PUBLIC
    jmp QWORD PTR [p_waveInReset]
waveInReset ENDP
waveInStart PROC PUBLIC
    jmp QWORD PTR [p_waveInStart]
waveInStart ENDP
waveInStop PROC PUBLIC
    jmp QWORD PTR [p_waveInStop]
waveInStop ENDP
waveInUnprepareHeader PROC PUBLIC
    jmp QWORD PTR [p_waveInUnprepareHeader]
waveInUnprepareHeader ENDP
waveOutBreakLoop PROC PUBLIC
    jmp QWORD PTR [p_waveOutBreakLoop]
waveOutBreakLoop ENDP
waveOutClose PROC PUBLIC
    jmp QWORD PTR [p_waveOutClose]
waveOutClose ENDP
waveOutGetDevCapsA PROC PUBLIC
    jmp QWORD PTR [p_waveOutGetDevCapsA]
waveOutGetDevCapsA ENDP
waveOutGetDevCapsW PROC PUBLIC
    jmp QWORD PTR [p_waveOutGetDevCapsW]
waveOutGetDevCapsW ENDP
waveOutGetErrorTextA PROC PUBLIC
    jmp QWORD PTR [p_waveOutGetErrorTextA]
waveOutGetErrorTextA ENDP
waveOutGetErrorTextW PROC PUBLIC
    jmp QWORD PTR [p_waveOutGetErrorTextW]
waveOutGetErrorTextW ENDP
waveOutGetID PROC PUBLIC
    jmp QWORD PTR [p_waveOutGetID]
waveOutGetID ENDP
waveOutGetNumDevs PROC PUBLIC
    jmp QWORD PTR [p_waveOutGetNumDevs]
waveOutGetNumDevs ENDP
waveOutGetPitch PROC PUBLIC
    jmp QWORD PTR [p_waveOutGetPitch]
waveOutGetPitch ENDP
waveOutGetPlaybackRate PROC PUBLIC
    jmp QWORD PTR [p_waveOutGetPlaybackRate]
waveOutGetPlaybackRate ENDP
waveOutGetPosition PROC PUBLIC
    jmp QWORD PTR [p_waveOutGetPosition]
waveOutGetPosition ENDP
waveOutGetVolume PROC PUBLIC
    jmp QWORD PTR [p_waveOutGetVolume]
waveOutGetVolume ENDP
waveOutMessage PROC PUBLIC
    jmp QWORD PTR [p_waveOutMessage]
waveOutMessage ENDP
waveOutOpen PROC PUBLIC
    jmp QWORD PTR [p_waveOutOpen]
waveOutOpen ENDP
waveOutPause PROC PUBLIC
    jmp QWORD PTR [p_waveOutPause]
waveOutPause ENDP
waveOutPrepareHeader PROC PUBLIC
    jmp QWORD PTR [p_waveOutPrepareHeader]
waveOutPrepareHeader ENDP
waveOutReset PROC PUBLIC
    jmp QWORD PTR [p_waveOutReset]
waveOutReset ENDP
waveOutRestart PROC PUBLIC
    jmp QWORD PTR [p_waveOutRestart]
waveOutRestart ENDP
waveOutSetPitch PROC PUBLIC
    jmp QWORD PTR [p_waveOutSetPitch]
waveOutSetPitch ENDP
waveOutSetPlaybackRate PROC PUBLIC
    jmp QWORD PTR [p_waveOutSetPlaybackRate]
waveOutSetPlaybackRate ENDP
waveOutSetVolume PROC PUBLIC
    jmp QWORD PTR [p_waveOutSetVolume]
waveOutSetVolume ENDP
waveOutUnprepareHeader PROC PUBLIC
    jmp QWORD PTR [p_waveOutUnprepareHeader]
waveOutUnprepareHeader ENDP
waveOutWrite PROC PUBLIC
    jmp QWORD PTR [p_waveOutWrite]
waveOutWrite ENDP

END
