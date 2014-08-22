/******************************************************************************/ 
/*                                                                            */ 
/* COPYRIGHT:                                                                 */ 
/* ----------                                                                 */ 
/* Copyright (C) International Business Machines Corp., 1994.                 */ 
/*                                                                            */ 
/* DISCLAIMER OF WARRANTIES:                                                  */ 
/* -------------------------                                                  */ 
/* The following [enclosed] code is sample code created by IBM                */ 
/* Corporation.  This sample code is not part of any standard IBM product     */ 
/* and is provided to you solely for the purpose of assisting you in the      */ 
/* development of your applications.  The code is provided "AS IS",           */ 
/* without warranty of any kind.  IBM shall not be liable for any damages     */ 
/* arising out of your use of the sample code, even if they have been         */ 
/* advised of the possibility of such damages.                                */ 
/*                                                                            */ 
/******************************************************************************/ 

/*******************************************************************/
/*                                                                 */
/* Sample program for ICSS REXX interface.                         */
/*                                                                 */
/* Usage: rexxreco <verbose_level>                                 */
/*                                                                 */
/*     verbose_level:  controls level of output from ICSS.         */
/*                     0 = none, default is 2.                     */
/*                                                                 */
/*******************************************************************/
/* Notes:  This program uses default values for ICSS API calls.    */
/*         If your profile is set up to use MMPM, you will need to */
/*         run this program using PMREXX.  If you are using an     */
/*         ACPA card without MMPM, simply run this program from    */
/*         the command line.                                       */
/*******************************************************************/

arg verbose_level

if verbose_level = "" then
   verbose_level = 2

say "This is REXXRECO.CMD, verbose level is" verbose_level

/*------symbolic values copied from icssapi.h-------------------------*/
default_int = '-1';
default_flt = '-2.0';
default_str = '';

/* register the ICSS function loader */

call RxFuncAdd 'LoadFunctions', 'ICSSREXX', 'LoadFunctions' 
call LoadFunctions  /* load the ICSS functions */

/* Start ICSS */

icss_rc = ICRXStart(default_str)
say '@@ Start returned: ' icss_rc
say;

icss_rc = ICRXStartConversation(default_str,default_int,default_str,default_int)
say '@@ StartConversation returned: ' icss_rc
say;

/* Example of SetValue */
parmid = 10;  /* Verbose Level */  
say; 
say 'Setting Verbose Level...';
icss_rc = ICRXSetValue(parmid, verbose_level);
say '@@ SetValue returned:' icss_rc; 


say; 
icss_rc = ICRXGetValue(parmid);
parse var icss_rc real_rc parm_value;
say '@@ GetValue returned:' real_rc 'with parm value:' parm_value 'for Verbose Level';

/* Load the context */

context_name = 'RL.CTX';

say 'Loading context' context_name;  
icss_rc = ICRXLoadContext(context_name,default_flt,default_flt,default_flt)
parse var icss_rc temp_rc handle
say '@@ LoadContext returned: ' temp_rc ' with handle: ' handle

say "Initialization complete!  Press any key to continue."
pull junk

answer = "Y"

/* Loop until the user responds with something other than "Y" */

do while answer = "Y"
   say ' '

   icss_rc = ICRXListen(handle,'5','')  
   say '@@ Listen returned: ' icss_rc
   say ' '
   say '@@ -->BEGIN SPEAKING<--'
   
   icss_rc = ICRXGetSpokenWords()              
   parse var icss_rc temp_rc too_soon utt_len acq_time reco_time buff 
   say '@@ GetSpokenWords returned:'
   say '@@               words: ' buff
   say '@@         return code: ' temp_rc
   say '@@            too soon: ' too_soon
   say '@@    utterance length: ' utt_len
   say '@@    acquisition time: ' acq_time
   say '@@    recognition time: ' reco_time
   say '  '

   say 'Another Reco (Y/N)?'
   pull answer
end 

say "OK, Cleaning up..."
icss_rc = ICRXRemoveContext(handle);
say '@@ RemoveContext returned:' icss_rc

icss_rc = ICRXEndConversation()
say '@@ EndConversation returned: ' icss_rc

icss_rc = ICRXEnd();  
say '@@ End returned: ' icss_rc

/*-------------------------------*/

call DropFunctions     /* not strictly necessary, perhaps */

say "All Done!"
exit

