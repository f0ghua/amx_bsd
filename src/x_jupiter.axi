PROGRAM_NAME='x_jupiter'
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    Symetrix Jupiter 8
*)

#include 'CMDAPI.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

JUPITER_VOL_MIN                 = 0
JUPITER_VOL_MAX                 = 48

CHAN_JUPITER_ONLINE             = 1501
BTN_JUPITER_VIDEO_VOLUME        = 1

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile char jupiterIpAddr[16] = '10.0.12.26'
volatile char bJupiterOnline

// TPs offline will cause level event which set all bargraph values to be 0,
// so we should prevent from it
volatile char bTakeAudioLevel

integer btnAudioLevel[] = {
    401 // only vedio volume can be adjust
}

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

define_function jupiter_tpsBtnSync()
{
    [gDvTps, CHAN_JUPITER_ONLINE] = bJupiterOnline

    //send_string 0, "'uGC.nVedioVolume = ', ITOA(uGC.nVedioVolume)"
    tpapi_UpdateLevelValue(btnAudioLevel[1], uGC.nVedioVolume)
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

DEFINE_MODULE 'jupiter_comm' jupiter_Comm (vdvJupiter, dvJupiter, jupiterIpAddr)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[vdvJupiter]
{
    ONLINE:
    {
        send_string 0, 'vdvJupiter is Online'

        //wait 50
        //send_command vdvJupiter, 'INPUT_VIDEO_VOLUME?'
    }
    STRING:
    {
        stack_var char cmdName[32]
        stack_var _sCMD_PARAMETERS uParameters
        stack_var integer v, dvIdx

        dvIdx = GET_LAST(vdvJupiter)

        uParameters.count = 0
        cmdapi_ParseCommand(DATA.TEXT, "':'", cmdName, uParameters)

        switch (cmdName)
        {
            case 'INPUT_VIDEO_VOLUME=' :
            {
                v = ATOI(uParameters.param[1])
                if ((uParameters.count > 0) &&
                    cmdapi_RangeCheck(TYPE_CAST(v), JUPITER_VOL_MIN, JUPITER_VOL_MAX))
                {
                    uGC.nVedioVolume = TYPE_CAST(v)
                }
            }
            case 'ONLINE=' :
            {
                v = ATOI(uParameters.param[1])
                if ((uParameters.count > 0) &&
                    cmdapi_RangeCheck(TYPE_CAST(v), 0, 1))
                {
                    bJupiterOnline = TYPE_CAST(v)
                }
            }
        }
    }
}

BUTTON_EVENT[gDvTps, btnAudioLevel]
{
    PUSH:
    {
        bTakeAudioLevel = TRUE
    }
    RELEASE:
    {
        integer btnIdx

        bTakeAudioLevel = FALSE
        btnIdx = get_last(btnAudioLevel)

        send_command vdvJupiter, "'INPUT_VIDEO_VOLUME=', ITOA(uGC.nVedioVolume)"

    }
/*
    // The dimmer should be changed when drag the level
    HOLD[1, REPEAT]:
    {
        integer btnIdx

        btnIdx = get_last(btnAudioLevel)

        send_command vdvJupiter, "'INPUT_VIDEO_VOLUME=', ITOA(uGC.nVedioVolume)"
    }
*/
}

LEVEL_EVENT[gDvTps, btnAudioLevel]
{
    if (bTakeAudioLevel)
        uGC.nVedioVolume = LEVEL.VALUE
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

