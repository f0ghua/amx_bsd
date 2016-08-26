PROGRAM_NAME='MXT Residential Demo,08-02-2012'
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $

    IPADDRESS:  10.0.12.21 ~ 10.0.12.29/255.255.255.0/10.0.12.254

    AMX NX3200: 10.0.12.21

    pptPlayer PC(PC1[bottom] ~ PC4[top]): 10.0.12.22 ~ 10.0.12.25
    The autostart function add in task schedule program
    PC volume set to 10

    Symetrix Jupiter 8: 10.0.12.26

    IPAD:
        appleID:    baoshide2016@icloud.com/Ba0shide
        tpcontrol:  TPC-6-AZDX-VWCD

    IPHONE6:
        appleID:    positec20161@icloud.com/Ba0shide
        tpcontrol:  TPC-0-JONK-KFJZ

    IPHONE6:
        appleID:    positec20162@icloud.com/Ba0shide
        tpcontrol:  TPC-0-XCBF-BILK
*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

// Channel 0001~0100    - MENU FEEDBACK
// Channel 0101~0400    - LIGHT FEEDBACK
// Channel 0401~0500    - AUDIO FEEDBACK
// Channel 1201~1400    - VIDEO FEEDBACK
// Channel 1401~1500    - AREA FEEDBACK
// Channel 1501~1600    - DEVICE ONLINE FEEDBACK

dvTP1           = 11001:1:0 // iphone6
dvTP2           = 11002:1:0 // iphone6
dvTP3           = 11003:1:0 // ipad 1024x768
dvTP4           = 11004:1:0 // iphone5s test

dvLight         = 5001:1:0

dvJupiter       = 0:2:0                     // ip socket, local port 2
vdvJupiter      = DYNAMIC_VIRTUAL_DEVICE

dvPPTPlay1      = 0:31:0                    // ip socket, local port 31
dvPPTPlay2      = 0:32:0                    // ip socket, local port 32
dvPPTPlay3      = 0:33:0                    // ip socket, local port 33
dvPPTPlay4      = 0:34:0                    // ip socket, local port 34

vdvPPTPlay1     = 33101:1:0
vdvPPTPlay2     = 33102:1:0
vdvPPTPlay3     = 33103:1:0
vdvPPTPlay4     = 33104:1:0

dvOptoma1       = 5001:2:0
dvOptoma2       = 5001:3:0
dvOptoma3       = 5001:4:0
dvOptoma4       = 5001:5:0

vdvOptoma1      = 33105:1:0
vdvOptoma2      = 33106:1:0
vdvOptoma3      = 33107:1:0
vdvOptoma4      = 33108:1:0

/*

I found dev array doesn't work with DYNAMIC_VIRTUAL_DEVICE, but I don't know
why.

vdvPPTPlay1     = DYNAMIC_VIRTUAL_DEVICE    //33101:1:0
vdvPPTPlay2     = DYNAMIC_VIRTUAL_DEVICE    //33102:1:0
vdvPPTPlay3     = DYNAMIC_VIRTUAL_DEVICE    //33103:1:0
vdvPPTPlay4     = DYNAMIC_VIRTUAL_DEVICE    //33104:1:0

vdvOptoma1      = DYNAMIC_VIRTUAL_DEVICE    //33105:1:0
vdvOptoma2      = DYNAMIC_VIRTUAL_DEVICE    //33106:1:0
vdvOptoma3      = DYNAMIC_VIRTUAL_DEVICE    //33107:1:0
vdvOptoma4      = DYNAMIC_VIRTUAL_DEVICE    //33108:1:0

*/

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

TP_MAX_PANELS           = 4
TP_STATUS_OFF           = 0
TP_STATUS_ON            = 1

POFF                    = 0
PON                     = 1

MAX_DEV_NUMBER          = 255

MAX_MODE_NUMBER         = 9
MAX_ZONE_NUMBER         = 8

ROOM_LIGHT_NUMBER       = 24
ROOM_VIDEO_NUMBER       = 4
ROOM_AUDIO_NUMBER       = 4

ZONE_LIGHT_NUMBER       = 4
ZONE_VIDEO_NUMBER       = 1
ZONE_MUSIC_NUMBER       = 1

// MAIN MENU ACTIVITY
MAIN_MENU_HOME          = 1
MAIN_MENU_CONFIG        = 2
MAIN_MENU_LIGHTS		= 3
MAIN_MENU_MUSIC         = 4
MAIN_MENU_VEDIO			= 5

// TIMELINE ID
TL_FEEDBACK			    = 1

DEFAULT_BRIGHT_GBLMODE  = 70
DEFAULT_BRIGHT_ZONE     = 100
DEFAULT_BRIGHT_ZOTHERS  = 50

MAIN_MODE_VISIT         = 1
MAIN_MODE_LEAVE         = 2

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

structure _sLightConfig
{
    char bValid              // valid FALSE means ignore
    char cBright             // 0 - off, 250 - on, 0 ~ 250 - dim value
}

structure _sVedioConfig
{
    char bValid
    char cState                 // OFF/ON
}

structure _sMusicConfig
{
    char bValid
    char cState
}

// each zone mode include config for all zones
structure _sModeConfig
{
    char nZoneId
    integer nVedioVolume
    _sLightConfig uLight[ROOM_LIGHT_NUMBER]
    _sVedioConfig uVideo[ROOM_VIDEO_NUMBER]
}

structure _sGblConfig
{
    char cBrightGblMode
    char cBrightZone
    char cBrightZoneOthers
    integer nVedioVolume
    _sLightConfig uLight[ROOM_LIGHT_NUMBER]
    _sVedioConfig uVideo[ROOM_VIDEO_NUMBER]
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile long lFeedbackTime[1] = { 200 }
volatile dev gDvTps[TP_MAX_PANELS] = {dvTP1, dvTP2, dvTP3, dvTP4}

volatile integer gTpStatus[TP_MAX_PANELS]

_sGblConfig uGC                                 // current config values
_sModeConfig uModeConfig[MAX_ZONE_NUMBER]

integer btnMainMode[] = {
    31, 32, 33, 34, 35, 36, 37, 38
}

volatile integer nMainMenuButtons[] =
{
    1,
    2,
    3,
    4,
    5
}

volatile integer nMainMenuLeftSelection

volatile integer nShowRoomAreas[]=
{
	1400,
	1401,
	1402,
	1403,
	1404,
	1405,
	1406,
	1407,
    1408																																																					// POOL
}

volatile integer nShowRoomAreasSelected[255];			// ARRAY OF AREAS SELECTED

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
define_function handleTpOnlineEvent (integer tpId)
{
    gTpStatus[tpId] = TP_STATUS_ON

    light_tpsBtnSyncStart()
    pptPlay_tpsBtnSyncStart(tpId)
}

define_function handleTpOfflineEvent (integer tpId)
{
    gTpStatus[tpId] = TP_STATUS_OFF
}

define_function tpapi_UpdateLevelValue (integer chan, integer value)
{
    integer tpId

    for (tpId = length_array(gDvTps); tpId >= 1; tpId--)
    {
        if (gTpStatus[tpId] == TP_STATUS_OFF)
            continue

        //if (chan == 401)
        //    send_string 0, "'tpId = ', ITOA(tpId), ' ', ITOA(chan), ' ', ITOA(value)"

        send_level gDvTps[tpId], chan, value
    }
}

define_function main_GblConfigReset2Default()
{
    uGC.cBrightGblMode = DEFAULT_BRIGHT_GBLMODE
    uGC.cBrightZone = DEFAULT_BRIGHT_ZONE
    uGC.cBrightZoneOthers = DEFAULT_BRIGHT_ZOTHERS
/*
    for (j = 1; j < ROOM_LIGHT_NUMBER; j++)
    {
        uGC.uLight[j].bValid = TRUE
        uGC.uLight[j].cBright = uGC.cBrightGblMode
    }

    for (j = 1; j < ROOM_VEDIO_NUMBER; j++)
    {
        uGC.uVideo[j].cState = PON
    }
*/
}

define_function main_ModeInitialize()
{
    stack_var integer i, j

    for (i = 1; i < MAX_MODE_NUMBER; i++)
    {
        for (j = 1; j < ROOM_LIGHT_NUMBER; j++)
        {
            // zone 8 keeps all light, which has the light 6
            if (j != 6)
            {
                uModeConfig[i].uLight[j].bValid = TRUE
                uModeConfig[i].uLight[j].cBright = uGC.cBrightZoneOthers
            }
        }

        for (j = 1; j < ROOM_VIDEO_NUMBER; j++)
        {
            uModeConfig[i].uVideo[j].cState = POFF
        }

        uModeConfig.nZoneId = type_cast(i - 1)

        switch (i)
        {
            case 1: // global mode
            {
                uModeConfig[i].uLight[6].bValid = TRUE

                for (j = 1; j < ROOM_LIGHT_NUMBER; j++)
                {
                    uModeConfig[i].uLight[j].cBright = uGC.cBrightGblMode
                }
                for (j = 1; j < ROOM_VIDEO_NUMBER; j++)
                {
                    uModeConfig[i].uVideo[j].bValid = TRUE
                    uModeConfig[i].uVideo[j].cState = PON
                }
            }
            case 2: // zone 1
            {
                uModeConfig[i].uLight[1].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[8].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[9].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[24].cBright = uGC.cBrightZone
            }
            case 3:
            {
                uModeConfig[i].uLight[5].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[10].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[20].cBright = uGC.cBrightZone

                uModeConfig[i].uVideo[1].bValid = TRUE
                uModeConfig[i].uVideo[1].cState = PON
            }
            case 4:
            {
                uModeConfig[i].uLight[7].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[11].cBright = uGC.cBrightZone
            }
            case 5:
            {
                uModeConfig[i].uLight[4].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[12].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[13].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[14].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[21].cBright = uGC.cBrightZone

                uModeConfig[i].uVideo[1].bValid = TRUE
                uModeConfig[i].uVideo[1].cState = PON
            }
            case 6:
            {
                uModeConfig[i].uLight[3].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[15].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[16].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[17].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[22].cBright = uGC.cBrightZone

                uModeConfig[i].uVideo[1].bValid = TRUE
                uModeConfig[i].uVideo[1].cState = PON
            }
            case 7:
            {
                uModeConfig[i].uLight[2].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[4].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[8].cBright = uGC.cBrightZone
            }
            case 8:
            {
                uModeConfig[i].uLight[4].cBright = uGC.cBrightZone
                uModeConfig[i].uLight[23].cBright = uGC.cBrightZone

                uModeConfig[i].uVideo[1].bValid = TRUE
                uModeConfig[i].uVideo[1].cState = PON
            }
            case 9:
            {
                uModeConfig[i].uLight[6].bValid = TRUE
                uModeConfig[i].uLight[6].cBright = uGC.cBrightZone
            }
        }
    }
}

define_function main_ExecuteModeConfig(integer nModeId)
{
    switch (nModeId)
    {
        case MAIN_MODE_VISIT:
        {
            light_CmdAllOn()
            optoma_CmdAllDevPowerOn()
            pptPlay_CmdOpenAllFiles()
        }

        case MAIN_MODE_LEAVE:
        {
            light_CmdAllOff()
            optoma_CmdAllDevPowerOff()
        }
    }
}

#include 'x_light.axi'
#include 'x_optoma.axi'
#include 'x_pptPlay.axi'
#include 'x_jupiter.axi'

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
{
/*
    if (uGC.cBrightGblMode == 0)
    {
        main_GblConfigReset2Default()
    }

    main_ModeInitialize()
*/
}
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[gDvTPs]
{
    ONLINE:
    {
        handleTpOnlineEvent(get_last(gDvTps))

        // Start feedback timeline
        IF (TIMELINE_ACTIVE(TL_FEEDBACK) == FALSE)
            TIMELINE_CREATE(TL_FEEDBACK, lFeedbackTime, 1, TIMELINE_ABSOLUTE, TIMELINE_REPEAT);
    }
    OFFLINE: { handleTpOfflineEvent(get_last(gDvTps)) }
}


BUTTON_EVENT[gDvTps, btnMainMode]
{
    PUSH:
    {
        stack_var integer i

        i = get_last(btnMainMode)

        main_ExecuteModeConfig(i)
    }
}

BUTTON_EVENT[gDvTPs, nShowRoomAreas]
{
    PUSH:
    {
        integer nArea;

        nArea = GET_LAST(nShowRoomAreas)

        nShowRoomAreasSelected[nArea] = !nShowRoomAreasSelected[nArea]

        if (nShowRoomAreasSelected[nArea])
        {
            main_ExecuteModeConfig(nArea)
        }
    }
}

TIMELINE_EVENT[TL_FEEDBACK]
{
    stack_var integer nLoop

    // Selected Areas
    for (nLoop = 1; nLoop <= LENGTH_ARRAY(nShowRoomAreas); nLoop++)
    {
        [gDvTPs, nShowRoomAreas[nLoop]] = (nShowRoomAreasSelected[nLoop] == TRUE)
    }

    light_tpsBtnSync()
    jupiter_tpsBtnSync()
    pptPlay_tpsBtnSync()
    optoma_tpsBtnSync()
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

