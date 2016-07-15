PROGRAM_NAME='x_optoma'
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
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

OPTOMA_POWER_STANDBY             = 0

BTN_OPTOMA1_POWERON              = 1
BTN_OPTOMA1_POWEROFF             = 2
BTN_OPTOMA1_POWERTOGGLE          = 3
BTN_OPTOMA2_POWERON              = 4
BTN_OPTOMA2_POWEROFF             = 5
BTN_OPTOMA2_POWERTOGGLE          = 6
BTN_OPTOMA3_POWERON              = 7
BTN_OPTOMA3_POWEROFF             = 8
BTN_OPTOMA3_POWERTOGGLE          = 9
BTN_OPTOMA4_POWERON              = 10
BTN_OPTOMA4_POWEROFF             = 11
BTN_OPTOMA4_POWERTOGGLE          = 12

BTNFB_OPTOMA1_POWER              = 1
BTNFB_OPTOMA2_POWER              = 2
BTNFB_OPTOMA3_POWER              = 3
BTNFB_OPTOMA4_POWER              = 4

char sOptomaPowerState[4][16] = {
    'STANDBY',
    'READY',
    'WARMING',
    'COOLING'
}

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile dev optomaDevices[] =
{
    vdvOptoma1,
    vdvOptoma2,
    vdvOptoma3,
    vdvOptoma4
}

integer btnOptoma[] = {
    1201, 1202, 1203, 1204, 1205, 1206, 1207, 1208,
    1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216
}

integer btnOptomaFb[] = {
    1201, 1202, 1203, 1204, 1205, 1206, 1207, 1208
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

define_function optoma_TpsUpdatePowerState(integer dvIdx, char cState)
{
    integer msgIdx

    msgIdx = cState + 1
    switch (dvIdx)
    {
        case 1:
            SEND_COMMAND gDvTps,
            "'^TXT-', ITOA(btnOptomaFb[BTNFB_OPTOMA1_POWER]), ',0,', sOptomaPowerState[msgIdx]"
        case 2:
            SEND_COMMAND gDvTps,
            "'^TXT-', ITOA(btnOptomaFb[BTNFB_OPTOMA2_POWER]), ',0,', sOptomaPowerState[msgIdx]"
        case 3:
            SEND_COMMAND gDvTps,
            "'^TXT-', ITOA(btnOptomaFb[BTNFB_OPTOMA3_POWER]), ',0,', sOptomaPowerState[msgIdx]"
        case 4:
            SEND_COMMAND gDvTps,
            "'^TXT-', ITOA(btnOptomaFb[BTNFB_OPTOMA4_POWER]), ',0,', sOptomaPowerState[msgIdx]"
    }
}

define_function optoma_CmdAllDevPowerOn()
{
    integer dvIdx

    for (dvIdx = LENGTH_ARRAY(optomaDevices); dvIdx > 0; dvIdx--)
    {
        SEND_COMMAND optomaDevices[dvIdx], 'POWER=1'
    }
}

define_function optoma_CmdAllDevPowerOff()
{
    integer dvIdx

    for (dvIdx = LENGTH_ARRAY(optomaDevices); dvIdx > 0; dvIdx--)
    {
        SEND_COMMAND optomaDevices[dvIdx], 'POWER=0'
    }
}

define_function optoma_AddressFBUpdate()
{
    SEND_COMMAND gDvTps,
            "'^TXT-', ITOA(btnOptomaFb[BTNFB_OPTOMA1_POWER]), ',0,',
            sOptomaPowerState[uGC.uVideo[1].cState + 1]"
    SEND_COMMAND gDvTps,
            "'^TXT-', ITOA(btnOptomaFb[BTNFB_OPTOMA2_POWER]), ',0,',
            sOptomaPowerState[uGC.uVideo[2].cState + 1]"
    SEND_COMMAND gDvTps,
            "'^TXT-', ITOA(btnOptomaFb[BTNFB_OPTOMA3_POWER]), ',0,',
            sOptomaPowerState[uGC.uVideo[3].cState + 1]"
    SEND_COMMAND gDvTps,
            "'^TXT-', ITOA(btnOptomaFb[BTNFB_OPTOMA4_POWER]), ',0,',
            sOptomaPowerState[uGC.uVideo[4].cState + 1]"

}

define_function optoma_tpsBtnSync()
{
    [gDvTps, btnOptoma[BTN_OPTOMA1_POWERTOGGLE]] = (uGC.uVideo[1].cState != OPTOMA_POWER_STANDBY)
    [gDvTps, btnOptoma[BTN_OPTOMA2_POWERTOGGLE]] = (uGC.uVideo[2].cState != OPTOMA_POWER_STANDBY)
    [gDvTps, btnOptoma[BTN_OPTOMA3_POWERTOGGLE]] = (uGC.uVideo[3].cState != OPTOMA_POWER_STANDBY)
    [gDvTps, btnOptoma[BTN_OPTOMA4_POWERTOGGLE]] = (uGC.uVideo[4].cState != OPTOMA_POWER_STANDBY)

    //optoma_AddressFBUpdate()
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

DEFINE_MODULE 'OPTOMA_COMM' optoma_Comm1(vdvOptoma1, dvOptoma1)
DEFINE_MODULE 'OPTOMA_COMM' optoma_Comm2(vdvOptoma2, dvOptoma2)
DEFINE_MODULE 'OPTOMA_COMM' optoma_Comm3(vdvOptoma3, dvOptoma3)
DEFINE_MODULE 'OPTOMA_COMM' optoma_Comm4(vdvOptoma4, dvOptoma4)


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[optomaDevices]
{
    STRING:
    {
            stack_var char cmdName[32]
            stack_var _sCMD_PARAMETERS uParameters
            stack_var integer v, dvIdx

            dvIdx = GET_LAST(optomaDevices)

            uParameters.count = 0
            cmdapi_ParseCommand(DATA.TEXT, "':'", cmdName, uParameters)

            switch (cmdName)
            {
                case 'POWER=' :
                {
                    v = ATOI(uParameters.param[1])
                    if ((uParameters.count > 0) &&
                        cmdapi_RangeCheck(TYPE_CAST(v), 0, 2) &&
                        (uGC.uVideo[dvIdx].cState != v))
                    {
                        uGC.uVideo[dvIdx].cState = TYPE_CAST(v)
                        optoma_TpsUpdatePowerState(dvIdx, TYPE_CAST(uGC.uVideo[dvIdx].cState))
                    }
                }
            }
    }

}

BUTTON_EVENT[gDvTPs, btnOptoma]
{
    PUSH:
    {
        stack_var integer btnIdx, dvIdx

        btnIdx = GET_LAST(btnOptoma)

        dvIdx = (btnIdx-1)/3 + 1

        switch (btnIdx)
        {
            case BTN_OPTOMA1_POWERON:
            case BTN_OPTOMA2_POWERON:
            case BTN_OPTOMA3_POWERON:
            case BTN_OPTOMA4_POWERON:

                SEND_COMMAND optomaDevices[dvIdx], 'POWER=1'

            case BTN_OPTOMA1_POWEROFF:
            case BTN_OPTOMA2_POWEROFF:
            case BTN_OPTOMA3_POWEROFF:
            case BTN_OPTOMA4_POWEROFF:

                SEND_COMMAND optomaDevices[dvIdx], 'POWER=0'

            case BTN_OPTOMA1_POWERTOGGLE:
            case BTN_OPTOMA2_POWERTOGGLE:
            case BTN_OPTOMA3_POWERTOGGLE:
            case BTN_OPTOMA4_POWERTOGGLE:

            {
                if (uGC.uVideo[dvIdx].cState == OPTOMA_POWER_STANDBY)
                {
                    SEND_COMMAND optomaDevices[dvIdx], 'POWER=1'
                }
                else
                {
                    SEND_COMMAND optomaDevices[dvIdx], 'POWER=0'
                }
            }
        }
    }
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

