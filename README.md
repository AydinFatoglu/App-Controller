# PowerShell Process Terminator on Idle

This PowerShell script defines a function to terminate a specified process and then monitors user input. If no user input is detected for a specified duration, the script terminates the specified process. It also logs information about the process termination.

## Breakdown of the code

1. **Defining mandatory script parameters:**
   - `$procname`: The name of the process to terminate.
   - `$delayUntilTermination`: The time (in minutes) of inactivity before terminating the process.
   - `$debugswitch`: A switch to enable or disable debugging output.
   - `$pollinginterval`: The interval (in seconds) between checking user input.
   - `$logfile`: The path to the log file.

2. **Defining a Killproc function:**
   The function terminates the specified process and logs information about the termination.

3. **Importing a C# UserInput class:**
   The class exposes methods to check for the last user input timestamp and calculate the idle time.

4. **Entering an infinite loop (`while ($true)`):**
   The loop performs the following actions:
   - Calculates the difference between the current time and the last user input timestamp.
   - If debugging is enabled, outputs the time difference.
   - Sleeps for the specified polling interval.
   - If the time difference is greater than the specified delay for process termination and the process is running, it calls the Killproc function to terminate the process.

This script is useful for monitoring user activity and automatically terminating specific processes when the user is idle for a certain period of time.
