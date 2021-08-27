# GDB Tutorial

GDB is like a swiss-army knife to a C/C++ developer. You can step through
your code line-by-line, view call stacks, view assembly, and most importantly---
find the source of a bug! If you haven't used a debugger before, take
the time now, during this easy assignment, to learn the basic tricks
of the debugger.  Learn how to set breakpoints, step through code, and
inspect variables. If you know how to debug using `gdb` you can skip this section.

---
Consider the following code:
```C
#include <stdio.h>
#include <stdlib.h>

void log_msg(char* string) {
    printf(string);
}

void my_broken_function()
{
    int a = 10;
    int *p = NULL;
    printf("Value of a is %d\n", a);
    *p = 1;
}

int main()
{
    log_msg("Welcome to the wonderful world of segfaults!\n");
    log_msg("Brace for impact! We are about to crash!\n");
    my_broken_function();
}
```
Compile and run the code with the following:
```
gcc -Wall -g -o program program.c
./program
```
You will see the following output:
```
Welcome to the wonderful world of segfaults!
Brace for impact! We are about to crash!
Value of a is 10
Segmentation fault (core dumped)
```

- Let's see what happened here. <u>**Start the program**</u> under gdb using:
    ```
    gdb ./program
    ```
- <u>**Run the program**</u> using `run` command in gdb:
    ```
    (gdb) run
    Starting program: /mnt/castor/seas_home/s/stahmed/ese532_code/hw1/tutorial/program 
    Missing separate debuginfos, use: zypper install glibc-debuginfo-2.31-7.30.x86_64
    Welcome to the wonderful world of segfaults!
    Brace for impact! We are about to crash!
    Value of a is 10

    Program received signal SIGSEGV, Segmentation fault.
    0x0000000000400556 in my_broken_function () at program.c:13
    13	    *p = 1;
    ```
- The program has exited with a segfault. While in gdb <u>**restart the program**</u>
using `file ./program`
    ```
    (gdb) file ./program
    A program is being debugged already.
    Are you sure you want to change the file? (y or n) y
    Load new symbol table from "./program"? (y or n) y
    Reading symbols from ./program...
    ```
- <u>**Stop at the beginning**</u> using `start`:
    ```
    (gdb) start
    The program being debugged has been started already.
    Start it from the beginning? (y or n) y
    Temporary breakpoint 1 at 0x400563: file program.c, line 18.
    Starting program: /mnt/castor/seas_home/s/stahmed/ese532_code/hw1/tutorial/program 
    Missing separate debuginfos, use: zypper install glibc-debuginfo-2.31-7.30.x86_64

    Temporary breakpoint 1, main () at program.c:18
    18	    log_msg("Welcome to the wonderful world of segfaults!\n");
    ```
- <u>**Step to the next line**</u> using `step`:
    ```
    (gdb) step
    log_msg (string=0x400630 "Welcome to the wonderful world of segfaults!\n") at program.c:5
    5	   printf(string);
    ```
- <u>**Find out where you are**</u> by using `list`:
    ```
    (gdb) list
    1	#include <stdio.h> 
    2	#include <stdlib.h>
    3	
    4	void log_msg(char* string) {
    5	   printf(string);
    6	}
    7	
    8	void my_broken_function()
    9	{
    10	    int a = 10;
    ```
- Looks like we are inside the `log_msg` function. <u>**Step out of the function**</u> using `finish`:
    ```
    (gdb) finish
    Run till exit from #0  log_msg (string=0x400630 "Welcome to the wonderful world of segfaults!\n")
        at program.c:5
    Welcome to the wonderful world of segfaults!
    main () at program.c:19
    19	    log_msg("Brace for impact! We are about to crash!\n");
    ```
- Looks like we are at the next `log_msg`. We'd like to <u>**step over it**</u>. Use `next`:
    ```
    (gdb) next
    Brace for impact! We are about to crash!
    20	    my_broken_function();
    ```
- That function looks suspicious. We can step into it, but let's <u>**set a breakpoint**</u> inside
that function using `break program.c:12` and <u>**continue to the breakpoint**</u> using `continue`:
    ```
    (gdb) break program.c:12
    Breakpoint 2 at 0x40053e: file program.c, line 12.
    (gdb) continue
    Continuing.

    Breakpoint 2, my_broken_function () at program.c:12
    12	    printf("Value of a is %d\n", a);
    ```
- Let's <u>**inspect the stack frame**</u>.
    - Use `info frame` to see information on the current stack frame:
        ```
        (gdb) info frame
        Stack level 0, frame at 0x7fffffffdd90:
        rip = 0x40053e in my_broken_function (program.c:12); saved rip = 0x400581
        called by frame at 0x7fffffffdda0
        source language c.
        Arglist at 0x7fffffffdd80, args: 
        Locals at 0x7fffffffdd80, Previous frame's sp is 0x7fffffffdd90
        Saved registers:
        rbp at 0x7fffffffdd80, rip at 0x7fffffffdd88
        ```
    - Use `info locals` to see the local variables and their values in the stack frame:
        ```
        (gdb) info locals
        a = 10
        p = 0x0
        ```
    - Use `info args` to see the arguments to the function:
        ```
        (gdb) info args
        No arguments.
        ```
	- If you did not already know where the bug was,  this  frame information should help you decipher why the program crashed.
	
- You can also <u>**print values**</u> using `print`:
    ```
    (gdb) print a
    $1 = 10
    ```
- Let's run till the segfault now using `continue`:
    ```
    (gdb) continue
    Continuing.
    Value of a is 10

    Program received signal SIGSEGV, Segmentation fault.
    0x0000000000400556 in my_broken_function () at program.c:13
    13	    *p = 1;
    ```
- We can see from there gdb output, the segfault happens at line 13.
    However, if you are working on a large codebase, location of the
    segfault might not be trivial. Use `backtrace` to <u>**find out how
    you got to the segfault**</u>:
    ```
    (gdb) backtrace
    #0  0x0000000000400556 in my_broken_function () at program.c:13
    #1  0x0000000000400581 in main () at program.c:20
    ```
- Assuming you couldn't figure out the [cause of the crash](https://en.wikipedia.org/wiki/Segmentation_fault#Null_pointer_dereference) and asked your
    friend for help. The friend compiled the program in their own machine
    and surprisingly ran the program without the segfault! May be if the
    friend ran with the exact replica of the process you were running,
    the segfault would show up. You can do that by supplying your friend
    with a <u>**core dump**</u>. A core dump is a copy of process memory.
    You will not be able to do the following in Biglab since core dumps
    are disabled there, however the steps are listed here for your reference.
    Your machine
    may be not configured to produce core dumps. Refer to this [blog](https://jvns.ca/blog/2018/04/28/debugging-a-segfault-on-linux/) post on how to setup your personal machine for core dumps.
    
    Now run your program. It now segfaults by saying `core dumped`:
    ```
    Welcome to the wonderful world of SEG Faults!
    Brace for impact! We are about to crash!
    Value of a is 10
    Segmentation fault (core dumped)
    ```
    You will also see there is a file in your directory called `core.*`.
    This is the core dump. Now you can run gdb with this core dump using
    `gdb ./program <your core dump file>` and it will
    reproduce the state your program was in until the crash:
    ```
    [ec2-user@ip-172-31-38-93 ~]$ gdb program core.1720
    GNU gdb (GDB) Red Hat Enterprise Linux 8.0.1-30.amzn2.0.3
    Copyright (C) 2017 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
    and "show warranty" for details.
    This GDB was configured as "aarch64-redhat-linux-gnu".
    Type "show configuration" for configuration details.
    For bug reporting instructions, please see:
    <http://www.gnu.org/software/gdb/bugs/>.
    Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.
    For help, type "help".
    Type "apropos word" to search for commands related to "word"...
    Reading symbols from program...done.
    [New LWP 1720]
    Core was generated by `./program'.
    Program terminated with signal SIGSEGV, Segmentation fault.
    #0  0x0000000000400610 in my_broken_function () at program.c:9
    9	    *p = 1;
    (gdb)
    ```

---
This concludes a basic introduction to debugging using gdb.
Following are some resources that you may find helpful:
- <http://www.brendangregg.com/blog/2016-08-09/gdb-example-ncurses.html>
- [GDB documentation](https://sourceware.org/gdb/current/onlinedocs/gdb/)
- {download}`gccintro <pdfs/gccintro.pdf>`
