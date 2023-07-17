#About

This PS script is intended to add a scheduled task with the current logged-in user as principal when running in a system context (i.e., from an Automox worklet) 

As it is given here, it is adding a specific task that regularly checks and moves the contents of redirected home folders back to local home directory (where GPO has failed to do so).

It can be genericized or repurposed to add any scheduled task in the user context: Simply change the values assigned to `$TaskName`, `$ScriptPath`, `$ScriptContent`, `$Trigger`, and `$Trigger.EndBoundary` 