PROGRAM_NAME='x_chineseCode'
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
*)

#include 'UnicodeLib.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

BTNFB_Z1FLIST_IDX1          = 1
BTNFB_Z1FLIST_IDX2          = 2

char btnPPTPlayFileName[4][16] = {
    '文件一',
    'filename 2'
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

// the function I use for sending utf-8 text, maybe you can find something
// useful in it.

// Also make sure you have "Enable _WC Preprocessor (Unicode) checkec in NS
// Preferences > Netlinx Compiler and make sure you have #INCLUDE
// 'UnicodeLib.axi' in your module and main.

define_function fnFB_DoSend_VT(integer iUI_Indx, integer iCHAN, char iStrMSG[])
{
    stack_var integer n;
    stack_var integer nTPCount;
    stack_var integer nLoopStart;
    stack_var char cUNI_STR_2[MAX_4096];
    stack_var widechar cUNI_STR_1[MAX_4096];

    if(iUI_Indx)
    {
        nTPCount = iUI_Indx;
        nLoopStart = iUI_Indx;
    }
    else
    {
        nTPCount = sSBS.sPlayer.nNum_UIs;
        nLoopStart = 1;
    }

    fnDevMod_DEBUG("'SEND_VT: ',iStrMSG,' :DEBUG<',ITOA(__LINE__),'>'",4);

    if(length_string(iStrMSG))
    {
        cUNI_STR_1 = WC_DECODE(fnStrReplace(iStrMSG,'$; ',', '),WC_FORMAT_UTF8,1);
        cUNI_STR_2 = WC_ENCODE(cUNI_STR_1,WC_FORMAT_TP,1);
    }

    for(n = nLoopStart; n <= nTPCount; n++)
    {
        if(nUI_ActiveArry[n] == sSBS.sPlayer.nInstance)//means it on this SB & ACTIVE on page
        {
            SWITCH(nUI_TypeArry[n])
            {
                CASE UI_TYPE_iPHONE:
                CASE UI_TYPE_iTOUCH:
                CASE UI_TYPE_iPAD:
                CASE UI_TYPE_G4:
                CASE UI_TYPE_R4:
                CASE UI_TYPE_MIO_DMS:
                {
                    if(length_string(cUNI_STR_2))
                    {
                        STACK_VAR CHAR cUniSend[MAX_4096];
                        STACK_VAR INTEGER nAppend;

                        cUniSend = cUNI_STR_2;

                        WHILE(LENGTH_STRING(cUniSend))
                        {
                            STACK_VAR CHAR cTMP[UNI_STR_SIZE];

                            if(LENGTH_STRING(cUniSend) > UNI_STR_SIZE)
                            {
                                cTMP = GET_BUFFER_STRING(cUniSend,UNI_STR_SIZE);
                            }
                            else
                            {
                                cTMP = GET_BUFFER_STRING(cUniSend,LENGTH_STRING(cUniSend));
                            }

                            if(nAppend)
                            {
                                SEND_COMMAND dvUI_SBSArry[n],"'^BAU-',ITOA(iCHAN),',0,',cTMP";   //Append Unicode to Modero Panels
                            }
                            else
                            {
                                SEND_COMMAND dvUI_SBSArry[n],"'^UNI-',ITOA(iCHAN),',0,',cTMP";   //Unicode to Modero Panels
                            }
                            fnDevMod_DEBUG("'SEND_COMMAND UNI, APPEND-[',itoa(nAppend),'], CHNL-[',itoa(iCHAN),'], STR-[ ',cTMP,' ] :DEBUG<',ITOA(__LINE__),'>'",4);
                            nAppend++;
                        }
                    }
                    else//we need to clear text fields too, duh!
                    {
                        SEND_COMMAND dvUI_SBSArry[n], "'^TXT-',itoa(iCHAN),',0,',cUNI_STR_2";
                    }
                }
                CASE UI_TYPE_G3:
                {
                    fnDevMod_DEBUG("'^TXT- TP INDX: ',itoa(n),', CHNL: ',itoa(iCHAN),' :DEBUG<',ITOA(__LINE__),'>'",4);
                    SEND_COMMAND dvUI_SBSArry[n], "'^TXT-',itoa(iCHAN),',0,',iStrMSG";
                }
                CASE UI_TYPE_METKP:
                CASE UI_TYPE_UNKNOWN:
                CASE UI_TYPE_VIRTUAL:
                {
                    //DO NOTHING
                }
            }
        }
    }

    RETURN;
}

define_function tps_updateFileList()
{
    SEND_COMMAND gDvTps,
        "'^UNI-', ITOA(btnPPTPlayFileList[BTNFB_Z1FLIST_IDX1]), ',0,', btnPPTPlayFileName[BTNFB_Z1FLIST_IDX1]"
    SEND_COMMAND gDvTps,
        "'^UNI-', ITOA(btnPPTPlayFileList[BTNFB_Z1FLIST_IDX2]), ',0,', '0041E69687E4BBB6E4B880'"
}