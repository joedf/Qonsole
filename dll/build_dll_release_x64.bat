@echo off
md bin >nul 2>&1
windres64 vinfo.rc vi.o
gcc64 SizeCon.c vi.o -o bin\SizeCon_x64.dll -DBUILD_DLL -mwindows -shared -Os -s
del vi.o