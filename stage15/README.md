# Stage 15

hi gang welcome to stage 15
Resource Manager Module - Module 0
a process needs to "acquire" a resource before it can be used. if the resource requested by a process is not available, then that process has to be blocked until it becomes free (process must be put in WAITING state).

When a process releases a resource, all the processes waiting for that specific resource must be put to READY

Terminal Status Table, a DS thats used for keeping track of which process is using the terminal: 4 Bytes (1Status + 1PID + 2)
Acquire Terminal function - 8
Release Terminal Function - 9

"Terminal Write" is a function(funciton 3) of the Device Manager Module (Mod 4), which calls on the above two functions to run its purpose.

THe invoker must save regisrets into the kernel stack of the program before invoking the module; the module sets its return value in R0 before returning to caller
THe invoker must extract the return value, then pop back the saved registers and resume execution

also in MOD 0, function 8: the acquire resouce function; its not necessary that we push/pop R0 because its just a return value.

Use 'tst' command in debug mode to view contents of terminal status table. initially theres a breakpoint in the os_startup.xsm. ignore that, and in the next breakpoints you can see the values of tst
