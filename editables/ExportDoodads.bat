
::This script will search through several folders in this directory for files ending in .ase or .aseprite, and export them to an output folder.
::By default, all sprites are exported at 5x scale, but that can be modified by changing the SCALE variable
::Note that the script will create folders and overwrite files as needed, but it will not clear the folders first.
::What this means is that you may need to manually delete the ExportedTextures folder from time to time, to clear out textures from files that no longer exist.


::Sprites in the folder simple-sprites will be flattened and exported.
::Sprites in the folder sprite-sheets will be exported as a horizontal sheet with all frames.
::Sprites in the folder by-group will be split into individual layer groups, then each group exported individually.
::Sprites in the folder no-scale will be flattened and exported - and will be exported at 1:1 scaling
::Sprites in the folder not-for-export (or anywhere else) will be ignored.

ECHO OFF
setlocal enabledelayedexpansion

@set ASEPRITE="D:\STEAM\steamapps\common\Aseprite\aseprite.exe"
@set /A SCALE = "1"
::@set EXPORTPATH ="..\textures\environment"



for /r .\doodads\ %%F in (*.ase*) do (
	
	 set "EDITABLEFOLDER=%%~dF%%~pF"
	 %ASEPRITE% -b %%F --color-mode rgb --scale %SCALE% --save-as ..\textures\!EDITABLEFOLDER:%CD%\=!/%%~nF-{slice}.png

	 echo DOODADS: File %%~nF%%~xF exported.
)

endlocal
PAUSE
