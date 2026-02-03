# exp-os
An Experimental Operating System for the OS Lab under NITC's CSE Curriculum. The goal for this project is to create a primitive operating system within 3 months by building upon the necessary files and resources maintained by the alumni.

##Stage 1:

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

Finally, run __make__ again. It should produce all the necessary directories other than the 'test' folder.
