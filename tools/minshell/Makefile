# vim:set ts=8 sts=4 sw=4 tw=0:
# Last Change: 28-Jan-2003.

TARGET = minshell.exe
OBJS = minshell.obj
LIBS = kernel32.lib user32.lib shell32.lib
CFLAGS = /nologo /O1 /Os /DVERYSMALL
LFLAGS = /nologo /SUBSYSTEM:WINDOWS /ENTRY:WinMainCRTStartup /NODEFAULTLIB \
	/ALIGN:4096

CC = cl
LD = link

$(TARGET): $(OBJS)
	$(LD) $(LFLAGS) $(LIBS) /OUT:$@ $**

clean :
	-del /F *.obj
	-del /F *.res

distclean: clean
	-del /F *.exe
