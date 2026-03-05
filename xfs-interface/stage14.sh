fdisk
load --os ../stage14/os_startup.xsm
load --int=timer ../stage14/timer.xsm
load --int=7 ../spl/spl_progs/sample_int7.xsm
load --init ../stage14/odd.xsm
load --idle ../stage14/idle.xsm
load --exec ../stage14/even.xsm
load --library ../expl/library.lib
load --int=10 ../stage14/int10.xsm
load --exhandler ../stage14/haltprog.xsm
load --module 7 ../stage14/mod7_boot.xsm
load --module 5 ../stage14/mod5_scheduler.xsm
exit
