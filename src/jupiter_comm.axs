MODULE_NAME='jupiter_comm' (DEV vdvDEVICE, DEV dvDEVICE, char caIpAddress[])
(***********************************************************)
(*  FILE CREATED ON: 07/22/2013  AT: 12:12:22              *)
(***********************************************************)
(*                                                         *)
(***********************************************************)
(*  COMMENTS:                                              *)
(*
    Well, I don't implement a command Q here since I don't case of the
    response type yet
*)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

#include 'CMDAPI.axi'

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

MAX_STRING_SIZE             = 128
MAX_BUFFER_SIZE             = 512

DEVICE_INPUT_NUMBER         = 8
DEVICE_OUTPUT_NUMBER        = 8

DEVICE_CONN_RETRY_TIMEOUT   = 150
DEVICE_COMMS_TIMEOUT        = 20
DEVICE_MAX_VOLVAL           = 48   // vol range is -24db to 24db

DEVICE_PORT                 = 48630

AMOUNT_PER_DB               = 1365
AMOUNT_FULL_DB              = 65535

CN_INPUT_MIC                = 236   // controler number for micphone input (1 and 2)
CN_INPUT_VIDEO1             = 136   // controler number for video input
CN_INPUT_VIDEO2             = 146   // controler number for video input
CN_INPUT_VIDEO3             = 156   // controler number for video input
CN_INPUT_VIDEO4             = 166   // controler number for video input

CCHAN_INPUT1_VOLINC         = 1
CCHAN_INPUT1_VOLDEC         = 2
CCHAN_INPUT2_VOLINC         = 3
CCHAN_INPUT2_VOLDEC         = 4
CCHAN_INPUT3_VOLINC         = 5
CCHAN_INPUT3_VOLDEC         = 6
CCHAN_INPUT4_VOLINC         = 7
CCHAN_INPUT4_VOLDEC         = 8
CCHAN_INPUT5_VOLINC         = 9
CCHAN_INPUT5_VOLDEC         = 10
CCHAN_INPUT6_VOLINC         = 11
CCHAN_INPUT6_VOLDEC         = 12
CCHAN_INPUT7_VOLINC         = 13
CCHAN_INPUT7_VOLDEC         = 14
CCHAN_INPUT8_VOLINC         = 15
CCHAN_INPUT8_VOLDEC         = 16

// command type define
CMD_TYPE_UNKNOWN            = 0
CMD_RE_INPUT_VIDEO_VOLUME   = 1     // reference command: input video

integer nTL_DEQUE           = 1               // Message Deque timeline

integer USER_QUEUE          = 1
integer STATUS_QUEUE        = 2

integer TX_USER_Q_SIZE      = 512   // approx 32 commands with each 16 bytes string
integer TX_STATUS_Q_SIZE    = 512   // MAX_POLL_ITEMS * 16

char sModuleName[]          = 'SYMETRIX JUPITER Comm'
char sVERSION[]             = '0.1'
char cQDELIM[]              = {$23, $40, $23}   // Queue delimiter

char cDDELIM                = $0D               // Device command message delimiter
char cRDELIM[]              = {$0D}             // Device response message delimiter


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

structure _sDvInfo {
    integer nInputMicVolume
    integer nInputVIDEOVolume
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile char bOnline
volatile integer nDebug         // toggle debug on or off


volatile integer inputVolumes[DEVICE_INPUT_NUMBER]

volatile integer cnVIDEOInput[] = {
    CN_INPUT_VIDEO1,
    CN_INPUT_VIDEO2,
    CN_INPUT_VIDEO3,
    CN_INPUT_VIDEO4
}

volatile integer ctrlChannels[] = {
    CCHAN_INPUT1_VOLINC,
    CCHAN_INPUT1_VOLDEC,
    CCHAN_INPUT2_VOLINC,
    CCHAN_INPUT2_VOLDEC
}

volatile char sTxUserQ[TX_USER_Q_SIZE]
volatile char sTxStatusQ[TX_STATUS_Q_SIZE]

volatile integer bStringOK = FALSE
volatile integer bWaitForReply = FALSE
volatile char cCmdTypeSaved = CMD_TYPE_UNKNOWN   // indicate the last send command type
volatile char sLastCommandSent[MAX_STRING_SIZE]

volatile char sRxBuff[MAX_BUFFER_SIZE]        // buffer for incoming data from the physical device

volatile long lDequeTLtime[]    = {500}    // reply timeout of 500 milliseconds

volatile _sDvInfo uDvInfo

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

// pass debug info to console
define_function fnDebug(char caMsg[])
{
    if (nDebug)
        send_string 0, "'[jupiter-DEVICE] - ',caMsg"
}

define_function fnDevConnect()
{
    fnDebug("'ip_client_open to ', caIpAddress, ':', itoa(DEVICE_PORT)")
    ip_client_open (dvDEVICE.port, caIpAddress, DEVICE_PORT, IP_UDP_2WAY)
}
/*
define_function fnDevServerOpen()
{
    fnDebug("'ip_server_open to ', caIpAddress, ':', itoa(dvDEVICE.port)")
    ip_server_open (dvDEVICE.port, DEVICE_PORT, IP_UDP)
}

define_function fnDevServerClose()
{
    fnDebug("'ip_server_open to ', caIpAddress, ':', itoa(dvDEVICE.port)")
    ip_server_close (dvDEVICE.port)
}
*/
// open connection and send string to device
define_function fnSendToDevice (char cmdStr[MAX_STRING_SIZE])
{
    if (!bOnline)
    {
        // if device is offline, we only do connect at this time and escape
        // the command

        if (nDebug)
            send_string 0, 'fnSendToDevice: device is offline'
        fnDevConnect()
    }
    else
    {
        if (nDebug)
            cmdapi_NetHex(0, "'fnSendToDevice: sCmd = '", cmdStr, FALSE)
        send_string dvDEVICE, "cmdStr"
    }
}

define_function handleChannelCmd(integer chan)
{
    long v
    char cmdStr[MAX_STRING_SIZE]

    cmdStr = ''
    switch (chan)
    {
        case CCHAN_INPUT3_VOLINC:
        {
            fnENQ("CMD_TYPE_UNKNOWN, 'CC ', ITOA(cnVIDEOInput[3]), ' 1 4095', cDDELIM",
                USER_QUEUE)
        }
    }
}

define_function integer fnENQ(char sCmd[], integer nWhichQueue)
{
    stack_var char bResult
    stack_var integer nQLength

    if (nDebug)
        cmdapi_NetHex(0, "'fnENQ: sCmd = '", sCmd, FALSE)

    bResult = TRUE

    switch (nWhichQueue)
    {
        case USER_QUEUE:
        {
            nQLength = length_string(sTxUserQ)

            if ((nQLength + length_string(sCmd) + length_string(cQDELIM)) <
                TX_USER_Q_SIZE)
            {
                sTxUserQ = "sTxUserQ,sCmd,cQDELIM"
            }
            else
            {
                bResult = FALSE
                send_string 0, "'fnENQ (USER): No room to queue command ',sCmd"
            }
        }   // END OF - add to user Q

        case STATUS_QUEUE:
        {
            nQLength = length_string(sTxStatusQ)

            if ((nQLength + length_string(sCmd) + length_string (cQDELIM)) <
                TX_STATUS_Q_SIZE)
            {
                sTxStatusQ = "sTxStatusQ,sCmd,cQDELIM"
            }
            else
            {
                bResult = FALSE
                send_string 0,"'fnENQ (POLL): No room to queue command ',sCmd"
            }
        }   // END OF - add to status Q
    }   // END OF - switch on which queue

    // Send msg as soon as no reply pending
    if (bWaitForReply = FALSE)
    {
        sRxBuff ='';
        fnDEQ();
    }

    return bResult
}

define_function fnDEQ()
{
    stack_var char sCmd[128]

    if (nDebug == 2)
    {
        cmdapi_NetHex(0, "'fnDEQ: sTxUserQ = '", sTxUserQ, FALSE)
        cmdapi_NetHex(0, "'fnDEQ: Poll Q = '",sTxStatusQ, FALSE)
    }

    sCmd = ''

    if (find_string(sTxUserQ, cQDELIM, 1))
    {
        sCmd = remove_string(sTxUserQ, "cQDELIM", 1)
        if (nDebug)
            cmdapi_NetHex(0, "'fnDEQ (USER): sCmd = '", sCmd, FALSE)
    }
    else if (find_string(sTxStatusQ, cQDELIM, 1))
    {
        sCmd = remove_string(sTxStatusQ, "cQDELIM",1)
        if (nDebug)
           cmdapi_NetHex(0, "'fnDEQ (POLL): sCmd = '", sCmd, FALSE)
    }

    if (length_string(sCmd))
    {
        // cQDELIM is used by the queue, not used by the device
        set_length_string(sCmd, (length_string(sCmd) - length_string(cQDELIM)))

        cCmdTypeSaved = get_buffer_char(sCmd)
        fnSendToDevice(sCmd)
        sLastCommandSent = sCmd
        bWaitForReply = TRUE

        // Start reply timout timer
        // if no reply need, then send next command after timeout;
        // if reply is needed, then send next command either reply got or timeout
        if (!TIMELINE_ACTIVE(nTL_DEQUE))
        {
            TIMELINE_CREATE(nTL_DEQUE, lDequeTLtime, 1, TIMELINE_ABSOLUTE, TIMELINE_ONCE)
        }
    }
    else  // Nothing left to send
    {
        if (TIMELINE_ACTIVE(nTL_DEQUE))
        {
            TIMELINE_KILL(nTL_DEQUE)
        }
    }
}   // END OF - fnDEQ

define_function fnProcessAPICommands(char cmdArray[])
{
    stack_var char cmdName[32]
    stack_var _sCMD_PARAMETERS uParameters
    stack_var integer v, v1, v2
    stack_var integer i


    if ( nDebug )
        cmdapi_NetHex(0, "itoa(__LINE__), ' fnProcessAPICommands '", cmdArray, TRUE)

    uParameters.count = 0
    cmdapi_ParseCommand(cmdArray, "':'", cmdName, uParameters)

    switch(cmdName)
    {
        case 'DEBUG=' :
        {
            v = atoi(uParameters.param[1])
            if (cmdapi_RangeCheck(type_cast(v), 0, 2) )
            {
                nDebug = v
                if (nDebug)
                {
                    send_string 0, "'>>> [', sModuleName, '] DEBUG IS NOW ON'"
                    send_string vdvDEVICE, "'DEBUG=', ITOA(nDebug)"   // turn UI debug ON
                }
                else
                {
                    send_string 0, "'>>> [', sModuleName, '] DEBUG IS NOW OFF'"
                    send_string vdvDEVICE,"'DEBUG=', ITOA(nDebug)"   // turn UI debug OFF
                }
            }
            else
                send_string 0,"'ERROR: Invalid argument for DEBUG ', uParameters.param[1]"
        }

        case 'DEBUG?' :
        {
            send_string vdvDEVICE, "'DEBUG=', ITOA(nDebug)"
            send_string 0, "'DEBUG=', ITOA(nDebug)"
        }

        case 'passthru=':
        case 'PASSTHRU=':
        {
            fnENQ("CMD_TYPE_UNKNOWN, uParameters.rawData", USER_QUEUE)
        }

        case 'INPUT_MIC_VOLINC':
        {
            fnENQ("CMD_TYPE_UNKNOWN, 'CC ',
                ITOA(CN_INPUT_MIC), ' 1 4095', cDDELIM", USER_QUEUE)
        }

        case 'INPUT_MIC_VOLDEC':
        {
            fnENQ("CMD_TYPE_UNKNOWN, 'CC ',
                ITOA(CN_INPUT_MIC), ' 0 4095', cDDELIM", USER_QUEUE)
        }

        case 'INPUT_MIC_VOLUME=':
        {
            v = ATOI(uParameters.param[1])

            if (cmdapi_RangeCheck(type_cast(v), 0, 48))
            {
                v = (v *  AMOUNT_PER_DB)
                fnENQ("CMD_TYPE_UNKNOWN, 'CS ',
                    ITOA(CN_INPUT_MIC), ' ', ITOA(v), cDDELIM", USER_QUEUE)
            }
        }

        case 'INPUT_VIDEO_VOLINC':
        {
            for (i = LENGTH_ARRAY(cnVIDEOInput); i > 0; i--)
            {
                fnENQ("CMD_TYPE_UNKNOWN, 'CC ',
                    ITOA(cnVIDEOInput[i]), ' 1 4095', cDDELIM", USER_QUEUE)
            }
        }

        case 'INPUT_VIDEO_VOLDEC':
        {
            for (i = LENGTH_ARRAY(cnVIDEOInput); i > 0; i--)
            {
                fnENQ("CMD_TYPE_UNKNOWN, 'CC ',
                    ITOA(cnVIDEOInput[i]), ' 0 4095', cDDELIM", USER_QUEUE)
            }
        }

        case 'INPUT_VIDEO_VOLUME=':
        {
            v = ATOI(uParameters.param[1])

            if (cmdapi_RangeCheck(type_cast(v), 0, 48))
            {
                v = (v *  AMOUNT_PER_DB)
                for (i = LENGTH_ARRAY(cnVIDEOInput); i > 0; i--)
                {
                    fnENQ("CMD_TYPE_UNKNOWN, 'CS ',
                        ITOA(cnVIDEOInput[i]), ' ', ITOA(v), cDDELIM", USER_QUEUE)
                }
            }
        }

        case 'INPUT_VIDEO_VOLUME?':
        {
            fnENQ("CMD_RE_INPUT_VIDEO_VOLUME, 'GS ', ITOA(cnVIDEOInput[1]), cDDELIM",
                 USER_QUEUE)
        }

    }
}

define_function fnProcessStrFromDev(char sReplyArray[])
{
    integer v
    char cCmdType

    if ( nDebug )
        cmdapi_NetHex(0, "ITOA(__LINE__), 'fnProcessStrFromDev'",
            sReplyArray, FALSE)

    if (!FIND_STRING(sReplyArray, "cRDELIM", 1))
    {
        // no delimeter found, it's a partial message, just return to wait
        // following
        bStringOK = FALSE
        return
    }
    else
    {
        bStringOK = TRUE
    }

    SET_LENGTH_STRING(sReplyArray, (LENGTH_STRING(sReplyArray) - LENGTH_STRING(cRDELIM)))

    switch (cCmdTypeSaved)
    {
        case CMD_RE_INPUT_VIDEO_VOLUME:
        {
            uDvInfo.nInputVIDEOVolume = (ATOI(sReplyArray)/AMOUNT_PER_DB)

            if (cmdapi_RangeCheck(type_cast(uDvInfo.nInputVIDEOVolume), 0, DEVICE_MAX_VOLVAL))
            {
                SEND_STRING vdvDEVICE, "'INPUT_VIDEO_VOLUME=', ITOA(uDvInfo.nInputVIDEOVolume)"
            }
        }
    }

    if (bWaitForReply)
    {
        bWaitForReply = FALSE;
    }

}

define_function char[MAX_STRING_SIZE] ipError (long err)
{
    switch (err)
    {
        case 0:
            return "";
        Case 2:
            return "'IP ERROR (',itoa(err),'): General Failure (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
        case 4:
            return "'IP ERROR (',itoa(err),'): unknown host or DNS error (IP_CLIENT_OPEN)'";
        case 6:
            return "'IP ERROR (',itoa(err),'): connection refused (IP_CLIENT_OPEN)'";
        case 7:
            return "'IP ERROR (',itoa(err),'): connection timed out (IP_CLIENT_OPEN)'";
        case 8:
            return "'IP ERROR (',itoa(err),'): unknown connection error (IP_CLIENT_OPEN)'";
        case 14:
            return "'IP ERROR (',itoa(err),'): local port already used (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
        case 16:
            return "'IP ERROR (',itoa(err),'): too many open sockets (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
        case 10:
            return "'IP ERROR (',itoa(err),'): Binding error (IP_SERVER_OPEN)'";
        case 11:
            return "'IP ERROR (',itoa(err),'): Listening error (IP_SERVER_OPEN)'";
        case 15:
            return "'IP ERROR (',itoa(err),'): UDP socket already listening (IP_SERVER_OPEN)'";
        case 9:
            return "'IP ERROR (',itoa(err),'): Already closed (IP_CLIENT_CLOSE/IP_SERVER_CLOSE)'";
        case 17:
            return "'IP ERROR (',itoa(err),'): Local port not open, can not send string (IP_CLIENT_OPEN)'";
        default:
            return "'IP ERROR (',itoa(err),'): Unknown'";
    }
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

bOnline     = false
nDebug      = false      // enable debug info by default

CREATE_BUFFER dvDEVICE, sRxBuff // only used by STRING

TIMELINE_CREATE(nTL_Deque, lDequeTLtime, 1, TIMELINE_RELATIVE, TIMELINE_REPEAT)

fnDevConnect()

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvDEVICE]
{
    ONLINE:
    {
        bOnline = true

        fnDebug('DEVICE is Online')
        SEND_STRING vdvDEVICE, 'ONLINE=1'

        fnENQ("CMD_RE_INPUT_VIDEO_VOLUME, 'GS ', ITOA(cnVIDEOInput[1]), cDDELIM",
                USER_QUEUE)
        // Do initalization when device online
        //handleChannelCmd(CCHAN_INIT)
    }
    OFFLINE:
    {
        bOnline = false
        fnDebug('DEVICE is Offline')
        SEND_STRING vdvDEVICE, 'ONLINE=0'

        cancel_wait 'ConnRetryTimeout'
        wait (DEVICE_CONN_RETRY_TIMEOUT) 'ConnRetryTimeout'
            fnDevConnect()
    }
    STRING:
    {
        fnProcessStrfromDev(sRxBuff)

        // bStringOK indicates whether a complete message was received. If so,
        // then clear the receive buffer, and proceed with the next message. If
        // not, wait for the next string event to trigger.
        if (bStringOK == TRUE)
        {
            if (nDebug)
            {
                SEND_STRING 0, "'received full message, dequeue next cmd'"
            }
            if (TIMELINE_ACTIVE(nTL_DEQUE))
            {
                TIMELINE_KILL(nTL_DEQUE)
            }
            sRxBuff =''
            fnDEQ();
        }
    }
    ONERROR:
    {
        fnDebug("ipError(data.number)")
        bOnline = false

        cancel_wait 'ConnRetryTimeout'
        wait (DEVICE_CONN_RETRY_TIMEOUT) 'ConnRetryTimeout'
            fnDevConnect()
    }
}

DATA_EVENT[vdvDEVICE]
{
    COMMAND:
    {
        fnDebug("'command received by module: ', data.text")

        if (!find_string(DATA.TEXT, 'PASSTHRU=', 1) &&
            !find_string(DATA.TEXT, 'passthru=', 1))
        {
            DATA.TEXT = upper_string(DATA.TEXT)
        }

        fnProcessAPICommands(DATA.TEXT)
    }
}

CHANNEL_EVENT[vdvDEVICE, ctrlChannels]
{
    ON:
    {
        handleChannelCmd(channel.channel)
    }
}

TIMELINE_EVENT[nTL_DEQUE] // Timeout - no reply
{
    if (nDebug)
    {
        SEND_STRING 0, "'No reply received; clear flag, dequeue next cmd'"
    }

    bWaitForReply = FALSE
    // clear out anything in rcv buffer
    sRxBuff = '';

    fnDEQ();  // Send next command in queue
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT  *)
(***********************************************************)