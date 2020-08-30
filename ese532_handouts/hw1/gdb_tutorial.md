# GDB Tutorial

```{include} ../common/aws_caution.md
```
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

void my_broken_function()
{
    int a = 10;
    int *p = NULL;
    printf("Value of a is %d\n", a);
    *p = 1;
}

int main() 
{
    printf("Welcome to the wonderful world of segfaults!\n");
    printf("Brace for impact! We are about to crash!\n");
    my_broken_function();
}
```
Compile and run the code with the following in your AWS A1 instance:
```
gcc -Wall -g -o program program.c
./program
```
You will see the following output:
```
Welcome to the wonderful world of segfaults!
Brace for impact! We are about to crash!
Value of a is 10
Segmentation fault
```

- Let's see what happened here. <u>**Start the program**</u> under gdb using:
    ```
    gdb ./program
    ```
- <u>**Run the program**</u> using `run` command in gdb:
    ```
    (gdb) run
    Starting program: /home/ec2-user/program
    Welcome to the wonderful world of SEG Faults!
    Brace for impact! We are about to crash!
    Value of a is 10
    
    Program received signal SIGSEGV, Segmentation fault.
    0x0000000000400610 in my_broken_function () at program.c:9
    9	    *p = 1;
    ```
- The program has exited with a segfault. While in gdb <u>**restart the program**</u>
using `file ./program`
    ```
    (gdb) file ./program
    Load new symbol table from "./program"? (y or n) y
    Reading symbols from ./program...done.
    ```
- <u>**Stop at the beginning**</u> using `start`:
    ```
    (gdb) start
    Temporary breakpoint 1 at 0x400628: file program.c, line 14.
    Starting program: /home/ec2-user/program
    
    Temporary breakpoint 1, main () at program.c:14
    14	    printf("Welcome to the wonderful world of SEG Faults!\n");
    ```
- <u>**Step to the next line**</u> using `step`:
    ```
    (gdb) step
    _IO_puts (str=0x400730 "Welcome to the wonderful world of SEG Faults!") at ioputs.c:36
    36	  _IO_acquire_lock (_IO_stdout);
    ```
- That looks like code we didn't write. <u>**Find out where you are**</u> by using `list`:
    ```
    (gdb) list
    31	int
    32	_IO_puts (const char *str)
    33	{
    34	  int result = EOF;
    35	  _IO_size_t len = strlen (str);
    36	  _IO_acquire_lock (_IO_stdout);
    37
    38	  if ((_IO_vtable_offset (_IO_stdout) != 0
    39	       || _IO_fwide (_IO_stdout, -1) == -1)
    40	      && _IO_sputn (_IO_stdout, str, len) == len
    ```
- Looks like we are inside the `printf` function. <u>**Step out of the function**</u> using `finish`:
    ```
    (gdb) finish
    Run till exit from #0  _IO_puts (str=0x400730 "Welcome to the wonderful world of SEG Faults!") at ioputs.c:36
    Welcome to the wonderful world of SEG Faults!
    main () at program.c:15
    15	    printf("Brace for impact! We are about to crash!\n");
    Value returned is $1 = 46
    ```
- Looks like we are at the next `printf`. We'd like <u>**step over it**</u>. Use `next`:
    ```
    (gdb) next
    Brace for impact! We are about to crash!
    16	    my_broken_function();
    ```
- That function looks suspicious. We can step into it, but let's <u>**set a breakpoint**</u> inside
that function using `break program.c:8` and <u>**continue to the breakpoint**</u> using `continue`:
    ```
    (gdb) break program.c:8
    Breakpoint 3 at 0x4005f8: file program.c, line 8.
    (gdb) continue
    Continuing.

    Breakpoint 3, my_broken_function () at program.c:8
    8	    printf("Value of a is %d\n", a);
    ```
- Let's <u>**inspect the stack frame**</u>.
    - Use `info frame` to see information on the current stack frame:
        ```
        (gdb) info frame
        Stack level 0, frame at 0xfffffffff370:
         pc = 0x4005f8 in my_broken_function (program.c:8); saved pc = 0x400644
         called by frame at 0xfffffffff380
         source language c.
         Arglist at 0xfffffffff350, args:
         Locals at 0xfffffffff350, Previous frame's sp is 0xfffffffff370
         Saved registers:
          x29 at 0xfffffffff350, x30 at 0xfffffffff358
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
- You can also <u>**print values**</u> using `print`:
    ```
    (gdb) print a
    $2 = 10
    ```
- Let's run till the segfault now using `continue`:
    ```
    (gdb) continue
    Continuing.
    Value of a is 10

    Program received signal SIGSEGV, Segmentation fault.
    0x0000000000400610 in my_broken_function () at program.c:9
    9	    *p = 1;
    ```
- We can see from there gdb output, the segfault happens at line 9.
    However, if you are working on a large codebase, location of the
    segfault might not be trivial. Use `backtrace` to <u>**find out how
    you got to the segfault**</u>:
    ```
    (gdb) backtrace
    #0  0x0000000000400610 in my_broken_function () at program.c:9
    #1  0x0000000000400644 in main () at program.c:16
    ```
- Assuming you couldn't figure out the [cause of the crash](https://en.wikipedia.org/wiki/Segmentation_fault#Null_pointer_dereference) and asked your
    friend for help. The friend compiled the program in their own machine
    and surprisingly ran the program without the segfault! May be if the
    friend ran with the exact replica of the process you were running,
    the segfault would show up. You can do that by supplying your friend
    with a <u>**core dump**</u>. A core dump is a copy of process memory. Your machine
    may be not configured to produce core dumps. Find out the size of a
    core dump your machine allows using:
    ```
    ulimit -c
    ```
    It returns 0, which means you need to increase the size. Let's increase
    the size to a 100 MB using:
    ```
    ulimit -c 100000000000
    ```
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

```{include} ../common/aws_caution.md
```
