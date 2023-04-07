param([Parameter(Mandatory=$true)][string]$procname)
$delayUntilTermination=1
$debugswitch="Off"
$pollinginterval=5
$logfile="c:\log.txt"
Function Killproc{
$proc = Get-Process $args[0] -ErrorAction SilentlyContinue
$proc|ForEach-Object{ $_.CloseMainWindow() } | Out-Null | stop-process –force
Start-Sleep -Seconds 5
$proc|Where-Object{ $_.hasExited -ne $true } | Stop-Process -ErrorAction SilentlyContinue
start-sleep -seconds 20
$ProcessActive = Get-Process $args[0] -ErrorAction SilentlyContinue
if($ProcessActive -eq $null){ $killed = "Not Running" }else{ $Killed = "Still Running" }
$user = [Environment]::UserName
$domain = [Environment]::UserDomainName
$fqdn = $domain + "\" + $user
$hname = $env:computername
$thedate = get-date
$datestamplog = $fqdn + "," + $hname + "," + $thedate + "," + $args[0] + " " + $killed
$datestamplog | out-file -filepath $logfile -append
}
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
$withinAnHour = $false
while ($true) {
    $mon = ([PInvoke.Win32.UserInput]::LastInput)
    $date2 = (Get-Date)
    $date1 = $mon
    $dateDiff = (New-TimeSpan $date1 $date2).totalminutes
    if ($debugswitch -eq "On") { $datediff }
    start-sleep -seconds $pollinginterval
    If ($datediff -gt $delayUntilTermination) {
        If (Get-Process -Name $args[0] -ErrorAction SilentlyContinue) {
            Killproc $args[0]
            $withinAnHour = $true
        }
    }
}
