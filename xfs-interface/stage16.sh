fdisk
load --os ../stage14/os_startup.xsm
load --int=timer ../stage14/timer.xsm
load --int=console ../stage16/console.xsm
load --int=7 ../stage15/int7.xsm
load --int=6 ../stage16/int6.xsm
load --init ../stage16/gcd.xsm
load --idle ../stage14/idle.xsm
load --exec ../stage14/even.xsm
load --library ../expl/library.lib
load --int=10 ../stage14/int10.xsm
load --exhandler ../stage14/haltprog.xsm
load --module 7 ../stage16/mod7_boot.xsm
load --module 5 ../stage14/mod5_scheduler.xsm
load --module 4 ../stage16/mod4_device.xsm
load --module 0 ../stage15/mod0_resource.xsm
exit
