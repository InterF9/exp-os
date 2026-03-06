# Stage 16

Console Input is done using Terminal Read of Device Manager. data should arrive in P0. And when the user presses enter/ or is done entering data, the XSM machine will raise console interrupt.

A process executing the IN instruction will be set to WAIT_TERMINAL an dinvoke schedule.

Read system call (interrupt 6)
Terminal Read is function 4 of The Device Manager Module (Module 4)

Keep in mind: Terminal Read function copies data from Input Buffer field to [R3].
THe console interrupt copies data from P0 to Input Buffer Field.

debugging notes:
the IP at 366 says it must go to INT 6.
library.lib says 362 is read and 366 is write

after INT 6 instruction, it goes to empty insjtruction.

Just confirmed that write system call works correctly from the expl problem.
Read system call doesnt seem to be loaded in correctly? fixed: incorred script loaded

2nd bug: int6.xsm is the issue for not passing the right value
fixed: order of passing values was incorrect and i missed it because it was sharing registers for variables
