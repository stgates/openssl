@echo off

if "%1"=="" (
echo;
echo Usage:		gen86.bat ^<toolset^> ^<zlib_package_root^> ^<zlib_linkage^>
echo;
goto err
) 

REM this makes it so that DLLs can have their own SxS Activation Context in an embedded resource.
if not defined CL set CL= /D ISOLATION_AWARE_ENABLED /U NOUSER 
echo %CL% | findstr ISOLATION_AWARE || set CL=%CL% /D ISOLATION_AWARE_ENABLED /U NOUSER 


mkdir intermediate
mkdir intermediate\%1
mkdir intermediate\%1\x86
mkdir intermediate\%1\x86\Release

mkdir output
mkdir output\%1
mkdir output\%1\x86
mkdir output\%1\x86\Release
mkdir output\%1\x86\Release\include

@echo on
perl Configure no-rc5 no-idea enable-mdc2 enable-zlib VC-WIN32 -I"%2/lib/native/include" -L"%2/lib/native/lib/Win32/%1/%3"
@echo off
REM call ms\do_nasm
call ms\do_ms
powershell -command "cat ms\ntdll.mak | ForEach-Object{ $_ -replace \"out32dll\", \"output/%1/x86/Release\" } | ForEach-Object{ $_ -replace \"tmp32dll\", \"intermediate/%1/x86/Release\" } | ForEach-Object{ $_ -replace \"inc32\", \"output/%1/x86/Release/include\" } | sc ms\ntdll86.mak"

nmake -f ms\ntdll86.mak	|| goto failed


@goto :eof
:failed
@echo Bad things happened...
:err
@exit /b 1;

