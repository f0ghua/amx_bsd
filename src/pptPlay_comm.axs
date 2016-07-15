MODULE_NAME='pptPlay_comm' (DEV vdvDEVICE, DEV dvDEVICE, char caIpAddress[])
(***********************************************************)
(*  FILE CREATED ON: 07/22/2013  AT: 12:12:22              *)
(***********************************************************)
(*                                                         *)
(***********************************************************)
(*                                                         *)
(*                                                         *)
(*                                                         *)
(*  COMMENTS:                                              *)
(*                                                         *)
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

char sModuleName[]      = 'pptPlay Comm'
char sVERSION[]         = '0.1'

MAX_STRING_SIZE         = 128
MAX_BUFFER_SIZE         = 256000

DEVICE_CONN_RETRY_TIMEOUT= 150
DEVICE_COMMS_TIMEOUT     = 20
DEVICE_MAX_VOLVAL        = 15

DEVICE_IPADDRESS         = '192.168.1.12'
DEVICE_PORT              = 3900

CCHAN_PPT_OPEN        = 1
CCHAN_PPT_CLOSE       = 2
CCHAN_PPT_PREV        = 3
CCHAN_PPT_NEXT        = 4
CCHAN_PPT_FIRSTPAGE   = 5
CCHAN_PPT_LASTPAGE    = 6
CCHAN_PPT_GETLIST     = 7

CCHAN_VEDIO_PLAY      = 11
CCHAN_VEDIO_PAUSE     = 12
CCHAN_VEDIO_STOP      = 13

CACMD_PPT_OPEN        = 1
CACMD_VEDIO_VOL       = 2

MCSEP                 = $7C   // DEVICE command separator '|'
cRDELIM               = $7C

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile char bOnline
volatile integer bStringOK = FALSE
volatile integer nDebug = 2        // toggle debug on or off
volatile integer nCommsError    // communication error
volatile integer nCurrVolume    // current volume level

volatile char caBuffer[MAX_BUFFER_SIZE]
volatile char caListStr[MAX_BUFFER_SIZE]

volatile integer ctrlChannels[] = {
    CCHAN_PPT_OPEN,
    CCHAN_PPT_CLOSE,
    CCHAN_PPT_PREV,
    CCHAN_PPT_NEXT,
    CCHAN_PPT_FIRSTPAGE,
    CCHAN_PPT_LASTPAGE,
    CCHAN_VEDIO_PLAY,
    CCHAN_VEDIO_PAUSE,
    CCHAN_VEDIO_STOP
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

// pass debug info to console
define_function fnDebug(char caMsg[])
{
    if (nDebug)
        send_string 0, "'[pptPlay-DEVICE] - ',caMsg"
}

define_function fnDevConnect()
{
    fnDebug("'ip_client_open to ', caIpAddress, ':', itoa(DEVICE_PORT), ', lport=', itoa(dvDEVICE.port)")
    ip_client_open (dvDEVICE.port, caIpAddress, DEVICE_PORT, IP_UDP_2WAY)
}

// open connection and send string to device
define_function fnSendToDevice (char cmdStr[MAX_STRING_SIZE])
{
    if (!bOnline)
    {
        fnDevConnect()
        wait 5
        {
            send_string dvDEVICE, "cmdStr"
            fnDebug("'string to DEVICE: ', cmdStr")
        }
    }
    else
    {
        send_string dvDEVICE, "cmdStr"
        fnDebug("'string to DEVICE: ', cmdStr")
    }

    // communications timeout
    wait (DEVICE_COMMS_TIMEOUT) 'CommsTimeout'
    {
        fnDebug ('No response received from device.')
        nCommsError = true
    }
}

define_function handleChannelCmd(integer chan)
{
    long v
    char cmdStr[MAX_STRING_SIZE]

    cmdStr = ''
    switch (chan)
    {
        case CCHAN_PPT_CLOSE:
        {
            fnSendToDevice("'$GB', MCSEP")
        }
        case CCHAN_PPT_PREV:
        {
            fnSendToDevice("'$GC', MCSEP")
        }
        case CCHAN_PPT_NEXT:
        {
            fnSendToDevice("'$GD', MCSEP")
        }
        case CCHAN_PPT_FIRSTPAGE:
        {
            fnSendToDevice("'$GE', MCSEP")
        }
        case CCHAN_PPT_LASTPAGE:
        {
            fnSendToDevice("'$GF', MCSEP")
        }
        case CCHAN_VEDIO_PAUSE:
        {
            fnSendToDevice("'$D', MCSEP")
        }
        case CCHAN_VEDIO_STOP:
        {
            fnSendToDevice("'$E', MCSEP")
        }
        case CCHAN_PPT_GETLIST:
        {
            fnSendToDevice("'$GZ', MCSEP")
        }
    }
}

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
            fnSendToDevice("uParameters.rawData")
        }

        case 'REINIT':
        {
            fnDevConnect()
        }

        case 'PPT_OPEN=':
        {
            v = ATOI(uParameters.param[1])
            fnSendToDevice("'$GA', ITOA(v), MCSEP")
        }

        case 'PPT_CLOSE':
        {
            fnSendToDevice("'$GB', MCSEP")
        }

        case 'PPT_PREV':
        {
            fnSendToDevice("'$GC', MCSEP")
        }

        case 'PPT_NEXT':
        {
            fnSendToDevice("'$GD', MCSEP")
        }

        case 'PPT_FIRSTPAGE':
        {
            fnSendToDevice("'$GE', MCSEP")
        }

        case 'PPT_LASTPAGE':
        {
            fnSendToDevice("'$GF', MCSEP")
        }

        case 'PPT_GETLIST':
        {
            fnSendToDevice("'$GZ', MCSEP")
        }

        case 'VEDIO_PLAY=':
        {
            v = ATOI(uParameters.param[1])
            fnSendToDevice("'$C', ITOA(v), MCSEP")
        }

        case 'VEDIO_PAUSE':
        {
            fnSendToDevice("'$D', MCSEP")
        }

        case 'VEDIO_STOP':
        {
            fnSendToDevice("'$E', MCSEP")
        }

        case 'VEDIO_VOLUME=':
        {
            v = ATOI(uParameters.param[1])
            if (cmdapi_RangeCheck(type_cast(v), 0, 100))
            {
                fnSendToDevice("'$B', ITOA(v), MCSEP")
            }
        }
    }
}

#include 'UnicodeLib.axi'

define_function char[WC_MAX_STRING_SIZE*2] fnUTF8cvTPString(char cData[])
{
    STACK_VAR widechar cSTRING1[WC_MAX_STRING_SIZE]
    STACK_VAR char cSTRING2[WC_MAX_STRING_SIZE*2]

    /* decode cData from UTF8 char array to widechar array */
    cSTRING1 = WC_DECODE(cData, WC_FORMAT_UTF8, 1)
    /* encode widechar array to TP format char array so that we can show on TP */
    cSTRING2 = WC_ENCODE(cSTRING1, WC_FORMAT_TP,1)

    SEND_STRING 0,"'DENON DEBUG: RX DATA UTF 8  DECODE-[ ',cSTRING1,' ] <',ITOA(__LINE__),'>'"
    SEND_STRING 0,"'DENON DEBUG: RX DATA UTF TP ENCODE-[ ',cSTRING2,' ] <',ITOA(__LINE__),'>'"

    //SEND_COMMAND dvTPKITSERVER,  "'^UNI-',ITOA(nLINE+210),',0,',cSTRING2" ;
    return cSTRING2;
}

/**
 * fnProcessStrFromDev
 *
 * process the reply message, parser ppt file names(now we will only get this
 * response) and then reformat to send to the vdvDevice
 *
 * @param  {[type]} char sReplyArray[] [description]
 * @return {[type]}      [description]
 */
define_function fnProcessStrFromDev(char sReplyArray[])
{
    STACK_VAR integer v
    STACK_VAR char temp[32];

    if ( nDebug )
        cmdapi_NetHex(0, "ITOA(__LINE__), 'pptPlay fnProcessStrFromDev'",
            sReplyArray, FALSE)

    // format: 1:file1.pptx;2:file2.pptx;3:file3.pptx;|
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

    fnDebug("'sReplyArray = [', sReplyArray, ']'")

    CLEAR_BUFFER caListStr
    while ( FIND_STRING(sReplyArray, ';', 1) )
    {
        temp = REMOVE_STRING(sReplyArray, ';', 1)

        // If nothing in temp, set temp = whatever's left in cmd
        if (FIND_STRING(temp, ';', 1))
        {
            SET_LENGTH_STRING(temp, LENGTH_STRING(temp)-1) // Remove ';'

            REMOVE_STRING(temp, ':', 1)
            if(LENGTH_STRING(temp) < 32)
            {
                if (!LENGTH_STRING(caListStr))
                    caListStr = temp
                else
                    caListStr = "caListStr, ':', temp"
            }
        }
    }

    fnDebug("'caListStr = [', caListStr, ']'")
    // reply string should be "LIST=file1.pptx:file2.pptx:file3.pptx"
    SEND_STRING vdvDEVICE, "'LIST=', caListStr"
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
nDebug      = true      // enable debug info by default

//CREATE_BUFFER dvDEVICE, caBuffer // only used by STRING

fnDevConnect()

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvDEVICE]
{
    ONLINE:
    {
        send_string 0, "'>>> [', sModuleName, '] DEVICE ', caIpAddress, 'is Online'"
        cancel_wait 'ConnRetryTimeout'

        bOnline = true
        SEND_STRING vdvDEVICE, 'ONLINE=1'

        // We should get the list of files when device online
        //wait 30
        //handleChannelCmd(CCHAN_PPT_GETLIST)
    }
    OFFLINE:
    {
        send_string 0, "'>>> [', sModuleName, '] DEVICE ', caIpAddress, 'is Offline'"

        bOnline = false
        SEND_STRING vdvDEVICE, 'ONLINE=0'

        cancel_wait 'ConnRetryTimeout'
        wait (DEVICE_CONN_RETRY_TIMEOUT) 'ConnRetryTimeout'
            fnDevConnect()
    }
    STRING:
    {
        // well, we got the response, stop waiting
        cancel_wait 'CommsTimeout'
        nCommsError = false

        fnDebug("'command received by ppt device: ', data.text")
        fnProcessStrfromDev(data.text);
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

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT  *)
(***********************************************************)