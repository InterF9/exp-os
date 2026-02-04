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

