/* vim:set ts=8 sts=4 sw=4 tw=0: */
/*
 * minshell.c -
 *
 * Last Change: 28-Jan-2003.
 * Written By:	MURAOKA Taro <koron@tka.att.ne.jp>
 */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shellapi.h>

#ifndef VERYSMALL
    int WINAPI
WinMin(HINSTANCE hInstance, HINSTANCE hPrevInstance,
	LPSTR lpCmdLine, int nCmdShow)
#else
    void
WinMainCRTStartup()
#endif
{
    char *url = GetCommandLine();
    int retval;
    if (*url == '"')
	for (++url; *url != '"' && *url != '\0'; )
	    ++url;
    while (*url != ' ' && *url != '\0')
	++url;
    while (*url == ' ' && *url != '\0')
	++url;
    retval = (int)ShellExecute(NULL, "open", url, NULL, NULL, SW_SHOW);
#ifndef VERYSMALL
    return retval;
#else
    ExitProcess(retval);
#endif
}
