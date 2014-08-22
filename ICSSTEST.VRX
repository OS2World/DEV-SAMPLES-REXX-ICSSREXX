/*:VRX         Main
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary: procedure
    name = arg( 1 )

    window = VRLoad( VRWindow(), VRWindowPath(), name )
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
return window

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:
    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"

    /* Initialize ICSSREXX */
    call RxFuncAdd 'LoadFunctions', 'ICSSREXX', 'LoadFunctions'
    call LoadFunctions  

    /* Initialize ICSS */

    default_int = '-1';
    default_flt = '-2.0';
    default_str = '';
    
    icss_rc = ICRXStart(default_str)
    
    if icss_rc \= 0 then 
        VRMessage(window, "Error on ICRXStart")
     
    icss_rc = ICRXStartConversation(default_str,default_int,default_str,default_int)   

    if icss_rc \= 0 then 
        VRMessage(window, "Error on ICRXStartConversation")

    context_name = 'RL.CTX';

    icss_data = ICRXLoadContext(context_name,default_flt,default_flt,default_flt)
    parse var icss_data icss_rc handle

    if icss_rc \= 0 then 
        VRMessage(window, "Error on ICRXStartConversation")
    else do
        VRSet("DT_Message", "Caption", "Ready")
        VRSet("PB_Reco", "Enabled", 1);
    end
      
    drop window icss_rc icss_data

return

/*:VRX         PB_Reco_Click
*/
PB_Reco_Click:
    ok = VRSet( "DT_Message", "Caption", "Please Wait..." )
    ok = VRSet( "PB_Reco", "Enabled", 0 )
    
    icss_rc = ICRXListen(handle,'5','')
    if icss_rc = 0 then do
        ok = VRSet( "DT_Message", "Caption", "Begin Speaking..." )
        icss_data = ICRXGetSpokenWords()
        parse var icss_data icss_rc too_soon utt_len acq_time reco_time buff
        if icss_rc = 0 then do
            ok = VRSet( "EF_RecoText", "Value", buff ) 
            end
        else do
            msg = "Error on GetSpokenWords, rc =" icss_rc
            ok = VRSet( "EF_RecoText", "Value", msg ) 
            end
        end
    else do
        msg = "Error on Listen, rc =" icss_rc
        ok = VRSet( "EF_RecoText", "Value", msg ) 
        end

    ok = VRSet( "DT_Message", "Caption", "Ready!" )
    ok = VRSet( "PB_Reco", "Enabled", 1 )        

return

/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    icss_rc = ICRXEndConversation()
    icss_rc = ICRXEnd()
    call DropFunctions 
    drop window
return

/*:VRX         Window1_Close
*/
Window1_Close:
    call Quit
return

