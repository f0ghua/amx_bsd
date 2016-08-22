PROGRAM_NAME='CMDAPI'

#IF_NOT_DEFINED __CMDAPI_CONST__
#DEFINE __CMDAPI_CONST__
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT // SNAPI Version

CHAR CMDAPI_AXI_VERSION[]    = '1.14'


(***********************************************************)
(*                   Command/Param Lengths                 *)
(***********************************************************)
                // Command/Param Lengths

#IF_NOT_DEFINED CMDAPI_MAX_PARAM_NUM
CMDAPI_MAX_PARAM_NUM   = 8
#END_IF

#IF_NOT_DEFINED CMDAPI_MAX_PARAM_LEN
CMDAPI_MAX_PARAM_LEN   = 64
#END_IF

#IF_NOT_DEFINED CMDAPI_MAX_DATA_LEN
CMDAPI_MAX_DATA_LEN    = 256
#END_IF

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

// for the command parser
structure _sCMD_PARAMETERS
{
    integer count
    char    param[CMDAPI_MAX_PARAM_NUM][CMDAPI_MAX_PARAM_LEN]
    char    rawdata[CMDAPI_MAX_DATA_LEN]
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE


(***********************************************************)
(*           SUBROUTINE DEFINITIONS GO BELOW               *)
(***********************************************************)

// Name   : ==== NetHex ====
// Purpose: To package header for module send_command or send_string
// Params : (1) IN - bAsciiFlag     TRUE/FALSE
// Returns: Packed header with command separator added if missing
// Notes  : Adds the command header to the string and adds the command if missing
//          This function assumes the standard Duet command separator '-'
//
define_function integer cmdapi_NetHex(dev dvDevice, char sPrefix[],
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

// Name   : ==== fnRangeCheck ====
// Purpose: To package header for module send_command or send_string
// Params : (1) IN - sndcmd/str header
// Returns: Packed header with command separator added if missing
// Notes  : Adds the command header to the string and adds the command if missing
//          This function assumes the standard Duet command separator '-'
//
define_function integer cmdapi_RangeCheck(slong value, slong min, slong max)
{
    if ((value >= min) and (value <= max))
        return TRUE
    else
        return FALSE
}

// Name   : ==== fnParseCommand ====
// Purpose: To parse out parameters from module send_command or send_string
// Params : (1) IN  - sndcmd/str data
//          (2) IN  - parameter separating character usually ':' or '|' or even a string
//          (3) OUT - parsed property/method name STILL INCLUDES the '=' or '?'
//          (4) OUT - MDX_PARAMETERS structure
// Returns: integer - -1 if the parse failed OR the count of parameters placed in (4)
// Notes  : Parses the strings sent to or from modules extracting the various parts
//          of the command out into command name, parameters and returning the count
//          of parameters present.   Adapted from the UK mdxStandard.axi
//          Changed the functionality because it didn't appear to support parameters
//          with query commands
//
define_function integer cmdapi_ParseCommand(char cmd[], char separator[],
                               char name[], _sCMD_PARAMETERS params)
{
    stack_var char p        // use character to save space
    stack_var char temp[CMDAPI_MAX_PARAM_LEN]

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
    while ((LENGTH_STRING(cmd)) and (params.count <= CMDAPI_MAX_PARAM_NUM))
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
            if (LENGTH_STRING(temp) < CMDAPI_MAX_PARAM_LEN)
            {
                params.param[p] = temp;
                params.count++;
            }
        }
        else
        {
            SET_LENGTH_STRING(temp, LENGTH_STRING(temp)-1); // Remove ':'
            if(LENGTH_STRING(temp) < CMDAPI_MAX_PARAM_LEN)
            {
                params.param[p] = temp;
                params.count++;
            }
        }
    }
    return params.count;
}

#END_IF //  __CMDAPI_CONST__
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
