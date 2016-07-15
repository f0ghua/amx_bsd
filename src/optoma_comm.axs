MODULE_NAME='OPTOMA_COMM' (DEV vdvDEVICE, DEV dvDEVICE)
(*{{PS_SOURCE_INFO(PROGRAM STATS)                          *)
(***********************************************************)
(*  FILE CREATED ON: 3/17/04                               *)
(***********************************************************)
(*  ORPHAN_FILE_PLATFORM: 1                                *)
(***********************************************************)
(* COMMENTS:
*
*)

#include 'SNAPI.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

char CR         = $0D
char LF         = $0A

char ASCII      = 1                 // NetHex translates ASCII characters
char NO_ASCII   = 0                 // NetHex does not translate ASCII characters

char sModuleName[] = 'OPTOMA HSF863UT Comm'
char sVERSION[] = '0.1'
char cQDELIM[]  = {$23, $40, $23}   // Queue delimiter

char cDDELIM    = $0D               // Device command message delimiter
char cRDELIM[]  = {$0D}             // Device response message delimiter

integer FALSE   = 0
integer TRUE    = 1

integer MAX_CMD_SIZE = 128

integer MAX_PARAMS = 5

integer USER_QUEUE = 1
integer STATUS_QUEUE = 2

integer TX_USER_Q_SIZE = 512        // approx 32 commands with each 16 bytes string
integer MAX_POLL_ITEMS = 32         // approx 32 commands with each 16 bytes string
integer TX_STATUS_Q_SIZE = 512      // MAX_POLL_ITEMS * 16

integer nPOLLTL     = 1               // poll timeline identifier
integer nTL_DEQUE   = 2               // Message Deque timeline
integer nTL_COUNTER = 3

integer UNKNOWN = $FFFF

long MIN_POLL_TIME      = 1             // 1 second in seconds
long MAX_POLL_TIME      = 360000        // 1 hour in seconds
long DEFAULT_POLL_TIME  = 5000          // 2 seconds in milliseconds

integer INFO_POWER_STANDBY  = 0
integer INFO_POWER_WARMING  = 1
integer INFO_POWER_COOLING  = 2

integer POWER_STATE_OFF     = 0
integer POWER_STATE_ON      = 1
integer POWER_STATE_WARMING = 2
integer POWER_STATE_COOLING = 3
integer POWER_STATE_TOGGLE  = 4

// reference command always need parse the response
// id 0 ~ 100
char CMD_RE_POWER            = 10       // reference command power
char CMD_RE_INPUTSOURCE      = 11

// operate command may have or no response
// id 101 ~ 255
char CMD_OP_UNKNOWN          = 255      // operate power command, no response need

integer TYPE_WARMUP_TIME        = 0
integer TYPE_COOLDOWN_TIME      = 1

integer DEFAULT_COOLDOWN_TIME   = 25
integer DEFAULT_WARMUP_TIME     = 30

char cmdRePowerState[]  = {'~', $30, $30, '1', '2', '4', $20, '1', cDDELIM}
char cmdOpPowerOn[]     = {'~', $30, $30, '0', '0', $20, '1', cDDELIM}
char cmdOpPowerOff[]    = {'~', $30, $30, '0', '0', $20, '0', cDDELIM}

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

// for the command parser
structure _sCMD_PARAMETERS
{
    integer count
    char    param[MAX_PARAMS][32]
    char    rawdata[MAX_CMD_SIZE]
}

STRUCTURE _sPoll_Item
{
    char    cKey
    char    cKeyOp
    char    sCmd[MAX_CMD_SIZE]
};

structure _sDV_STATES
{
    integer nPower
    integer nInput
    integer nWarming
    integer nCooling
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile integer nWarmUpTime = DEFAULT_WARMUP_TIME
volatile integer nCoolDownTime = DEFAULT_COOLDOWN_TIME

volatile integer bStringOK = FALSE
volatile integer bWaitForReply = FALSE
volatile integer nReplyCounter = 0      // used to track number of replies from device
volatile char bAckResponse = 0  // indicate last command ACK and RESPONSE state

volatile integer nDebug = 0   // determines if debugging is on or off
volatile long lBaudRate = 9600

// Some projector response different cmd with same messages, so we use command
// type to distingush them
volatile char cCmdTypeSaved = CMD_OP_UNKNOWN   // indicate the last send command type
volatile char sLastCommandSent[MAX_CMD_SIZE]

volatile char sRxBuff[512]        // buffer for incoming data from the physical device

volatile char sTxUserQ[TX_USER_Q_SIZE]
volatile char sTxStatusQ[TX_STATUS_Q_SIZE]

volatile long lPollTLtime[]     = {DEFAULT_POLL_TIME}    // default polling time of 3 minutes
volatile long lDequeTLtime[]    = {500}    // reply timeout of 500 milliseconds
volatile long lCounterTLtime[]  = {1000}   // warming/cooling counter time of 1 second

volatile long lCoolCnterTLtime[255]
volatile long lWarmCnterTLtime[255]

volatile _sPoll_Item uPollList[MAX_POLL_ITEMS]
volatile integer nNumberPollItems

volatile _sDV_STATES uDvState
volatile char bStartUpSyncState

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

define_function integer NetHex(dev dvDevice, char sPrefix[],
        char sBuff[], char bAsciiFlag)
{
    stack_var char     sLogBuff[1024], sTempBuff[1024]
    stack_var integer  n, lineno, nLength

    for (n = 1; n <= LENGTH_STRING(sBuff); n++)
    {
        if  ((sBuff[n] >= $21 && sBuff[n] <= $7E) && (bAsciiFlag) )
            sLogBuff = "sLogBuff, sBuff[n]"
        else
            sLogBuff = "sLogBuff, ' ', format('0x%02X', sBuff[n]), ' '"
    }
    while (LENGTH_STRING(sLogBuff) > 75) // chop up output string if it is >75
    {
        sTempBuff = GET_BUFFER_STRING(sLogBuff, 75)
        SEND_STRING dvDevice, "sPrefix,sTempBuff,$D,$A"
    }
    if (length_string (sLogBuff))
        SEND_STRING dvDevice, "sPrefix,sLogBuff,$D,$A"
}

define_function fnCmd_referencePower()
{
    fnENQ("CMD_RE_POWER, cmdRePowerState", USER_QUEUE)
}

define_function fnCmd_operationPowerOn()
{
    fnENQ("CMD_OP_UNKNOWN, cmdOpPowerOn", USER_QUEUE)
    fnENQ("CMD_RE_POWER, cmdRePowerState", USER_QUEUE)
}

define_function fnCmd_operationPowerOff()
{
    fnENQ("CMD_OP_UNKNOWN, cmdOpPowerOff", USER_QUEUE)
    fnENQ("CMD_RE_POWER, cmdRePowerState", USER_QUEUE)
}

define_function char fnIsNoResponseCmd(char cmdType)
{
    if (cmdType == CMD_OP_UNKNOWN)
        return TRUE

    return FALSE
}

define_function integer fnENQ(char sCmd[], integer nWhichQueue)
{
    stack_var char bResult
    stack_var integer nQLength

    if (nDebug)
        NetHex(0, "'fnENQ: sCmd = '", sCmd, NO_ASCII)

    bResult = TRUE

    switch (nWhichQueue)
    {
        case USER_QUEUE:
        {
            nQLength = LENGTH_STRING(sTxUserQ)

            if ((nQLength + LENGTH_STRING(sCmd) + LENGTH_STRING(cQDELIM)) <
                TX_USER_Q_SIZE)
            {
                sTxUserQ = "sTxUserQ,sCmd,cQDELIM"
            }
            else
            {
                bResult = FALSE
                SEND_STRING 0, "'fnENQ (USER): No room to queue command ',sCmd"
            }
        }   // END OF - add to user Q

        case STATUS_QUEUE:
        {
            nQLength = LENGTH_STRING(sTxStatusQ)

            if ((nQLength + LENGTH_STRING(sCmd) + LENGTH_STRING (cQDELIM)) <
                TX_STATUS_Q_SIZE)
            {
                sTxStatusQ = "sTxStatusQ,sCmd,cQDELIM"
            }
            else
            {
                bResult = FALSE
                SEND_STRING 0,"'fnENQ (POLL): No room to queue command ',sCmd"
            }
        }   // END OF - add to status Q
    }   // END OF - switch on which queue

    // Send msg as soon as no reply pending
    if (bWaitForReply = FALSE)
    {
        sRxBuff ='';
        fnDEQ();
    }

    RETURN bResult
}

define_function fnDEQ()
{
    stack_var char sCmd[128]

    if (nDebug == 2)
    {
        NetHex(0, "'fnDEQ: sTxUserQ = '", sTxUserQ, NO_ASCII)
        NetHex(0, "'fnDEQ: Poll Q = '",sTxStatusQ, NO_ASCII)
    }

    sCmd = ''

    if (FIND_STRING(sTxUserQ, cQDELIM, 1))
    {
        sCmd = REMOVE_STRING(sTxUserQ, "cQDELIM", 1)
        if (nDebug)
            NetHex(0, "'fnDEQ (USER): sCmd = '", sCmd, NO_ASCII)
    }
    else if (FIND_STRING(sTxStatusQ, cQDELIM, 1))
    {
        sCmd = REMOVE_STRING (sTxStatusQ, "cQDELIM",1)
        if (nDebug)
           NetHex(0, "'fnDEQ (POLL): sCmd = '", sCmd, NO_ASCII)
    }

    if (LENGTH_STRING(sCmd))
    {
        // cQDELIM is used by the queue, not used by the device
        SET_LENGTH_STRING(sCmd, (LENGTH_STRING(sCmd) - LENGTH_STRING(cQDELIM) ) )

        cCmdTypeSaved = GET_BUFFER_CHAR(sCmd)
        fnSendToDevice(sCmd)
        sLastCommandSent = sCmd
        bWaitForReply = TRUE

        // if no reply need, then send next command after timeout;
        // if reply needed, then send next command either reply got or timeout
        if (!TIMELINE_ACTIVE(nTL_DEQUE))  // Start reply timout timer
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

define_function integer fnRangeCheck(slong value, slong min, slong max)
{
    if ((value >= min) and (value <= max))
        return TRUE
    else
        return FALSE
}

define_function integer fnParseCommand(char cmd[], char separator [],
                               char name[], _sCMD_PARAMETERS params)
{
    stack_var char p        // use character to save space
    stack_var char temp[32]

    if ( find_string(cmd,"'='",1) )
    {
        name = REMOVE_STRING(cmd,"'='",1)
    }
    else
    if ( find_string(cmd,"'?'",1) )
    {
        name = REMOVE_STRING(cmd,"'?'",1)
    }
    ELSE
    {
        name = cmd
        return 0
    }

    ///////////////////////////////////////////////////////////////////////////
    // Strip the string down into parameters separated by ':'
    //
    // Make the whole remaining buffer available for later if needed
    params.rawdata = cmd

    // Tokenize the params
    p = 0
    params.count = 0
    while ((LENGTH_STRING(cmd)) and (params.count <= MAX_PARAMS))
    {
        p++;
        // Strip off each param and put into its index place in array
        temp = REMOVE_STRING(cmd, "separator", 1)
        // May only be 1 param so no trailing ':'
        //
        // If nothing in temp, set temp = whatever's left in cmd
        if (!LENGTH_STRING(temp))
        {
            temp = cmd;
            CLEAR_BUFFER cmd;
            if (LENGTH_STRING(temp) < 32)
            {
                params.param[p] = temp;
                params.count++;
            }
        }
        else
        {
            SET_LENGTH_STRING(temp, LENGTH_STRING(temp)-1); // Remove ':'
            if(LENGTH_STRING(temp) < 32)
            {
                params.param[p] = temp;
                params.count++;
            }
        }
    }
    return params.count;
}

define_function fnSendToDevice(char sData[])
{
    IF (nDebug)
        NetHex(0, "'fnSendToDevice: data sent is '", sData, NO_ASCII)

    SEND_STRING dvDEVICE, "sData"
}

define_function fnInitWarmCoolTLTime(char type)
{
    integer i
    long mSec

    mSec = 1000

    if (type == TYPE_WARMUP_TIME)
    {
        for (i = 1; i <= nWarmUpTime; i++)
        {
            lWarmCnterTLtime[i] = mSec
            mSec = mSec + 1000
        }
    }
    else
    {
        for (i = 1; i <= nCoolDownTime; i++)
        {
            lCoolCnterTLtime[i] = mSec
            mSec = mSec + 1000
        }
    }
}

// sData should has cmd type at the first char
define_function integer fnAddPollItem(char sData1[])
{
    stack_var integer i
    stack_var char cKey
    stack_var integer nTempInt

    if (LENGTH_STRING(sData1) > MAX_LENGTH_ARRAY(uPollList[1].sCmd))
    {
        SEND_STRING 0, "'fnAddPollItem():  input data length is exceed!'"
        return 0
    }

    // Make sure we have room in the list
    if (nNumberPollItems == MAX_POLL_ITEMS)
    {
        SEND_STRING 0, "'fnAddPollItem(): PollItems array is full!'"
        return 0
    }

    // Don't want duplicates in the list
    for (i = 1; i <= nNumberPollItems; i++)
    {
        if ((sData1 == uPollList[i].sCmd))
        {
            SEND_STRING 0,('fnAddPollItem(): command already in notify list')
            return 0
        }
    }

    // Not in the list so stick it in
    nNumberPollItems++
    uPollList[nNumberPollItems].sCmd = sData1

    return nNumberPollItems

}

// sData has already prepend with the cmd type
define_function fnGet_dvInfo(char sData[], integer nWhichQueue)
{
    fnEnq("sData", nWhichQueue)
}

// Name   : ==== fnProcessAPICommands ====
// Purpose:  parses the command strings AND takes the
//           appropriate action or actions
//
// Params : (1) sCmdArray passed as data.text from the data event
//
// Returns: None
// Notes  : None
//
define_function fnProcessAPICommands(char sCmdArray[])
{
    stack_var char sName[32]
    stack_var char cType
    stack_var _sCMD_PARAMETERS uParameters
    stack_var integer nTempValue, nTempValue1, nTempValue2
    stack_var integer nDEVICE
    stack_var long lTempBaudRate
    stack_var integer i
    stack_var integer nAddressType

    if ( nDebug )
        NetHex(0, "ITOA(__LINE__), ' fnProcessAPICommands '", sCmdArray, ASCII)

    uParameters.count = 0
    fnParseCommand(sCmdArray, "':'", sName, uParameters)

    switch(sName)
    {
        case 'DEBUG=' :
        {
            nTempValue = ATOI(uParameters.param[1])
            if (fnRangeCheck(TYPE_CAST(nTempValue), 0, 2) )
            {
                nDebug = nTempValue
                if (nDebug)
                {
                    SEND_STRING 0, "'>>> [', sModuleName, '] DEBUG IS NOW ON'"
                    SEND_STRING vdvDEVICE,"'DEBUG=',ITOA(nTempValue)" // turn UI debug ON
                }
                else
                {
                    SEND_STRING 0, "'>>> [', sModuleName, '] DEBUG IS NOW OFF'"
                    SEND_STRING vdvDEVICE,"'DEBUG=0'"             // turn UI debug OFF
                }
            }
            else
                SEND_STRING 0,"'ERROR: Invalid argument for DEBUG ', uParameters.param[1]"
        }

        case 'DEBUG?' :
        {
            SEND_STRING vdvDEVICE, "'DEBUG=', ITOA(nDebug)"
            SEND_STRING 0, "'DEBUG=', ITOA(nDebug)"
        }

        case 'passthru=':
        case 'PASSTHRU=':
        {
            fnEnq("CMD_OP_UNKNOWN, uParameters.rawData", USER_QUEUE)
        }
        case 'POLLTIME=':
        {
            stack_var integer nValue

            nValue = ATOI(uParameters.param[1])
            //
            // kills and restarts timeline even if value is the same as it was previously
            //
            if (nValue)
            {
                if ((nValue >= MIN_POLL_TIME) && (nValue  <= MAX_POLL_TIME))
                {
                    if (TIMELINE_ACTIVE(nPOLLTL) )
                        TIMELINE_KILL(nPOLLTL)

                    lPollTLtime[1] = nValue * 1000
                    TIMELINE_CREATE(nPOLLTL, lPollTLtime, 1,
                        TIMELINE_RELATIVE, TIMELINE_REPEAT)
                }
                else // nValue outside valid range
                   SEND_STRING 0, "'Invalid POLLTIME value :', ITOA(nValue)"
            }
            else // nValue = 0
            {
                lPollTLtime[1] = nValue         // set to 0 for correct POLLTIME? value
                if (TIMELINE_ACTIVE(nPOLLTL) )  // avoid error if it's not active
                    TIMELINE_KILL(nPOLLTL)
            }
        }
        case 'POLLTIME?':
        {
            SEND_STRING vdvDEVICE, "'POLLTIME=', ITOA(lPollTLtime[1]/1000)"
        }
        CASE 'ADD_POLL=':
        {
            nTempValue = 0
            IF (uParameters.count = 1)
            {
                nTempValue = fnAddPollItem(uParameters.param[1])

                SEND_STRING vdvDEVICE,"'ADD_POLL=',ITOA(nTempValue)"
             }
             ELSE
                 SEND_STRING 0,"'ERROR - invalid number of arguments for ADD_POLL ',ITOA(uParameters.count)"

        }
        CASE 'AMX_BAUD=':
        {
           lTempBaudRate = ATOI(uParameters.param[1])
           IF ( (lTempBaudRate == 1200)
                 || (lTempBaudRate == 2400)
                 || (lTempBaudRate == 4800)
                 || (lTempBaudRate == 9600)
                 || (lTempBaudRate == 19200)
                 || (lTempBaudRate == 38400)
                 || (lTempBaudRate == 57600) )
           {
                lBaudRate = lTempBaudRate
                SEND_COMMAND dvDEVICE, "'SET BAUD ',ITOA(lBaudRate),',N,8,1 485 DISABLE'"

                SEND_STRING vdvDEVICE, "'AMX_BAUD=',ITOA(lBaudRate)"
           }
           ELSE
           {
                send_string 0, "'ERROR: Invalid argument for Baud Rate'"
           }
        }
        CASE 'AMX_BAUD?':
        {
            SEND_STRING vdvDEVICE,"'AMX_BAUD=', ITOA(lBaudRate)"
        }
        CASE 'POWER=':
        {
           nTempValue = ATOI(uParameters.param[1])

           switch (nTempValue)
           {
                case POWER_STATE_OFF:
                    fnCmd_operationPowerOff()
                case POWER_STATE_ON:
                    fnCmd_operationPowerOn()
                case POWER_STATE_TOGGLE:
                {
                    if (uDvState.nPower == POWER_STATE_OFF)
                        fnCmd_operationPowerOn()
                    else
                        fnCmd_operationPowerOff()
                }
                default:
                    SEND_STRING 0, "'ERROR: Invalid argument for Power'"
           }
        }
        CASE 'POWER?':
        {
            SEND_STRING vdvDEVICE, "'POWER=', ITOA(uDvState.nPower)"
        }

    }
}

// Name   : ==== fnProcessStrFromDev ====
//
// Purpose: parses the responses from the device and takes the appropriate
//          action(s)
//
// Params : (1) sReplyArray passed as the individual parsed reply
//           from the receive buffer
//
// Returns: None
// Notes  : None
//
define_function fnProcessStrFromDev(char sReplyArray[])
{
    char sMsg[128]
    char cCmdType
    integer nTempValue

    if ( nDebug )
        NetHex(0, "ITOA(__LINE__), 'fnProcessStrFromDev'",
            sReplyArray, NO_ASCII)

    if (!FIND_STRING(sReplyArray, "cRDELIM", 1))
    {
        bStringOK = FALSE
        return
    }
    else
    {
        bStringOK = TRUE
    }

    // We also handle with the response message end with $0D and $0A
    sMsg = REMOVE_STRING(sReplyArray, "cRDELIM", 1)
    SET_LENGTH_STRING(sMsg, (LENGTH_STRING(sMsg) - LENGTH_STRING(cRDELIM)))

    sMsg = UPPER_STRING(sMsg)
    select
    {
        active ((sMsg == 'F')||(sMsg == 'P')):
        {
                    // we don't care about command fail or pass
        }
        active (FIND_STRING(sMsg, 'OK', 1)):
        {
            // only standby response OK0, else(warming/cooling/ready) all return OK1
            REMOVE_STRING(sMsg, 'OK', 1)
            switch (cCmdTypeSaved)
            {
                case CMD_RE_POWER:
                {
                    nTempValue = ATOI(sMsg)
                    if (fnRangeCheck(TYPE_CAST(nTempValue), 0, 1))
                    {
                        if (nTempValue ==  POWER_STATE_OFF)
                        {
                            uDvState.nPower = nTempValue
                            SEND_STRING vdvDEVICE, "'POWER=', ITOA(uDvState.nPower)"
                        }
                        else
                        {
                            // warming/cooling/ready all return with OK1, so
                            // we only update power state when startup sync

                            if (bStartUpSyncState)
                            {
                                bStartUpSyncState = !bStartUpSyncState

                                uDvState.nPower = nTempValue
                                SEND_STRING vdvDEVICE, "'POWER=', ITOA(uDvState.nPower)"
                            }
                        }
                    }
                }
                case CMD_RE_INPUTSOURCE:
                {
                    uDvState.nInput = ATOI(sMsg)

                    SEND_STRING vdvDEVICE, "'INPUT=', ITOA(uDvState.nInput)"
                }
            }
        }
        active (FIND_STRING(sMsg, 'INFO', 1)):
        {
            REMOVE_STRING(sMsg, 'INFO', 1)
            nTempValue = ATOI(sMsg)
            if (fnRangeCheck(TYPE_CAST(nTempValue), 0, 2))
            {
                switch (nTempValue)
                {
                    case INFO_POWER_STANDBY:
                        if (uDvState.nPower != POWER_STATE_OFF)
                        {
                            uDvState.nPower = POWER_STATE_OFF

                            if (TIMELINE_ACTIVE(nTL_COUNTER))
                            {
                                TIMELINE_KILL(nTL_COUNTER)
                            }
                        }
                    case INFO_POWER_WARMING:
                        if (uDvState.nPower != POWER_STATE_WARMING)
                        {
                            uDvState.nPower = POWER_STATE_WARMING
                             // start the cooling/warming counter
                            if (!TIMELINE_ACTIVE(nTL_COUNTER))
                            {
                                 TIMELINE_CREATE(nTL_COUNTER, lWarmCnterTLtime,
                                    nWarmUpTime,
                                    TIMELINE_ABSOLUTE, TIMELINE_ONCE)
                            }
                        }
                    case INFO_POWER_COOLING:
                        if (uDvState.nPower != POWER_STATE_COOLING)
                        {
                            uDvState.nPower = POWER_STATE_COOLING

                            if (!TIMELINE_ACTIVE(nTL_COUNTER))
                            {
                                TIMELINE_CREATE(nTL_COUNTER, lCoolCnterTLtime,
                                    nCoolDownTime,
                                    TIMELINE_ABSOLUTE, TIMELINE_ONCE)
                            }
                        }
                }

                SEND_STRING vdvDEVICE, "'POWER=', ITOA(uDvState.nPower)"
            }
        }

    }

    // A reference command need confirmed with both ACK and RESPONSE message
    // while a operation command need ACK only
    if (bWaitForReply)
    {
        bWaitForReply = FALSE;
    }

}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

uDvState.nWarming = nWarmUpTime
uDvState.nCooling = nCoolDownTime

fnInitWarmCoolTLTime(TYPE_WARMUP_TIME)
fnInitWarmCoolTLTime(TYPE_COOLDOWN_TIME)

CREATE_BUFFER dvDEVICE, sRxBuff
//TIMELINE_CREATE(nPOLLTL, lPollTLtime, 1, TIMELINE_RELATIVE, TIMELINE_REPEAT)
//TIMELINE_CREATE(nTL_Deque, lDequeTLtime, 1, TIMELINE_RELATIVE, TIMELINE_REPEAT)

(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT

CHANNEL_EVENT[vdvDEVICE, PWR_ON]
CHANNEL_EVENT[vdvDEVICE, PWR_OFF]
{
    ON:
    {
        SWITCH(CHANNEL.CHANNEL)
        {
            CASE PWR_ON:        fnCmd_operationPowerOn()
            CASE PWR_OFF:       fnCmd_operationPowerOff()
        }
    }
}

DATA_EVENT[dvDEVICE]
{
    ONLINE:
    {
        SEND_COMMAND dvDEVICE,"'SET BAUD ',ITOA(lBaudRate),',N,8,1 485 DISABLE'"
        SEND_COMMAND dvDEVICE,'HSOFF'
        SEND_COMMAND dvDEVICE,'XOFF'

        //fnAddPollItem("CMD_RE_POWER, cmdRePowerState")
        bStartUpSyncState = TRUE
        fnCmd_referencePower()

    } //END ONLINE
    OFFLINE:
    {
    } //END OFFLINE
    STRING:
    {

        // We will still only get one response at a time (we send next command
        // only the previous one has been responsed), so I don't handle the
        // case of multiple responses being received, i.e. (using a while
        // loop)  but do handle the case of a partial message being received.

        // partial messages will get cleared from the buffer by the regular
        // reply timeout.

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
    } // END OF - DATA_EVENT STRING
} //END DATA_EVENT[dvDEVICE]

DATA_EVENT[vdvDEVICE]
{
    COMMAND:
    {
        if (!FIND_STRING(DATA.TEXT, 'PASSTHRU=', 1) &&
            !FIND_STRING(DATA.TEXT, 'passthru=', 1))
        {
            DATA.TEXT = UPPER_STRING(DATA.TEXT)
        }

        fnProcessAPICommands(DATA.TEXT)
    }
} //END DATA_EVENT[vdvDEVICE]

TIMELINE_EVENT[nTL_COUNTER]
{
    if (nDebug == 2)
        SEND_STRING 0,"'counting now !'"

    switch (uDvState.nPower)
    {
        case POWER_STATE_WARMING:
        {
            uDvState.nWarming = nWarmUpTime - TIMELINE.SEQUENCE

            SEND_STRING vdvDEVICE, "'WARMING=', ITOA(uDvState.nWarming)"
            if (uDvState.nWarming == 0)
            {
                // send power query again to ensure the power on
                // fnCmd_referencePower()

                // Since fnCmd_referencePower can't get the right confirm of
                // power on(both warming and ready state return OK1, so we
                // emulate the ready state here)
                uDvState.nPower = POWER_STATE_ON
                SEND_STRING vdvDEVICE, "'POWER=', ITOA(uDvState.nPower)"
            }
        }
        case POWER_STATE_COOLING:
        {
            uDvState.nCooling = nCoolDownTime - TIMELINE.SEQUENCE

            SEND_STRING vdvDEVICE, "'COOLING=', ITOA(uDvState.nCooling)"
            if (uDvState.nCooling == 0)
            {
                // send power query again to ensure the power off
                fnCmd_referencePower()
            }
        }
    }
}

TIMELINE_EVENT[nPOLLTL]
{
    stack_var integer i

    if (nDebug == 2)
        SEND_STRING 0,"'polling now !'"

    // Loop through poll items, stop if end of notify list
    for (i = 1; i <= nNumberPollItems; i++)
    {
        fnGet_dvInfo(uPollList[i].sCmd, USER_QUEUE)
    }
}

TIMELINE_EVENT[nTL_DEQUE]  // Timeout - no reply
{
    if (nDebug)
    {
        SEND_STRING 0, "'No reply received; clear flag, dequeue next cmd'"
    }

    bWaitForReply = FALSE
    // clear out anything in serial port rcv buffer
    sRxBuff = '';
    SEND_COMMAND dvDevice, "'RXCLR'";
    fnDEQ();  // Send next command in queue
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)