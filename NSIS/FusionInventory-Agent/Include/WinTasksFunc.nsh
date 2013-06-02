/*
   ------------------------------------------------------------------------
   FusionInventory Agent Installer for Microsoft Windows
   Copyright (C) 2010-2013 by the FusionInventory Development Team.

   http://www.fusioninventory.org/ http://forge.fusioninventory.org/
   ------------------------------------------------------------------------

   LICENSE

   This file is part of FusionInventory project.

   FusionInventory Agent Installer for Microsoft Windows is free software;
   you can redistribute it and/or modify it under the terms of the GNU
   General Public License as published by the Free Software Foundation;
   either version 2 of the License, or (at your option) any later version.


   FusionInventory Agent Installer for Microsoft Windows is distributed in
   the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
   the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
   PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA,
   or see <http://www.gnu.org/licenses/>.

   ------------------------------------------------------------------------

   @package   FusionInventory Agent Installer for Microsoft Windows
   @file      .\FusionInventory Agent\Include\WinTasksFunc.nsh
   @author    Manuel J. Garrido <manuel.garrido@gmail.com>
   @copyright Copyright (c) 2010-2013 FusionInventory Team
   @license   GNU GPL version 2 or (at your option) any later version
              http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
   @link      http://www.fusioninventory.org/
   @link      http://forge.fusioninventory.org/projects/fusioninventory-agent
   @since     2012

   ------------------------------------------------------------------------
*/


!ifndef __FIAI_WINTASKSFUNC_INCLUDE__
!define __FIAI_WINTASKSFUNC_INCLUDE__

!include LogicLib.nsh
!include "${FIAI_DIR}\Include\INIFunc.nsh"

; FusionInventoryAgentTaskIsInstalled
!macro _FusionInventoryAgentTaskIsInstalled _a _b _t _f
    ; $R0 Comspec full path
    ; $R1 String to look for
    ; $R2 ExecToStack's return value

    ; Push $R0, $R1, $R2 & $R3 onto the stack
    Push $R0
    Push $R1
    Push $R2

    ; Look for task
    !insertmacro _LOGICLIB_TEMP
    ExpandEnvStrings $R0 %COMSPEC%
    StrCpy $R1 '${PRODUCT_NAME}""'
    nsExec::ExecToStack '"$R0" /C schtasks /query /fo csv | find /C "$R1"'

    ; Get ExecToStack's return values
    Pop $R2
    Pop $_LOGICLIB_TEMP

    ; Pop $R2, $R1 & $R0 off of the stack
    Pop $R2
    Pop $R1
    Pop $R0

    !insertmacro _= $_LOGICLIB_TEMP 1 `${_t}` `${_f}`
!macroend

!define FusionInventoryAgentTaskIsInstalled `"" FusionInventoryAgentTaskIsInstalled ""`

; RemoveFusionInventoryTask
!define RemoveFusionInventoryTask "!insertmacro RemoveFusionInventoryTask"

!macro RemoveFusionInventoryTask
    ; $R0, $R1 ExecToStack's return values

    Push $R0
    Push $R1

    ${If} ${FusionInventoryAgentTaskIsInstalled}
        nsExec::ExecTostack 'schtasks /delete /tn "${PRODUCT_NAME}" /f'
        Pop $R0
        Pop $R1 
        ${If} $R0 != 0
           DetailPrint "Error deleting task. $R0: $R1"
        ${EndIf}
    ${EndIf}

    ; Pop $R1 & $R0 off of the stack
    Pop $R1
    Pop $R0 
!macroend

; AddFusionInventoryTask
!define AddFusionInventoryTask "Call AddFusionInventoryTask"

Function AddFusionInventoryTask
    ; $R0 Section from which to read
    ; $R1 Install directory
    ; $R2 Time unit for the scheduler (minute, hourly, daily)
    ; $R3 Time interval
    ; $R4, $R5 ExecToStack's return values

    ; Push $R0, $R1, $R2 & $R3 onto the stack
    Push $R0
    Push $R1
    Push $R2
    Push $R3
    Push $R4
    Push $R5

    ; Set the section from which to read
    StrCpy $R0 "${IOS_FINAL}"

    ; Get install directory
    ${ReadINIOption} $R1 "$R0" "${IO_INSTALLDIR}"

    ; Get time unit for the scheduler (minute, hourly, daily)
    ${ReadINIOption} $R2 "$R0" "${IO_TASK-FREQUENCY}"

    ; Get the time interval
    ${Select} "$R2"
        ${Case} "daily"
            ${ReadINIOption} $R3 "$R0" "${IO_TASK-DAILY-MODIFIER}"
        ${Case} "hourly"
            ${ReadINIOption} $R3 "$R0" "${IO_TASK-HOURLY-MODIFIER}"
       ${Case} "minute"
            ${ReadINIOption} $R3 "$R0" "${IO_TASK-MINUTE-MODIFIER}"
    ${EndSelect}

    ; Create scheduled task
    nsExec::ExecTostack 'schtasks /tn "${PRODUCT_NAME}" /create /ru system \
        /TR "\"${IO_INSTALLDIR}\fusioninventory-agent.bat\"" /sc $R2 /mo $R3'

    Pop $R4
    Pop $R5 
    ${If} $R4 != 0
           DetailPrint "Error creating task. $R4: $R5"
    ${EndIf}

    ; Pop $R4, $R4, $R3, $R2, $R1 & $R0 off of the stack
    Pop $R5
    Pop $R4
    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

!endif