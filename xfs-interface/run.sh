fdisk
load --int=7 ../spl/spl_progs/sample_int7.xsm
load --int=timer ../spl/spl_progs/sample_timer.xsm
load --int=10 ../spl/spl_progs/haltprog.xsm
load --module 7 ../spl/spl_progs/bootmodule.xsm
load --module 5 ../spl/spl_progs/scheduler.xsm
load --os ../spl/spl_progs/os_startup.xsm
load --exec ../expl/expl_progs/odd.xsm
load --idle ../expl/expl_progs/idle.xsm
load --init ../expl/expl_progs/even.xsm
