@echo off
md bin >nul 2>&1
windres vinfo.rc vi.o
gcc SizeCon.c vi.o -o bin\SizeCon.dll -DBUILD_DLL -mwindows -shared -Os -s
del vi.o