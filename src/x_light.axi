PROGRAM_NAME='x_light'
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*

AMD0603 Module Mapping Table

Module 1:
C1  - LD06
C2  - LD15
C3  - ?
C4  - ?

Module 2:
C1  - LD14
C2  - ?
C3  - LD19
C4  - ?
C5  - LD18
C6  - LD12
C7  - LD04
C8  - LD08
C9  - LD13

Module 3:
C1  - ?
C2  - LD10
C3  - LD11
C4  - LD14
C5  - LD15
C6  - LD03
C7  - LD16
C8  - LD01
C9  - ?
C10 - LD07
C11 - LD05

*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LIGHT_CMD_SIZE          = 64

LIGHT_ON                = 1
LIGHT_OFF               = 0

LIGHT_BRIGHT_MIN        = 0
LIGHT_BRIGHT_MAX        = 250
LIGHT_BRIGHT_PER_10     = (250*10/100)
LIGHT_BRIGHT_PER_20     = (250*20/100)
LIGHT_BRIGHT_PER_30     = (250*30/100)
LIGHT_BRIGHT_PER_50     = (250*50/100)

LIGHT_CIRCUIT_NUMBER    = ROOM_LIGHT_NUMBER

BTN_LIGHT_D01       = 1
BTN_LIGHT_D02       = 2
BTN_LIGHT_D03       = 3
BTN_LIGHT_D04       = 4
BTN_LIGHT_D05       = 5
BTN_LIGHT_D06       = 6
BTN_LIGHT_D07       = 7
BTN_LIGHT_D08       = 8
BTN_LIGHT_D09       = 9
BTN_LIGHT_D10       = 10
BTN_LIGHT_D11       = 11
BTN_LIGHT_D12       = 12
BTN_LIGHT_D13       = 13
BTN_LIGHT_D14       = 14
BTN_LIGHT_D15       = 15
BTN_LIGHT_D16       = 16
BTN_LIGHT_D17       = 17
BTN_LIGHT_D18       = 18
BTN_LIGHT_D19       = 19
BTN_LIGHT_D20       = 20
BTN_LIGHT_D21       = 21
BTN_LIGHT_D22       = 22
BTN_LIGHT_D23       = 23
BTN_LIGHT_D24       = 24

LIGHT_SCENE_ALL_ON          = 1
LIGHT_SCENE_ALL_OFF         = 2
LIGHT_SCENE_MODE1           = 3
LIGHT_SCENE_MODE2           = 4
LIGHT_SCENE_MODE3           = 5
LIGHT_SCENE_MODE4           = 6
LIGHT_SCENE_ALL_INCBRIGHT   = 7
LIGHT_SCENE_ALL_DECBRIGHT   = 8
LIGHT_SCENE_PROJECTOR1      = 9
LIGHT_SCENE_PROJECTOR2      = 10
LIGHT_SCENE_PROJECTOR3      = 11
LIGHT_SCENE_PROJECTOR4      = 12



LIGHT_SCENEPJ_Z1_OFF        = 1
LIGHT_SCENEPJ_Z1_ON         = 2
LIGHT_SCENEPJ_Z2_OFF        = 3
LIGHT_SCENEPJ_Z2_ON         = 4
LIGHT_SCENEPJ_Z3_OFF        = 5
LIGHT_SCENEPJ_Z3_ON         = 6
LIGHT_SCENEPJ_Z4_OFF        = 7
LIGHT_SCENEPJ_Z4_ON         = 8

// predefined code to control the scenes, it only used to control panel(module 4)
char cpcLightAllOn[] = {
    $fe, $55, $37, $00, $12, $04,
    $00, $00, $00, $00, $00, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $89
}

char cpcLightAllOff[] = {
    $fe, $55, $37, $00, $12, $04,
    $01, $00, $01, $01, $01, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $89
}

char cpcLightMode1[] = {
    $fe, $55, $37, $00, $12, $04,
    $02, $00, $02, $02, $02, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $89
}

char cpcLightMode2[] = {
    $fe, $55, $37, $00, $12, $04,
    $03, $00, $03, $03, $03, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $89
}

char cpcLightMode3[] = {
    $fe, $55, $37, $00, $12, $04,
    $04, $00, $04, $04, $04, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $89
}

char cpcLightMode4[] = {
    $fe, $55, $37, $00, $12, $04,
    $05, $00, $05, $05, $05, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $89
}

char cpcLightAllIncBright[] = {
    $fe, $55, $37, $00, $12, $05,
    $00, $03, $00, $00, $00, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $8b
}

char cpcLightAllDecBright[] = {
    $fe, $55, $37, $00, $12, $05,
    $01, $04, $00, $00, $00, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $8d
}

char cpcLightSceneProjector1[] = {
    $fe, $55, $37, $00, $12, $05,
    $02, $00, $06, $06, $06, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $8c
}

char cpcLightSceneProjector2[] = {
    $fe, $55, $37, $00, $12, $05,
    $03, $00, $07, $07, $07, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $8c
}

char cpcLightSceneProjector3[] = {
    $fe, $55, $37, $00, $12, $05,
    $04, $00, $08, $08, $08, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $84
}

char cpcLightSceneProjector4[] = {
    $fe, $55, $37, $00, $12, $05,
    $05, $00, $09, $09, $09, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd,
    $84
}

char cfgLightSceneProjector1[ROOM_LIGHT_NUMBER] = {
    $fe, $fe, LIGHT_BRIGHT_PER_10, LIGHT_BRIGHT_PER_10,
    LIGHT_BRIGHT_PER_50, LIGHT_BRIGHT_PER_10, LIGHT_BRIGHT_PER_10, LIGHT_BRIGHT_PER_10,
    LIGHT_BRIGHT_MIN, $fe, LIGHT_BRIGHT_PER_10, $fe,
    $fe, $fe, $fe, $fe,
    $fe, $fe, $fe, $fe,
    $fe, $fe, $fe, $fe
}

char cfgLightSceneProjector2[ROOM_LIGHT_NUMBER] = {
    LIGHT_BRIGHT_PER_10, $fe, $fe, LIGHT_BRIGHT_PER_10,
    $fe, LIGHT_BRIGHT_PER_30, $fe, $fe,
    $fe, $fe, LIGHT_BRIGHT_PER_10, LIGHT_BRIGHT_PER_10,
    $fe, $fe, $fe, $fe,
    $fe, $fe, $fe, $fe,
    $fe, $fe, $fe, $fe
}

char cfgLightSceneProjector3[ROOM_LIGHT_NUMBER] = {
    LIGHT_BRIGHT_PER_10, $fe, $fe, LIGHT_BRIGHT_PER_10,
    $fe, LIGHT_BRIGHT_PER_30, $fe, $fe,
    LIGHT_BRIGHT_MIN, $fe, LIGHT_BRIGHT_PER_10, LIGHT_BRIGHT_PER_10,
    $fe, $fe, $fe, $fe,
    $fe, $fe, $fe, $fe,
    $fe, $fe, $fe, $fe
}

char cfgLightSceneProjector4[ROOM_LIGHT_NUMBER] = {
    LIGHT_BRIGHT_PER_10, $fe, LIGHT_BRIGHT_PER_30, LIGHT_BRIGHT_PER_10,
    $fe, LIGHT_BRIGHT_PER_30, $fe, $fe,
    $fe, $fe, LIGHT_BRIGHT_MIN, $fe,
    $fe, $fe, $fe, $fe,
    $fe, $fe, $fe, $fe,
    $fe, $fe, $fe, $fe
}


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

structure _sLightAddress {
    integer nModule
    integer nCircurt
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

integer btnLightLevel[] = {
    101, 102, 103, 104, 105, 106, 107, 108,
    109, 110, 111, 112, 113, 114, 115, 116,
    117, 118, 119, 120, 121, 122, 123, 124
}

integer btnLight[] = {
    151, 152, 153, 154, 155, 156, 157, 158,
    159, 160, 161, 162, 163, 164, 165, 166,
    167, 168, 169, 170, 171, 172, 173, 174
}

integer btnZoneLightFB[] = {
    201, 202, 203, 204, 205, 206, 207, 208
}

integer btnLightScene[] = {
    301, 302, 303, 304, 305, 306, 307, 308
}

integer btnLightSceneProjector[] = {
    311, 312, 313, 314, 315, 316, 317, 318
}

_sLightAddress uLightMapping[LIGHT_CIRCUIT_NUMBER]
char cLvlBright[ROOM_LIGHT_NUMBER]

volatile char bTakeLightLevel

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

define_function char light_MappingInitialize()
{
    uLightMapping[1].nModule    = 3
    uLightMapping[1].nCircurt   = 8

    uLightMapping[2].nModule    = 1 //
    uLightMapping[2].nCircurt   = 2

    uLightMapping[3].nModule    = 3
    uLightMapping[3].nCircurt   = 6

    uLightMapping[4].nModule    = 2
    uLightMapping[4].nCircurt   = 7

    uLightMapping[5].nModule    = 3
    uLightMapping[5].nCircurt   = 11

    uLightMapping[6].nModule    = 1
    uLightMapping[6].nCircurt   = 1

    uLightMapping[7].nModule    = 3
    uLightMapping[7].nCircurt   = 10

    uLightMapping[8].nModule    = 2
    uLightMapping[8].nCircurt   = 8

    uLightMapping[9].nModule    = 1
    uLightMapping[9].nCircurt   = 4

    uLightMapping[10].nModule   = 2 // no affect
    uLightMapping[10].nCircurt  = 11

    uLightMapping[11].nModule   = 3
    uLightMapping[11].nCircurt  = 3

    uLightMapping[12].nModule   = 2
    uLightMapping[12].nCircurt  = 6

    uLightMapping[13].nModule   = 2
    uLightMapping[13].nCircurt  = 9

    uLightMapping[14].nModule   = 3
    uLightMapping[14].nCircurt  = 4

    uLightMapping[15].nModule   = 3
    uLightMapping[15].nCircurt  = 5

    uLightMapping[16].nModule   = 3
    uLightMapping[16].nCircurt  = 7

    uLightMapping[17].nModule   = 2 // no affect
    uLightMapping[17].nCircurt  = 12

    uLightMapping[18].nModule   = 2
    uLightMapping[18].nCircurt  = 5

    uLightMapping[19].nModule   = 2
    uLightMapping[19].nCircurt  = 3

    uLightMapping[20].nModule   = 2 //
    uLightMapping[20].nCircurt  = 1

    uLightMapping[21].nModule   = 2 //
    uLightMapping[21].nCircurt  = 2

    uLightMapping[22].nModule   = 2 //
    uLightMapping[22].nCircurt  = 4

    uLightMapping[23].nModule   = 3 //
    uLightMapping[23].nCircurt  = 1

    uLightMapping[24].nModule   = 3 // no affect
    uLightMapping[24].nCircurt  = 12
}

define_function integer light_MappingGetIndex(integer nModule, integer nCircurt)
{
    integer i

    for (i = LIGHT_CIRCUIT_NUMBER; i > 0; i--)
    {
        if ((nModule == uLightMapping[i].nModule) &&
            (nCircurt == uLightMapping[i].nCircurt)
            )
            return i
    }

    return 0
}

define_function char light_CmdCrc(char cBuffer[], integer nCrcLen)
{
    integer i
    char nCrcValue

    nCrcValue = cBuffer[1]
    for (i = 2; i <= nCrcLen; i++)
    {
        nCrcValue = (nCrcValue^cBuffer[i])
    }

    return nCrcValue
}

define_function char light_CmdStateQuery(integer nModule)
{
    char cCmd[LIGHT_CMD_SIZE]
    char cCrcStr[LIGHT_CMD_SIZE]
    char cCrcValue
    stack_var integer i, nByte, nCrcLen, nCmdLen

    cCmd[1] = $FE
    cCmd[2] = $55
    cCmd[4] = $00
    cCmd[5] = $16
    cCmd[6] = TYPE_CAST(nModule)

    nCrcLen = 5
    cCmd[3] = TYPE_CAST(nCrcLen)

    for (i = 1; i <= nCrcLen; i++)
        cCrcStr[i] = cCmd[i+1]

    cCrcValue = light_CmdCrc(cCrcStr, nCrcLen)

    nCmdLen = nCrcLen + 2
    cCmd[nCmdLen] = cCrcValue
    SET_LENGTH_ARRAY(cCmd, nCmdLen)

    send_string dvLight, "cCmd"
}

define_function integer light_GetModuleCirCurt(integer nModule)
{
        switch (nModule)
        {
            case 1:
                return 6;   // module 1 has 6 circurts
            case 2:
            case 3:
                return 12;
        }
}

// brightValue is 0~250
define_function light_DimModuleLevel(integer nModule, integer nCirCurt, char brightValue)
{
    char cCmd[LIGHT_CMD_SIZE]
    char cCrcStr[LIGHT_CMD_SIZE]
    char cCrcValue
    stack_var integer i, nByte, nCrcLen, nCmdLen, cirNum

    cirNum = light_GetModuleCirCurt(nModule)

    cCmd[1] = $FE
    cCmd[2] = $55
    cCmd[4] = $00
    cCmd[5] = $17
    cCmd[6] = TYPE_CAST(nModule)
    for (i = 1; i <= (cirNum); i++)
    {
        nByte = i + 6
        if (i == nCirCurt)
        {
            cCmd[nByte] = brightValue
        }
        else
        {
            cCmd[nByte] = $FE // do nothing
        }
    }

    nCrcLen = (5 + cirNum)
    cCmd[3] = TYPE_CAST(nCrcLen)

    for (i = 1; i <= nCrcLen; i++)
        cCrcStr[i] = cCmd[i+1]

    cCrcValue = light_CmdCrc(cCrcStr, nCrcLen)

    nCmdLen = nCrcLen + 2
    cCmd[nCmdLen] = cCrcValue
    SET_LENGTH_ARRAY(cCmd, nCmdLen)

    send_string dvLight, "cCmd"
}

// brightValue is 0~250
define_function light_DimLevel(integer lightIdx, char brightValue)
{
    char divBright1

    divBright1 = (uGC.uLight[lightIdx].cBright - brightValue)

    send_string 0, "'cBright= ', uGC.uLight[lightIdx].cBright, ',brightValue= ', brightValue, ',divBright1= ', divBright1"
    if ( divBright1 > (LIGHT_BRIGHT_MAX/2))
    {
        CANCEL_WAIT 'WAIT_LIGHT_DIMLEVEL'

        divBright1 = (divBright1/2)
        light_DimModuleLevel(uLightMapping[lightIdx].nModule,
            uLightMapping[lightIdx].nCircurt,
            divBright1
            )

        wait 5 'WAIT_LIGHT_DIMLEVEL'
        light_DimModuleLevel(uLightMapping[lightIdx].nModule,
            uLightMapping[lightIdx].nCircurt,
            brightValue
            )
    }
    else
    {
        light_DimModuleLevel(uLightMapping[lightIdx].nModule,
            uLightMapping[lightIdx].nCircurt,
            brightValue
            )
    }

    uGC.uLight[lightIdx].cBright = brightValue;

    //light_tpsUpdateLevelValuesByIdx(lightIdx)
}

define_function char[LIGHT_CMD_SIZE] light_BuildCmdArray(integer nModule, char aLightSet[])
{
    char cCmd[LIGHT_CMD_SIZE]
    char cCrcStr[LIGHT_CMD_SIZE]
    char cCrcValue
    stack_var integer i, j, nByte, nCrcLen, nCmdLen, cirNum

    cirNum = light_GetModuleCirCurt(nModule)

    cCmd[1] = $FE
    cCmd[2] = $55
    cCmd[4] = $00
    cCmd[5] = $17
    cCmd[6] = TYPE_CAST(nModule)
    for (i = 1; i <= (cirNum); i++)
    {
        nByte = i + 6
        cCmd[nByte] = $FE // initial with do nothing
    }

    // update values set in aLightSet
    for (i = 1; i <= (cirNum); i++)
    {
        nByte = i + 6
        for (j = 1; j <= LENGTH_ARRAY(aLightSet); j++)
        {
            if ((uLightMapping[j].nModule == nModule) &&
                (uLightMapping[j].nCircurt == i))
            {
                cCmd[nByte] = aLightSet[j]
            }
        }
    }

    nCrcLen = (5 + cirNum)
    cCmd[3] = TYPE_CAST(nCrcLen)

    for (i = 1; i <= nCrcLen; i++)
        cCrcStr[i] = cCmd[i+1]

    cCrcValue = light_CmdCrc(cCrcStr, nCrcLen)

    nCmdLen = nCrcLen + 2
    cCmd[nCmdLen] = cCrcValue
    SET_LENGTH_ARRAY(cCmd, nCmdLen)

    return cCmd
}

define_function light_DimCmdArray(char aLightSet[])
{
    stack_var integer i
    local_var cLightCmd1[LIGHT_CMD_SIZE], cLightCmd2[LIGHT_CMD_SIZE], cLightCmd3[LIGHT_CMD_SIZE]

    cLightCmd1 = light_BuildCmdArray(1, aLightSet)
    cLightCmd2 = light_BuildCmdArray(2, aLightSet)
    cLightCmd3 = light_BuildCmdArray(3, aLightSet)

    CANCEL_WAIT 'WAIT_DIM1'
    CANCEL_WAIT 'WAIT_DIM2'

    send_string dvLight, "cLightCmd1"

    wait 5 'WAIT_DIM1'
    {
        send_string dvLight, "cLightCmd2"
    }

    wait 10 'WAIT_DIM2'
    {
        send_string dvLight, "cLightCmd3"
    }

    for (i = 0; i < LENGTH_ARRAY(aLightSet); i++)
    {
        if ((i < ROOM_LIGHT_NUMBER) && (aLightSet[i] != $fe))
            uGC.uLight[i].cBright = aLightSet[i]
    }
}

define_function light_CmdScene(integer nSceneIndex)
{
    integer i

    switch (nSceneIndex)
    {
        case LIGHT_SCENE_ALL_ON:
        {
            for (i = 0; i < LENGTH_ARRAY(uGC.uLight); i++)
            {
                uGC.uLight[i].cBright = LIGHT_BRIGHT_MAX
            }
            send_string dvLight, "cpcLightAllOn"
        }
        case LIGHT_SCENE_ALL_OFF:
        {
            for (i = 0; i < LENGTH_ARRAY(uGC.uLight); i++)
            {
                uGC.uLight[i].cBright = LIGHT_BRIGHT_MIN
            }
            send_string dvLight, "cpcLightAllOff"
        }
        case LIGHT_SCENE_PROJECTOR1:
        {
            for (i = 0; i < LENGTH_ARRAY(uGC.uLight); i++)
            {
                uGC.uLight[i].cBright = cfgLightSceneProjector1[i];
            }
            send_string dvLight, "cpcLightSceneProjector1"
        }
        case LIGHT_SCENE_PROJECTOR2:
        {
            for (i = 0; i < LENGTH_ARRAY(uGC.uLight); i++)
            {
                uGC.uLight[i].cBright = cfgLightSceneProjector2[i];
            }
            send_string dvLight, "cpcLightSceneProjector2"
        }
        case LIGHT_SCENE_PROJECTOR3:
        {
            for (i = 0; i < LENGTH_ARRAY(uGC.uLight); i++)
            {
                uGC.uLight[i].cBright = cfgLightSceneProjector3[i];
            }
            send_string dvLight, "cpcLightSceneProjector3"
        }
        case LIGHT_SCENE_PROJECTOR4:
        {
            for (i = 0; i < LENGTH_ARRAY(uGC.uLight); i++)
            {
                uGC.uLight[i].cBright = cfgLightSceneProjector4[i];
            }
            send_string dvLight, "cpcLightSceneProjector4"
        }
    }

    send_string 0, "'call light_tpsUpdateLevelValues'"
    light_tpsUpdateLevelValues()
}

define_function light_CmdSceneProjector(integer nSceneIndex)
{
    switch (nSceneIndex)
    {
        case LIGHT_SCENEPJ_Z1_OFF:
        {
            light_CmdScene(LIGHT_SCENE_PROJECTOR1)
        }
        case LIGHT_SCENEPJ_Z1_ON:
        {
            light_CmdScene(LIGHT_SCENE_ALL_ON)
        }
        case LIGHT_SCENEPJ_Z2_OFF:
        {
            light_CmdScene(LIGHT_SCENE_PROJECTOR2)
        }
        case LIGHT_SCENEPJ_Z2_ON:
        {
            light_CmdScene(LIGHT_SCENE_ALL_ON)
        }
        case LIGHT_SCENEPJ_Z3_OFF:
        {
            light_CmdScene(LIGHT_SCENE_PROJECTOR3)
        }
        case LIGHT_SCENEPJ_Z3_ON:
        {
            light_CmdScene(LIGHT_SCENE_ALL_ON)
        }
        case LIGHT_SCENEPJ_Z4_OFF:
        {
            light_CmdScene(LIGHT_SCENE_PROJECTOR4)
        }
        case LIGHT_SCENEPJ_Z4_ON:
        {
            light_CmdScene(LIGHT_SCENE_ALL_ON)
        }
    }
}

define_function light_CmdAllOn()
{
    light_CmdScene(LIGHT_SCENE_ALL_ON)
}

define_function light_CmdAllOff()
{
    light_CmdScene(LIGHT_SCENE_ALL_OFF)
}

// index: the light index of the button array
// return: 0 - off, 1 - on
define_function integer light_GetStatus(integer index)
{
    return (uGC.uLight[index].cBright != 0)
}

define_function light_tpsUpdateLevelValues()
{
    integer i

    for (i = 1; i <= LENGTH_ARRAY(btnLightLevel); i++)
    {
        //send_string 0, "'light_tpsUpdateLevelValues, channel: ', ITOA(btnLightLevel[i]), 'value', ITOA(uGC.uLight[i].cBright)"
        tpapi_UpdateLevelValue(btnLightLevel[i], uGC.uLight[i].cBright)
    }
}

define_function light_tpsUpdateLevelValuesByIdx(integer i)
{
    tpapi_UpdateLevelValue(btnLightLevel[i], uGC.uLight[i].cBright)
}

define_function light_tpsBtnSyncStart()
{
    light_tpsUpdateLevelValues()
}

define_function light_tpsBtnSync()
{
    integer i

    for (i = 1; i <= LENGTH_ARRAY(btnLight); i++)
    {
        [gDvTps, btnLight[i]] = (uGC.uLight[i].cBright != 0)
    }
}

define_function fnProcessStrFromDev(char sReplyArray[])
{
    stack_var integer i
    stack_var char cByte, nLightIdx
    stack_var char cHead, cFix, cLen, cId, cCode, cModule

    if (LENGTH_STRING(sReplyArray) < 6)
    {
        return
    }

    cHead   = GET_BUFFER_CHAR(sReplyArray)
    cFix    = GET_BUFFER_CHAR(sReplyArray)
    cLen    = GET_BUFFER_CHAR(sReplyArray)
    cId     = GET_BUFFER_CHAR(sReplyArray)
    cCode   = GET_BUFFER_CHAR(sReplyArray)
    cModule = GET_BUFFER_CHAR(sReplyArray)

    if ((cFix != $55)||(cCode != $96))
    {
        return
    }

    switch (cModule)
    {
        case 1: // module 1 has 6 circurts
        {
            for (i = 1; i <= 6; i++)
            {
                cByte = GET_BUFFER_CHAR(sReplyArray)
                nLightIdx = TYPE_CAST(light_MappingGetIndex(cModule, i))
                if (nLightIdx)
                {
                    uGC.uLight[nLightIdx].cBright = cByte
                }
            }
            light_tpsUpdateLevelValues();
        }
        case 2: // module 2,3 has 12 circurts
        case 3:
        {
            for (i = 1; i <= 12; i++)
            {
                cByte = GET_BUFFER_CHAR(sReplyArray)
                nLightIdx = TYPE_CAST(light_MappingGetIndex(cModule, i))
                if (nLightIdx)
                {
                    uGC.uLight[nLightIdx].cBright = cByte
                }
            }
            light_tpsUpdateLevelValues();
        }
    }

    return
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

light_MappingInitialize()

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvLight]
{
    ONLINE:
    {
        SEND_COMMAND DATA.DEVICE, 'SET MODE DATA'
        SEND_COMMAND DATA.DEVICE, 'SET BAUD 9600,N,8,1,485 ENABLE'

        wait 20 light_CmdStateQuery(1)
        wait 30 light_CmdStateQuery(2)
        wait 40 light_CmdStateQuery(3)
    }
    STRING:
    {
        fnProcessStrFromDev(DATA.TEXT)
    }
}

BUTTON_EVENT[gDvTps, btnLight]
{
    PUSH:
    {
        stack_var integer i

        i = get_last(btnLight)

        if (light_GetStatus(i))
        {
            light_DimLevel(i, LIGHT_BRIGHT_MIN)
        }
        else
        {
            light_DimLevel(i, LIGHT_BRIGHT_MAX)
        }
    }
}

BUTTON_EVENT[gDvTps, btnLightScene]
{
    PUSH:
    {
        stack_var integer i

        i = get_last(btnLightScene)

        light_CmdScene(i)
    }
}

BUTTON_EVENT[gDvTps, btnLightSceneProjector]
{
    PUSH:
    {
        stack_var integer i

        i = get_last(btnLightSceneProjector)

        light_CmdSceneProjector(i)
    }
}

BUTTON_EVENT[gDvTps, btnLightLevel]
{
    PUSH:
    {
        bTakeLightLevel = TRUE
    }
    RELEASE:
    {
        stack_var integer i

        bTakeLightLevel = FALSE
        i = get_last(btnLightLevel)

        light_DimLevel(i, cLvlBright[i])
    }
/*
    // The dimmer should be changed when drag the level
    HOLD[1, REPEAT]:
    {
        stack_var integer i

        i = get_last(btnLightLevel)
        light_DimLevel(i, uGC.uLight[i].cBright)
    }
*/
}

LEVEL_EVENT[gDvTps, btnLightLevel]
{
    stack_var integer i;

    // Panel offline will cause level_enent with 0 value, this variable can
    // prevent from that case

    if (bTakeLightLevel)
    {
        i = get_last(btnLightLevel)
        cLvlBright[i] = TYPE_CAST(LEVEL.VALUE)
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

