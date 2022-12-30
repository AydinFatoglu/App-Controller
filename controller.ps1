PowerShell.exe -windowstyle hidden { 

#Only the 3 variables below need to be changed to get this script working#

#Number in minutes of inactivity before process it terminated
$delayUntilTermination = 1

#ProcessName, use get-process to see what's running and its processname
$procname = "reMarkable"

#Enable\Disable debugging using either "On" or "Off"
$debugswitch = "Off"

#Polling interval of last input
$pollinginterval = 5

#Log file
$logfile = "c:\log.txt"

#End of Change these only#




#Functions

#Stop process (kill)
Function Killproc{

$proc = Get-Process $procname -ErrorAction SilentlyContinue
$proc| ForEach-Object { $_.CloseMainWindow() } | Out-Null | stop-process –force
Start-Sleep -Seconds 5
$proc | Where-Object { $_.hasExited -ne $true } |
Stop-Process -ErrorAction SilentlyContinue

start-sleep -seconds 20

#write logging

#see if process is still running
$ProcessActive = Get-Process $procname -ErrorAction SilentlyContinue
if($ProcessActive -eq $null)
{
 $killed = "Not Running"
}
else
{
 $Killed = "Still Running"
}

#build domain username, machine name and date\timefor logging
$user = [Environment]::UserName
$domain = [Environment]::UserDomainName
$fqdn = $domain+ "\" +$user
$hname = $env:computername
$thedate = get-date
$datestamplog = $fqdn + "," + $hname + "," + $thedate + "," + $procname + " " + $killed
$datestamplog | out-file -filepath $logfile -append

    }


#Start querying all input devices, Keyboard Mouse or other to see if any input has been made since last check, using namespace PInvoke.Win32
Add-Type @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PInvoke.Win32 {

    public static class UserInput {

        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }

        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.Now.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }

        public static TimeSpan IdleTime {
            get {
                return DateTime.Now.Subtract(LastInput);
            }
        }

        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }
    }
}
'@

#Static to set to false
$withinAnHour = $false

#Endless loop ;-).  This keeps the script live all the time - check task mgr to find powershell.exe using about 30mb
$i = 1
while ($i -lt 2) {

#Grab last input date
$mon = ([PInvoke.Win32.UserInput]::LastInput)
#[datetime]$mon

#Get date\time right now
$date2 = (Get-Date)
#Last input date
$date1= $mon

#Find difference between $date1 and $date2 in minutes
$dateDiff = (New-TimeSpan $date1 $date2).totalminutes

#Debugging enabled if $debuswitch is set to "On" - Off by default
 if ($debugswitch -eq "On" ) {$datediff}



#Sleep a bit
start-sleep -seconds $pollinginterval

#If statement to act on input stopping - compares the idle time to the $delayuntiltermination variable at the top, if -gt call Killproc function to kill process
#If no input after $delayUntilTermination minutes fire Sendkey function
If ($datediff -gt $delayUntilTermination) {

    
    #check if the process is running before calling the function Sendkey
    If (Get-Process -Name $procname -ErrorAction SilentlyContinue) {
    
    Killproc

    #Debugging enabled if $debuswitch is set to "On" - Off by default
    #if ($debugswitch -eq "On" ){}
    #Set $withinanhour to true
            $withinAnHour = $true
            }





        }
 }
 }
