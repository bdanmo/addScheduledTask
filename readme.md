#About
This PS script is intended to add a scheduled task in the logged-in user context.

As it is given here, it is adding a specific task that migrates the contents of redirected home folders back to local home directory (where GPO has failed to do so).

It can be genericized or repurposed to add any scheduled task in the user context: Simply change the values assigned to `$TaskName`, `$ScriptPath`, `$ScriptContent`, `$Trigger`, and `$Trigger.EndBoundary` 