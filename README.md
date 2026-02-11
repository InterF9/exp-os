# exp-os
An Experimental Operating System for the OS Lab under NITC's CSE Curriculum. The goal for this project is to create a primitive operating system within 3 months by building upon the necessary files and resources maintained by the alumni.

## Stage 1:

1. This stage involves downloading and installing the necessary libraries required to setup expos on the system.
2. After which, we download the resources and executables required for the operating system using the __curl__ command.
3. The next step asks to use the make command in the myexpos directory but this operation fails for no clear reason.

These errors mainly come from a file named: lex.yy.c which is generated after a .l (a Lex / Flex file) gets compiled. The different types of errors are primarily a Wimplicit-function-declation or Wint-conversion. These specific exceptions are raised because before  the release of gcc-14 (since May 2024), these were regarded as warnings. gcc-14 promoted these warnings to errors, which is why the **make** command fails to execute completely.

To mitigate this, we could just revert to a previous version of gcc in which these were considered as warnings. gcc-13 is a very apt choice and does not produce these errors. Hence, we uninstall gcc-14 and install gcc-13 using:

```markdown
sudo apt-get remove gcc

sudo apt-get install gcc-13
```

Since we have installed a previous version of gcc, we must update the Makefiles to look for this specific version.

4. Open Makefile in the myexpos directory. Add a line "cc=gcc-13" Here cc is a variable that stores the name of the C Compiler which is used on the system. Adding this line explicitly tells the **make** command to use gcc-13.
5. Within the subdirectory of the myexpos folder, each of them contain a Makefile in which "cc=gcc" is mentioned at the top. Modify this line to mention "cc=gcc-13". 
6. One thing to note is that the Makefile in the xsm folder has "cc=cc" mentioned which could just be a typing error; correct this to "cc=gcc-13" as done previously.

Finally, run __make__ again. It should produce all the necessary directories other than the 'test' folder. Note: it may generate a bunch of errors but this is fine because we rolled back the version of gcc to a version which treats the fatal errors as warnings.


## Stage 2:

Three Types of Files: Root File, Data File, Executable file (XEXE). The XFS disk has certain blocks reserved for storing the metadata of the files on disk. 

Each data file / executable takes atmost 4 data blocks = 4 * 512 words = 2048 words

### Root File:
The root file has name root. Each entry in the root file is 8 words: FILENAME:1 FILESIZE:1 FILETYPE:1 USERNAME:1 PERMISSION:1 Unused:3
The Username and Permission field is only used in the case of multiuser extension. The first root entry is for the root file itself.

Also, MAX_FILE_NUM = 60 files. 60 entries = 60 * 8 words = 480 words
A memory copy is stored in page 62 and ROOT_FILE points to the start of this data structure. 
username = the name of the user that owns the file


### Inode Table:
Each entry in inode table is 16 words. 8 of which is equivalent of what is used in Root File. 3 words + 2 words + 3 Unused. BUT 4TH WORD IS USERID, NOT USERNAME LIKE BEFORE.Then we have data blocks 1 to 4. each data block stores the block number of a data block of the file. then 4 is unused.

Userid = index of the user in the usertable. (kernel = 0, root = 1) 

Unused entries = -1

fdisk: initialises the inode entry table with the values FILE_TYPE = 1, FILE_SIZE = 512, DATA_Block = 5 (stored in the 5th block, as per Memory Organisation)

Free inode entry: -1 in file name field.

A memory copy is stored in page 59 and INODE_TABLE points to the start of this data structure.

Procedures done during fdisk (format disk):
1. Initialises the inode entry table with the values FILE_TYPE=1, FILE_SIZE = 512, DATA_BLOCK = 5
2. default password of root user is set to `user`

## XFS-Interface

The interface provided by expos that allows for transfer of files to the XFS and also tools for handling the file system / disk.
Some commands of xfs-interface:

```markdown
fdisk : Format Disk
load --data $HOME/myexpos/sample.dat
```

two things happen when the load command is executed:
1. since this is less than 512 words, only 1 block is necessary for this and hence the system allocator, allocates the first block available which is block 69.
2. an entry is made in inode table. since this file was loaded in through xfs-interface, the owner would be root and hence the userid field in the inodetable would be 1.

command copy <x> <y> <path> would dump blocks x to y in path. Since 60 entries (remember MAX_FILES_NUM = 60 files) each 16 words, gives us 60 * 16 = 960 words + user table(MAX_USERS = 16), each 2 words, gives us 16 * 2 words = 32 words

commands like `dump --inodeusertable` can also be used to dump the table directly to ./xfs-interface/inodeusertable.txt

now lets retrieve back the data we've loaded in, which was loaded in block 69 by the internal allocator. we can use the aforementioned copy command to get this.

```markdown
copy 69 69 $HOME/myexpos/data.txt
```
We would get the entire data in that block writtenin the txt file. But it will not have the same line formatting as the input file.
This is because each word is 16 characters long (can we assume 1 word = 16 bytes) and it would return word by word.

Alternative method to retrieve data from xfs: use export command, with the internal file name, and it will work. for ex:

```markdown
export sample.dat $HOME/myexpos/data.txt
```

Inode table accessible by kernel only (access to datablock info i guess?)
Root file accessible in both kernel and user mode. easier to search for a file from an application program.

## Stage 3

Understanding the machine organisation: There are two main modes of execution: privileged mode and unprivileged mode.
Privileged mode gives full access to the memory and the disk.
Unprivileged mode has access only to a restricted machine model called the XSM virtual machine. it is a subset of what is available in the privileged mode. this restricted machine model consists of the: virtual machine instruction set and the virtual machine memory model.

Why does this separation exist? This model allows sandboxing of applications and software. So, when one piece of software crashes, it doesn't end up writing to some other memory location that's used for something critical. 
The translation mechanism (in the next stages) restricts the access of memory

### Bootstrap

Disk blocks 0 to 1 store the bootstrap. block 0 specifically, will contain the OS Startup code.
When the OS Starts up, the ROM Code is stored in the memory by default at page 0. it has two primary functions:
1. it loads block 0 (the OS Startup Code, part of the bootstrap) onto memory page 1. remember: page 0 stores the ROM Code always.
2. it sets the value of the IP (instruction pointer) to 512 which points to the beginning of page 1, where the OS Startup code would be stored.

After making helloworld.xsm, we are going to load into the block 0 of disk.xfs

We use the following command:

```markdown
# load --os <UNIXpath>
```
This loads the file <UNIXpath> onto block 0 of disk.xfs

We can now run the experimental string machine (xsm) and see the output as:
```markdown
HELLO_WORLD
Machine is halting.
```


## Stage 4
Stage 4 involves writing low level code or modules using SPL, a much easier language to facilitate the process of building these modules. In this stage, we are writing a simple program to print odd numbers from 1 to 20.

we use the keyword alias to store temporary data in registers, like traditional variables.

## Stage 5

Stage 5 introduces the concept of a debug mode and instructions that help us to debug a program by certain methods, one of them being viewing the contents of the registers / memory for each instruction.

NOTE: Each instruction = 2 words.
1 word = 16 bytes

using ./xsm --debug only processes the breakpoint statements and pauses. otherwise, it ignores as if it were never there. 
in debug mode, the following commands are available
1. `reg` shows the values of the registers at that point of time.
2. `mem <x>` dumps the values of the memory page x into a file in the CWD.
3. `s` executes the next instruction (if any).
4. `c` executes the instructions until the next breakpoint (if any).


# XSM Virtual Machine Model and The Page Table

Only a few of the registers are available in unprivileged mode, namely: R0-R19, BP, SP, IP.
The virtual model is a continguous address space from 0 -> 512 * **PTLR** - 1 (PTLR = Page Table Length Register)

Each application only gets PTLR words of memory. And the logical page number the process uses, is not necessarily the same as the physical address.
So, we create a mapping from the logical address (0 to 512 * PTLR - 1) to the physical addresses.
This mapping is stored in the **Page Table**.
The page table, has entries that specify which physical page it has to refer to, as well as the permissions associated to that page.
so each entry looks like this:

PHYSICAL PAGE #0
AUXILIARY INFO #0
PHYSICAL PAGE #1
AUXILIARY INFO #1
.
.
PHYSICAL PAGE #PTLR * 512 - 1
AUXILIARY INFO #PTLR * 512 - 1

This is the structure of the Page Table in which 2 words consist of 1 page.
The auxiliary bits are **R**eferenced **V**alidity **W**rite **D**irty

Reference bit: Whether the page has been referenced or not. 0 on initialization, 1 after it gets referenced.
Validity Bit: Whether the page entry corresponds to a valid page within the memory. 1 if valid, 0 if not
Write Permission Bit: 1 if the user mode program is allowed to write into it. 0 if not. Exception if tried to write while 0.
Dirty Bit: Set to 1 if an instruction modifies the contents of the page.

to recap: Page Table stores information about which page each virtual page refers to, and its permissions.

but the translation isnt done just by referring to the pt. we take the address, find WHICH corresponding page to refer to. how do we do this?
let's keep one thing in mind: we really are finding the mapping of which page to refer to. the offset remains __same__. the offset with respect to the logical page as well as the physical page is the same.

now. which entry of the page table do we refer to? we refer to the (LogicalAddress // 512)<sup>th</sup> __entry__.
Now, remember, if you are at the nth entry, the next entry will start after 2 words, and the one after that will be 2 words later. So, in essence: The __location__ would be 2 * (LogicalAddress // 512). now, since we're looking at the entries of the page table, we should start from the PTBR value.


```markdown
PhysicalPageNumber  = the value at: PTBR + 2 * (LogicalAddress // 512)
                    = [PTBR + 2 * (LogicalAddress // 512)]
```

now, remember offset of the address from the beginning of the page is same.

```markdown
OffsetPhysical = OffsetLogical
OffsetPhysical = LogicalAddress % 512
```

Finally, combining it all:

```markdown
PhysicalAddress = PhysicalPageNumber * 512 + OffsetPhysical
                = [PTBR + 2 * (LogicalAddress // 512)] * 512 + LogicalAddress % 512
```

oh also remember the index starts from 0.

## Stage 6

quick exercises to make us familiar with the translation.
ensure it stays within PTLR.

This stage involves creating a program that runs in user mode. When a program is in execution we call it a **process**

onej thing to note: these xsm codes don't recognise labels.

oh also: IN and OUT are privileged instructions. we cannot run them in user mode applications. but we would do this indirectly by later implementing a syscall handler(number 5) which invokes interrupt 7 which uses a print statement in SPL, that uses the OUT keyword.

to halt programs, we use the INT 10 interrupt. and now we would write code for this interrupt. a simple `halt` written in spl and then compiled to xsm would do the job.
after which, we load it into the machine for the specific interrupt location which we're able to do by 

```markdown
load --int=10 <path>
```

We also use the same haltprog.xsm as a handler for exceptions; any time the system encounters an exception, we execute the interrupt handler for exceptions which would run the same program.
Exceptions raise interrupt 0.

## The OS Startup Code

//1. Load INIT from disk to memory
//2. Load INT10 Module
//3. Load Exception Handler
//4. Setup page table registers
//5. Setup page table for the page mapping + auxilliary info
//6. Push 0 into stack, and set value of SP to point at that value
//7. ireturn :)

we do these tasks to facilitate the virtual memory mode of the init program and then finally, set the stack pointer to point at the value 0 in the stack page which indicates to start executing the next instruction from the start of the code of the init program. this os_startup file sets the context for executing the os_startup spl

Also, keep a note of the final stack thing and the steps regarding the ireturn.

1. privilege changes from kernel to user
    what do we infer from this? since the privilege has changed to the user mode, we'll be using the address translationj scheme. in this scheme for atleast this program, we're using 2 pages code + 1 page stack.
2. in order for the IP to point at the start of the program, we just have to make IP = 0; translation would ensure it would be at the start of the page.
3. And then the value of SP is decremented by 1.


## Stage 7

ABI refers to the bridge between the user application and kernel
Since we moved the code page from page 0 to page 4, we add 2048 words to the jump addresses, making up for the shift. additionally, we add 8 words, to satisfy the XEXE format

one thing to note: the standard xsm instruction is 2 words. but the values of the header info is just 1 word. so make changes accordingly 

When the program starts up, the first 2 pages are occupied for the library's code
Page 2 and 3 are taken for heap space

//1. Load library from 13 14 to 63 64
//2. Preload the library to the disk block

Library at pages 63 , 64
Heap at 78, 79
Code 65 66
Stack 76 77


Also: i had an encounter where it would randomly change the IP in between; this was actually the timer interrupt changing the IP and took me a couple of minutes to debug.... lowkey the perfect hint at the next stage

## Stage 8

# Timer Interrupt:

`xsm --timer 10` runs the interrupt timer every 10 instructions.

After every 10 instructions, the following happens:
1. Pushes IP onto stack
2. Sets IP to 2048 (gets it from the interrupt vector table entry at location 493, which points to address 2048).
3. Switches to privileged mode, and address translation is disabled.

this is similar to the INT instruction but here the user application has no control of this happening
Also: no timer interrupts in kernel mode
**In a time sharing environment, the timer interrupt invokes the scheduler of the OS to schedule another process, when the current process has finished its time quanta.**

## Stage 9

We need to maintain two separate stacks, one for unprivileged and one for privileged. this is mainly for preventing hacks or restricted access.

So, we actually have a data structure named the **process table** that stores info regarding a process. for example here, the user stack pointer and user area page number. The kernel assigns each process a user area page. despite its name, it is created by the kernel for a process. each user area page consists of a kernel stack and a per process resource table. 
 
This process table starts from page number 56 (address 28672). it has space only for 16 entries (remember max 16 processes!) and each entry consists of 16 words. Since we only have one word, we'll be using the first 16 words from the aforementioned address.

### Kernel Stack Management during hw interrupts and exceptions:

Since the application does not have control over the transfer to the interrupt module, it would not have saved its context.
In KPTR, the offset of the SP register within the User Area Page will be stored. not the actual physical address. This is to ensure that if the kernel relocates the user area page, the KPTR doesn't have to be affected.

On entering a kernel module from user process, kStack = empty hence KPTR = 0.
In usermode, kernel stack = empty, hence KPTR = 0;

### Actions done upon entering the ISR (Interrupt Service Routine):

IP+2 is ushed first
1. Store value of SP to UPTR field (this process table entry now knows where to go back to)
2. SP = UserAreaPageNumber * 512 - 1 (kernel stack is empty upon entry)
3. save values of machine registers to the stack in the order: BP, R0 - R!9 with the BACKUP instruction. remember: this is saved in the kernel stack!
4. Continue execution of ISR

### Actions done upon leaving the ISR (Interrupt Service Routine):
1. Execution of ISR is done
2. Restore the values of the registers using RESTORE keyword
3. SP = UPTR
4. Transfer control back

For assignment: Just add in `PRINT [SYSTEM_STATUS_TABLE + 1];`
