# Stage 14

couple of notes as i do this:

remember that while setting up the Process Table of even.xsm, KPTR = 0 because KPTR stores the offset and while it is set up, it is 0.
    
timer interrupt:
saves UPTR, R0-R19 registers onto kernel stack
https://exposnitc.github.io/os_design-files/timer.html 


scheduler pseudocode:
BP, SP(KPTR), PTBR, PTLR saved to process table entry
decides which program to run using round robin 
loads new values to SP, PTBR, PTLR from process table of newly selected process.
updates systems status table
if state is READY, changes it to RUNNING
restore BP
returns using return instruction

if the state of the newly selected the program, it does not return back to timer. it DIRECTLY goes back to the new program using ireturn and has no context to restore.

A bit more info on the RR scheduler:
From (currentPID + 1) until PID 15, the first one to be in READY/CREATED is executed first.
If none is found, we cycle back and to schedule to the next one, which is idle.

question: what happens to BP when the new program is in CREATED? is it not restored?

current issues:
seems to be switching between IDLE and PID 1 all the time: but PID 1 is not being executed
init was never scheduled?

fixed! the issue was when setting up the process table of the Executable; it was modifying the same files of init.
