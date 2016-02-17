#define WINVER         0x0500
#define _WIN32_WINNT   0x0500
#define _WIN32_WINDOWS 0x0500

//#include <stdio.h>
#include <windows.h>

#ifdef BUILD_DLL
	#define _DLLEXPORT __declspec(dllexport)
	#endif
#ifndef BUILD_DLL
	#define _DLLEXPORT
	#endif

#ifndef __MINGW64__
#ifdef __MINGW32__ //mingw define fix //http://stackoverflow.com/a/8867686
	COORD WINAPI GetConsoleFontSize(HANDLE hConsoleOutput,DWORD nFont);
	BOOL WINAPI GetCurrentConsoleFont(HANDLE hConsoleOutput,BOOL bMaximumWindow,PCONSOLE_FONT_INFO lpConsoleCurrentFont);
	#endif
#endif

//Declare Functions
	//Set Functions
		_DLLEXPORT int getFontWidth(HANDLE hStdout);
		_DLLEXPORT int getFontHeight(HANDLE hStdout);

int main() {return 0;}

_DLLEXPORT int getFontWidth(HANDLE hStdout) {
	
	CONSOLE_FONT_INFO cmdft;
	GetCurrentConsoleFont(hStdout,FALSE,&cmdft);
	COORD fontSize = GetConsoleFontSize(hStdout,cmdft.nFont);
	
	return fontSize.X;
}

_DLLEXPORT int getFontHeight(HANDLE hStdout) {
	
	CONSOLE_FONT_INFO cmdft;
	GetCurrentConsoleFont(hStdout,FALSE,&cmdft);
	COORD fontSize = GetConsoleFontSize(hStdout,cmdft.nFont);
	
	return fontSize.Y;
}