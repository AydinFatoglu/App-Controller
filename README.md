# Powershell Unused App Killer

This code is a PowerShell script that runs in the background and monitors user activity on a computer. It waits for a specified period of time (in minutes) for any user activity, and if there is no activity during that time, it terminates a specific process called "reMarkable". The script also includes a debug mode, where additional information can be outputted to the console. The script periodically polls the computer's input devices (keyboard and mouse) to determine the last time there was user activity. If the delay in user activity exceeds the specified time (in minutes), it terminates the "reMarkable" process and logs the action to a text file. The script runs in an infinite loop until the PowerShell process is terminated manually.

