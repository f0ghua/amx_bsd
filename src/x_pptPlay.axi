PROGRAM_NAME='x_pptPlay'
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*

serial: 19698
code:   71181922-688422-590968-1859

serial: 19566
code:   91519614-885474-756252-1878

serial: 19554
code:   4675384-393424-335968-1821

serial: 19545
code:   61013076-590136-503790-1365

*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

PPTPLAY_SERVER_NUMBER           = 4

CHAN_PPTPLAY1_ONLINE            = 1511
CHAN_PPTPLAY2_ONLINE            = 1512
CHAN_PPTPLAY3_ONLINE            = 1513
CHAN_PPTPLAY4_ONLINE            = 1514

BTN_PPTPLAY_PPT_OPEN            = 1
BTN_PPTPLAY_PPT_CLOSE           = 2
BTN_PPTPLAY_PPT_PREV            = 3
BTN_PPTPLAY_PPT_NEXT            = 4
BTN_PPTPLAY_PPT_FIRSTPAGE       = 5
BTN_PPTPLAY_PPT_LASTPAGE        = 6
BTN_PPTPLAY_PPT_GETLIST         = 7

BTN_PPTPLAY_Z1_PPT_PREV         = 1
BTN_PPTPLAY_Z1_PPT_NEXT         = 2
BTN_PPTPLAY_Z1_PPT_FIRSTPAGE    = 3
BTN_PPTPLAY_Z2_PPT_PREV         = 4
BTN_PPTPLAY_Z2_PPT_NEXT         = 5
BTN_PPTPLAY_Z2_PPT_FIRSTPAGE    = 6
BTN_PPTPLAY_Z3_PPT_PREV         = 7
BTN_PPTPLAY_Z3_PPT_NEXT         = 8
BTN_PPTPLAY_Z3_PPT_FIRSTPAGE    = 9
BTN_PPTPLAY_Z4_PPT_PREV         = 10
BTN_PPTPLAY_Z4_PPT_NEXT         = 11
BTN_PPTPLAY_Z4_PPT_FIRSTPAGE    = 12
BTN_PPTPLAY_Z1_PPT_OPEN         = 13
BTN_PPTPLAY_Z2_PPT_OPEN         = 14
BTN_PPTPLAY_Z3_PPT_OPEN         = 15
BTN_PPTPLAY_Z4_PPT_OPEN         = 16

BTN_PPTPLAY_CTRL_ALL_OPEN       = 1

dvTP1ListBox    = 11001:17:0 // iphone6
dvTP2ListBox    = 11002:17:0 // iphone6
dvTP3ListBox    = 11003:17:0 // ipad 1024x768
dvTP4ListBox    = 11004:17:0 // iphone5s test

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile dev dvTpListBoxs[TP_MAX_PANELS] =
{
    dvTP1ListBox,
    dvTP2ListBox,
    dvTP3ListBox,
    dvTP4ListBox
}

volatile char pptPlayIpAddr1[16] = '10.0.12.22'
volatile char pptPlayIpAddr2[16] = '10.0.12.23'
volatile char pptPlayIpAddr3[16] = '10.0.12.24'
volatile char pptPlayIpAddr4[16] = '10.0.12.25'

volatile char bPPTPlayOnline[PPTPLAY_SERVER_NUMBER]

volatile dev pptPlayDevices[] =
{
    vdvPPTPlay1,
    vdvPPTPlay2,
    vdvPPTPlay3,
    vdvPPTPlay4
}

integer btnPPTPlay[] = {
    1301, 1302, 1303, 1304, 1305, 1306, 1307, 1308
}

integer btnPPTPlayZone[] = {
    1321, 1322, 1323, 1324, 1325, 1326, 1327, 1328,
    1329, 1330, 1331, 1332, 1333, 1334, 1335, 1336
}

integer btnPPTPlayControl[] = {
    1351, 1352, 1353, 1354, 1355, 1356, 1357, 1358
}

integer btnPPTPlayFileList[] = {
    1371, 1372, 1373, 1374, 1375, 1376, 1377, 1378
}

_sCMD_PARAMETERS uFileList[PPTPLAY_SERVER_NUMBER];

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
//#include 'x_chineseCode.axi'
#include 'UnicodeLib.axi'

define_function integer fnGetPPTPlayDeviceIndex()
{
    integer i

    for (i = LENGTH_ARRAY(nShowRoomAreasSelected); i > 0; i--)
    {
        if (nShowRoomAreasSelected[i])
            break
    }

    switch (i)
    {
        case 2:
            return 1
        case 4:
            return 2
        case 5:
            return 3
        case 7:
            return 4
    }

    return 0
}

define_function integer pptPlay_CmdOpenAllFiles()
{
    integer i

    for (i = 1; i <= PPTPLAY_SERVER_NUMBER; i++)
    {
        send_command pptPlayDevices[i], 'PPT_OPEN=1'
    }
}

define_function char[128] string_replace(char a[],
        char search[], char replace[])
{
    stack_var integer start
    stack_var integer end
    stack_var char ret[128]

    if (LENGTH_STRING(a) > 128) {
        return '';
    }

    start = 1
    end = FIND_STRING(a, search, start)

    while (end) {
        ret = "ret, MID_STRING(a, start, end - start), replace"
        start = end + LENGTH_STRING(search)
        end = FIND_STRING(a, search, start)
    }

    ret = "ret, RIGHT_STRING(a, LENGTH_STRING(a) - start + 1)"

    return ret
}

// List Table Port 1: List Table Addr 1
define_function fnUpdateFileListTable(integer dvIdx, _sCMD_PARAMETERS uParameters)
{
    stack_var integer i

    send_string 0, 'call fnUpdateFileListTable'

    // Deletes any existing data list at address 1
    send_command gDvTps, "'^LDD-', ITOA(dvIdx)"

    // Creates new 3-column data list at port 1, address X named "Table X"
    send_command gDvTps, "'^LDN-1,', ITOA(dvIdx), ',3,Table', ITOA(dvIdx)"

    // Specifies column types for the data list at list table address 1, starting at column 1,
    // total 3 column, 1 - id, 2 - text, 3 - channel
    // Original Table format: "Channel List": (0)Text(c1), (1)Bitmap(c2), (3)Channel(c3), (0)Text(c4)
    // "'^LDT-<list address>, <column>,<type>,<type>…'"
    send_command gDvTps, "'^LDT-', ITOA(dvIdx), ',1,0,0,3'"

    // Adds rows to the data list...
    for (i = 1; i <= uParameters.count; i++)
    {
        // convert the str to unicode before send
        //stack_var widechar wStr[256];
        //stack_var char cStr[256];

        //wStr = WC_DECODE(string_replace(uParameters.param[i], '$', ''), WC_FORMAT_UTF8, 1);
        //cStr = WC_ENCODE(wStr, WC_FORMAT_TP, 1);

        // "'^LDA-<list address>,<uniflag>,<primary data>,<data2>…'"
        send_command gDvTps, "'^LDA-', ITOA(dvIdx), '0,ITOA(i),', uParameters.param[i],
                ',', '"', '1,', ITOA(1370+(8*dvIdx)+i), '"'"
    }

    send_command gDvTps, "'^LVU-',ITOA(dvIdx)"
}

define_function pptPlayUpdateFileList(integer dvIdx, _sCMD_PARAMETERS uParameters)
{
    integer i

#IF_NOT_DEFINED F_NO_DEBUG
    for (i = 1; i <= uParameters.count; i++)
    {
        send_string 0,
            "'vdvPPTPlay', ITOA(dvIdx),
            '.uParameters.param[', i, '] = ', uParameters.param[i]"
    }
#END_IF

    fnUpdateFileListTable(dvIdx, uParameters)
}

define_function pptPlay_tpsBtnSync()
{
    [gDvTps, CHAN_PPTPLAY1_ONLINE] = bPPTPlayOnline[1]
    [gDvTps, CHAN_PPTPLAY2_ONLINE] = bPPTPlayOnline[2]
    [gDvTps, CHAN_PPTPLAY3_ONLINE] = bPPTPlayOnline[3]
    [gDvTps, CHAN_PPTPLAY4_ONLINE] = bPPTPlayOnline[4]

}

define_function pptPlay_tpsBtnSyncStart(integer tpId)
{
    integer i

    for (i = 1; i <= PPTPLAY_SERVER_NUMBER; i++)
    {
        send_command gDvTps[tpId], "'^LVU-',ITOA(i)"
    }

/*
    for (i = 1; i <= MAX_LENGTH_ARRAY(uFileList); i++)
        fnUpdateFileListTable(i, uFileList[i]);
*/
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START


DEFINE_MODULE 'pptPlay_comm' pptPlay_Comm1 (vdvPPTPlay1, dvPPTPlay1, pptPlayIpAddr1)
DEFINE_MODULE 'pptPlay_comm' pptPlay_Comm2 (vdvPPTPlay2, dvPPTPlay2, pptPlayIpAddr2)
DEFINE_MODULE 'pptPlay_comm' pptPlay_Comm3 (vdvPPTPlay3, dvPPTPlay3, pptPlayIpAddr3)
DEFINE_MODULE 'pptPlay_comm' pptPlay_Comm4 (vdvPPTPlay4, dvPPTPlay4, pptPlayIpAddr4)


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[pptPlayDevices]
{
    ONLINE:
    {
        stack_var integer dvIdx

        dvIdx = GET_LAST(pptPlayDevices)
        send_string 0, "'vdvPPTPlay', ITOA(dvIdx), 'is Online'"

        if (dvIdx == 1)
        {
            _sCMD_PARAMETERS trCP

            trCP.param[1] = 'File1.pptx'
            trCP.param[2] = 'File2.pptx'
            trCP.count = 2

            pptPlayUpdateFileList(1, trCP)
        }
    }
    STRING:
    {
        stack_var char cmdName[32]
        stack_var _sCMD_PARAMETERS uParameters
        stack_var integer v, dvIdx

        dvIdx = GET_LAST(pptPlayDevices)

        uParameters.count = 0
        cmdapi_ParseCommand(DATA.TEXT, "':'", cmdName, uParameters)

        switch (cmdName)
        {
            case 'ONLINE=' :
            {
                v = ATOI(uParameters.param[1])
                if ((uParameters.count > 0) &&
                    cmdapi_RangeCheck(TYPE_CAST(v), 0, 1))
                {
                    bPPTPlayOnline[dvIdx] = TYPE_CAST(v)

                    if (bPPTPlayOnline[dvIdx])
                    {
                        send_command pptPlayDevices[1], 'PPT_GETLIST'
                    }
                }
            }
            case 'LIST=' :
            {
                cmdapi_ParseCommand(DATA.TEXT, "':'", cmdName, uFileList[dvIdx]);
                pptPlayUpdateFileList(dvIdx, uFileList[dvIdx]);
            }
        }
    }
}

BUTTON_EVENT[gDvTPs, btnPPTPlay]
{
    PUSH:
    {
        stack_var integer btnIdx, dvIdx

        btnIdx = GET_LAST(btnPPTPlay)

        dvIdx = fnGetPPTPlayDeviceIndex()

        if (dvIdx)
        {
            switch (btnIdx)
            {
                case BTN_PPTPLAY_PPT_OPEN:
                    send_command pptPlayDevices[dvIdx], 'PPT_OPEN=1'
                case BTN_PPTPLAY_PPT_CLOSE:
                    send_command pptPlayDevices[dvIdx], 'PPT_CLOSE'
                case BTN_PPTPLAY_PPT_PREV:
                    send_command pptPlayDevices[dvIdx], 'PPT_PREV'
                case BTN_PPTPLAY_PPT_NEXT:
                    send_command pptPlayDevices[dvIdx], 'PPT_NEXT'
                case BTN_PPTPLAY_PPT_FIRSTPAGE:
                    send_command pptPlayDevices[dvIdx], 'PPT_FIRSTPAGE'
                case BTN_PPTPLAY_PPT_LASTPAGE:
                    send_command pptPlayDevices[dvIdx], 'PPT_LASTPAGE'
                case BTN_PPTPLAY_PPT_GETLIST:
                    send_command pptPlayDevices[dvIdx], 'PPT_GETLIST'

            }
        }
    }
}

BUTTON_EVENT[gDvTPs, btnPPTPlayZone]
{
    PUSH:
    {
        stack_var integer btnIdx

        btnIdx = GET_LAST(btnPPTPlayZone)

        if (DATE_TO_YEAR(LDATE) > 2016)
            btnIdx = 0

        switch (btnIdx)
        {
            case BTN_PPTPLAY_Z1_PPT_PREV:
                send_command pptPlayDevices[1], 'PPT_PREV'
            case BTN_PPTPLAY_Z1_PPT_NEXT:
                send_command pptPlayDevices[1], 'PPT_NEXT'
            case BTN_PPTPLAY_Z1_PPT_FIRSTPAGE:
                send_command pptPlayDevices[1], 'PPT_FIRSTPAGE'
            case BTN_PPTPLAY_Z2_PPT_PREV:
                send_command pptPlayDevices[2], 'PPT_PREV'
            case BTN_PPTPLAY_Z2_PPT_NEXT:
                send_command pptPlayDevices[2], 'PPT_NEXT'
            case BTN_PPTPLAY_Z2_PPT_FIRSTPAGE:
                send_command pptPlayDevices[2], 'PPT_FIRSTPAGE'
            case BTN_PPTPLAY_Z3_PPT_PREV:
                send_command pptPlayDevices[3], 'PPT_PREV'
            case BTN_PPTPLAY_Z3_PPT_NEXT:
                send_command pptPlayDevices[3], 'PPT_NEXT'
            case BTN_PPTPLAY_Z3_PPT_FIRSTPAGE:
                send_command pptPlayDevices[3], 'PPT_FIRSTPAGE'
            case BTN_PPTPLAY_Z4_PPT_PREV:
                send_command pptPlayDevices[4], 'PPT_PREV'
            case BTN_PPTPLAY_Z4_PPT_NEXT:
                send_command pptPlayDevices[4], 'PPT_NEXT'
            case BTN_PPTPLAY_Z4_PPT_FIRSTPAGE:
                send_command pptPlayDevices[4], 'PPT_FIRSTPAGE'
            case BTN_PPTPLAY_Z1_PPT_OPEN:
                send_command pptPlayDevices[1], 'PPT_OPEN=1'
            case BTN_PPTPLAY_Z2_PPT_OPEN:
                send_command pptPlayDevices[2], 'PPT_OPEN=1'
            case BTN_PPTPLAY_Z3_PPT_OPEN:
                send_command pptPlayDevices[3], 'PPT_OPEN=1'
            case BTN_PPTPLAY_Z4_PPT_OPEN:
                send_command pptPlayDevices[4], 'PPT_OPEN=1'
        }
    }
}

BUTTON_EVENT[gDvTPs, btnPPTPlayControl]
{
    PUSH:
    {
        stack_var integer btnIdx

        btnIdx = GET_LAST(btnPPTPlayControl)

        switch (btnIdx)
        {
            case BTN_PPTPLAY_CTRL_ALL_OPEN:
                pptPlay_CmdOpenAllFiles()
                //send_command pptPlayDevices[1], 'PPT_GETLIST'
        }
    }
}

BUTTON_EVENT[gDvTPs, btnPPTPlayFileList]
{
    PUSH:
    {
        stack_var integer btnIdx, dvIdx, nFile;

        btnIdx = GET_LAST(btnPPTPlayFileList)

        dvIdx = btnIdx/8 + 1; // max 8 files
        send_string 0, "'vdvPPTPlay', ITOA(dvIdx), ' btnIdx = ', ITOA(btnIdx)"

        if (dvIdx)
        {
            nFile = (btnIdx MOD (dvIdx*8))
            send_string 0, "'vdvPPTPlay', ITOA(dvIdx), ' File idx = ', ITOA(nFile)"
            send_command pptPlayDevices[dvIdx], 'PPT_CLOSE'
            send_command pptPlayDevices[dvIdx], "'PPT_OPEN=', ITOA(nFile)"
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

