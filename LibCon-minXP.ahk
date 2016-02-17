; modified

; REDUCED (min) VERSION FOR QONSOLE - since 1.1.7
; ------------------------------------------------

;
; AutoHotkey (Tested) Version: 1.1.13.01
; Author:         Joe DF  |  http://joedf.co.nr  |  joedf@users.sourceforge.net
; Date:           November 16th, 2013 - Remembrance day Release (v1.0.4.x)
; Library Version: 1.0.4.2
;
;	LibCon - AutoHotkey Library For Console Support
;
;///////////////////////////////////////////////////////

;Default settings
	SetKeyDelay, 0
	SetWinDelay, 0
	SetBatchLines,-1

;Console Constants ;{
	LibConVersion := "1.0.4.2" ;Library Version
	LibConDebug := 0 ;Enable/Disable DebugMode
	LibConErrorLevel := 0 ;Used For DebugMode
	
	;Type sizes // http://msdn.microsoft.com/library/aa383751 // EXAMPLE: SHORT is 2 bytes, etc..
	sType := Object("SHORT", 2, "COORD", 4, "WORD", 2, "SMALL_RECT", 8, "DWORD", 4, "LONG", 4, "BOOL", 4, "RECT", 16, "CHAR", 1)
;}

;Console Functions + More... ;{

	;AttachConsole() http://msdn.microsoft.com/library/ms681952
	;Defaults to calling process... ATTACH_PARENT_PROCESS = (DWORD)-1
	AttachConsole(cPID:=-1) {
		global LibConErrorLevel
		global Stdout
		global Stdin
		x:=DllCall("AttachConsole", "UInt", cPID, "Cdecl int")
		if ((!x) or (LibConErrorLevel:=ErrorLevel)) and (cPID!=-1) ;reject error if ATTACH_PARENT_PROCESS is set
			return LibConError("AttachConsole",cPID) ;Failure
		Stdout:=getStdoutObject()
		Stdin:=getStdinObject()
		return x
	}

	;FreeConsole() http://msdn.microsoft.com/library/ms683150
	FreeConsole() {
		global LibConErrorLevel
		x:=DllCall("FreeConsole")
		if (!x) or (LibConErrorLevel:=ErrorLevel)
			return LibConError("FreeConsole") ;Failure
		return x
	}
	
	;GetStdHandle() http://msdn.microsoft.com/library/ms683231
	GetStdinObject() {
		global LibConErrorLevel
		x:=FileOpen(DllCall("GetStdHandle", "int", -10, "ptr"), "h `n")
		if (!x) or (LibConErrorLevel:=ErrorLevel)
			return LibConError("getStdinObject") ;Failure
		return x
	}

	GetStdoutObject() {
		global LibConErrorLevel
		x:=FileOpen(DllCall("GetStdHandle", "int", -11, "ptr"), "h `n")
		if (!x) or (LibConErrorLevel:=ErrorLevel)
			return LibConError("getStdoutObject") ;Failure
		return x
	}
	
	;Get the console's window Handle
	;GetConsoleWindow() http://msdn.microsoft.com/library/ms683175
	GetConsoleHandle() {
		global LibConErrorLevel
		hConsole := DllCall("GetConsoleWindow","UPtr") ;or WinGet, hConsole, ID, ahk_pid %cPID%
		if (!hConsole) or (LibConErrorLevel:=ErrorLevel)
			return LibConError("getConsoleHandle") ;Failure
		else
			return %hConsole% ;Success
	}
	
	Dec2Hex(var) {
		OldFormat := A_FormatInteger
		SetFormat, Integer, Hex
		var += 0
		SetFormat, Integer, %OldFormat%
		return var
	}
	
	;Get BufferSize, GetConsoleScreenBufferInfo() http://msdn.microsoft.com/library/ms683171
	GetConsoleSize(ByRef bufferwidth, ByRef bufferheight) {
		global LibConErrorLevel
		global Stdout
		global sType
		hStdout := Stdout.__Handle
		VarSetCapacity(struct,(sType.COORD*3)+sType.WORD+sType.SMALL_RECT,0)
		x:=DllCall("GetConsoleScreenBufferInfo","UPtr",hStdout,"Ptr",&struct)
		LibConErrorLevel:=ErrorLevel
		bufferwidth:=NumGet(&struct,"UShort")
		bufferheight:=NumGet(&struct,sType.SHORT,"UShort")
		if (!x) or (LibConErrorLevel:=ErrorLevel)
			return LibConError("getConsoleSize",bufferwidth,bufferheight) ;Failure
		return 1
	}

	GetConsoleHeight() {
		if (!getConsoleSize(bufferwidth,bufferheight))
			return 0 ;Failure
		else
			return %bufferheight% ;Success
	}
	
	
	;///////////////////////// [ XP Patch ] /////////////////////////
	NULL := ""
	SizeConDebug := 0
	SizeConErrorLevel := 0
	SizeConDll := (A_Is64bitOS) ? "SizeCon_x64.dll" : "SizeCon.dll"
	
	loadSizeCon() {
		
		global SizeConDll
		global SizeConErrorLevel
		;SizeConDll := dll
		hDLL:=DllCall("LoadLibrary", "str", SizeConDll)
		if (errorlevel) or (hDLL==0)
		{
			SizeConErrorLevel := ErrorLevel
			if (hDLL==0)
				SizeConErrorLevel := -4 ;dllcall "not found" error code
			return MsgError() ;Failure
		}
		else
			return 1 ;Success
	}
	MsgError(fname:="",arg1:="",arg2:="",arg3:="",arg4:="") {
		
		global SizeConDebug
		global SizeConErrorLevel
		;calling function name: msgbox % Exception("",-2).what ; from jethrow
		;http://www.autohotkey.com/board/topic/95002-how-to-nest-functions/#entry598796
		if fname is space
			fname := Exception("",-2).what
		if (SizeConDebug)
		{
			MsgBox, 50, MsgError, %fname%() Failure`nErrorlevel: %SizeConErrorLevel%`n`nWill now Exit.
			IfMsgBox, Abort
				return Qonsole_Abort()
			IfMsgBox, Ignore
				return 0
			IfMsgBox, Retry
				return %fname%(arg1,arg2,arg3,arg4)
		}
		return 0
	}
	
	;GetCurrentConsoleFont() http://msdn.microsoft.com/library/ms683176
	GetFontSize(Byref fontwidth, ByRef fontheight) {
		global LibConErrorLevel
		global sType
		global Stdout
		hStdout:=Stdout.__Handle
		;CONSOLE_FONT_INFO cmdft;
		;GetCurrentConsoleFont(hStdout,FALSE,&cmdft);
		;COORD fontSize = GetConsoleFontSize(hStdout,cmdft.nFont);
		;return fontSize.X;
		
		;typedef struct _CONSOLE_FONT_INFO {
		;	DWORD nFont;
		;	COORD dwFontSize;
		; } CONSOLE_FONT_INFO, *PCONSOLE_FONT_INFO;
		
		VarSetCapacity(struct,sType.DWORD+sType.COORD,0)
		x:=DllCall("GetCurrentConsoleFont","Ptr",hStdout,"Int",0,"Ptr",&struct)
		LibConErrorLevel:=ErrorLevel
		;VarSetCapacity(structb,sType.COORD,0)
		;structb:=DllCall("GetConsoleFontSize","Ptr",hStdout,"UInt",NumGet(&struct,"Int"))
		
		fontwidth:=NumGet(&struct,sType.DWORD,"UShort")
		fontheight:=NumGet(&struct,sType.DWORD+sType.SHORT,"UShort")
		
		if A_OSVersion in WIN_2003,WIN_XP,WIN_2000,WIN_NT4,WIN_95,WIN_98,WIN_ME
		{			
			global SizeConDll
			global SizeConErrorLevel
			fontwidth:=DllCall(SizeConDll . "\getFontWidth","Ptr",hStdout,"Cdecl Int")
			fontheight:=DllCall(SizeConDll . "\getFontHeight","Ptr",hStdout,"Cdecl Int")
			if errorlevel
			{
				SizeConErrorLevel := ErrorLevel
				return MsgError(NULL,hStdout) ;Failure
			}
			return 1
		}
		else
		{
			if (!x) or (LibConErrorLevel)
				return LibConError("getFontSize",fontwidth,fontheight) ;Failure
			return 1
		}
	}
	;///////////////////////// [ XP Patch ] /////////////////////////
	
	
	GetFontWidth() {
		if (!getFontSize(fontwidth,fontheight))
		{
			return 0 ;Failure
		}
		else
			return %fontwidth% ;Success
	}
	
	;SetConsoleScreenBufferSize() http://msdn.microsoft.com/library/ms686044
	;set Console window size ; - Width in Columns and Lines : (Fontheight and Fontwidth)
	SetConsoleSize(width,height,SizeHeight=0) {
		global LibConErrorLevel
		global sType
		global Stdout
		hStdout:=Stdout.__Handle
		hConsole:=getConsoleHandle()
		
		getConsoleSize(cW,cH) ;buffer size
		WinGetPos,wX,wY,,wH,ahk_id %hConsole% ;window size
		getFontSize(fW,fH) ;font size
		
		;MsgBox % "rqW: " width "`nrqH: " height
		
		newBuffer := Object("w",(width*fW),"h",(height*fH))
		oldBuffer := Object("w",(cW*fW),"h",(cH*fH))
		
		VarSetCapacity(bufferSize,sType.COORD,0)
		NumPut(width,bufferSize,"UShort")
		NumPut(height,bufferSize,sType.SHORT,"UShort")
		
		if ( (newBuffer.w >= oldBuffer.w) and (newBuffer.h >= oldBuffer.h) )
		{
			if (DllCall("SetConsoleScreenBufferSize","Ptr",hStdout,"uint",Numget(bufferSize,"uint"))
				and DllCall("MoveWindow","Ptr",hConsole,"Int",wX,"Int",wY,"Int",newBuffer.w,"Int",newBuffer.h,"Int",1))
			{
				if (SizeHeight)
					WinMove,ahk_id %hConsole%,,,,,wH
				return 1
			}
			else
			{
				LibConErrorLevel := ErrorLevel
				return LibConError("setConsoleSize",width,height,SizeHeight) ;Failure
			}
		}
		else
		{
			if (DllCall("MoveWindow","Ptr",hConsole,"Int",wX,"Int",wY,"Int",newBuffer.w,"Int",newBuffer.h,"Int",1)
				and DllCall("SetConsoleScreenBufferSize","Ptr",hStdout,"uint",Numget(bufferSize,"uint")))
			{
				if (SizeHeight)
					WinMove,ahk_id %hConsole%,,,,,wH
				return 1
			}
			else
			{
				LibConErrorLevel := ErrorLevel
				return LibConError("setConsoleSize",width,height,SizeHeight) ;Failure
			}
		}
	}
	
	Print(string=""){
		global Stdout
		global LibConErrorLevel
		
		if (!StrLen(string))
			return 1
		
		e:=DllCall("WriteConsole" . ((A_IsUnicode) ? "W" : "A")
				, "UPtr", Stdout.__Handle
				, "Str", string
				, "UInt", strlen(string)
				, "UInt*", Written
				, "uint", 0)

		if (!e) or (LibConErrorLevel:=ErrorLevel)
			return LibConError("print",string) ;Failure
		Stdout.Read(0)
		return e
	}
	
	;Msgbox for Errors (DebugMode Only)
	LibConError(fname:="",ByRef arg1:="", ByRef arg2:="",arg3:="",arg4:="", ByRef arg5:="") {
		global LibConDebug
		global LibConErrorLevel
		
		static LibConErrorsIgnoreList
		
		;calling function name: msgbox % Exception("",-2).what ; from jethrow
		;http://www.autohotkey.com/board/topic/95002-how-to-nest-functions/#entry598796
		if !IsFunc(fname) ;or fname is space
			fname := Exception("",-2).what
		if !IsFunc(fname) ;try again since sometime it return -2() meaning not found...
			fname := "Undefined"
		global Stdout
		if (fname="print") and (A_LastError=6)
		{
			if strlen(arg1) > 0
				x:=Stdout.write(arg1)
			Stdout.Read(0)
			return x
		}
		if (LibConDebug)
		{
			
			if fname in %LibConErrorsIgnoreList%
				return 0
			
			MsgBox, 262194, LibConError, %fname%() Failure`nErrorlevel: %LibConErrorLevel%`nA_LastError: %A_LastError%`n`nWill now Exit.
			IfMsgBox, Abort
			{
				return Qonsole_Abort()
			}
			IfMsgBox, Ignore
			{
				LibConErrorsIgnoreList:=fname "," LibConErrorsIgnoreList
				return 0
			}
			IfMsgBox, Retry
			{
				return %fname%(arg1,arg2,arg3,arg4,arg5)
			}
		}
		return 0
	}
	
	Qonsole_Abort() {
		MsgBox, 262195, , Restart Qonsole?`nIf No`, Qonsole will simply exit.`nIf Cancel`, Qonsole will continue running.
		IfMsgBox,Yes
			Reload
		IfMsgBox,No
			ExitApp
		return 0
	}
;}

