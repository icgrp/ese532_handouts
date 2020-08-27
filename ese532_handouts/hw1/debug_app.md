# Debug an Application
```{include} ../common/aws_caution.md
```

1. Create a new source C file and paste the following code in it.
The code should print another message, but due to a bug, it doesn't.
    ```C
    #include <stdio.h>
    
    int len(char* s) {
      int l = 0;
      while (*s) s++;
      return l;
    }
    
    int rot13(int l) {
      if (l >= 'A' && l <= 'Z') l = (l - 'A' + 13) % 26 + 'A';
      if (l >= 'a' && l <= 'z') l = (l - 'a' + 13) % 26 + 'a';
      return l;
    }
    
    char* msg = "Jryy Qbar!!!\n";
    
    int main() {
      int i = 0;
      printf("The secret message is: ");
      while (i < len(msg)) printf("%c", rot13(msg[i++]));
    
      return 0;
    }
    ```
2. Build and run using:
    ```
    gcc -g -o program program.c
    ./program
    ```
    ```{note}
    You need to provide the `-g` option to the compiler to include
    debug symbols in the binary!
    ```
3. You will notice that the output is not correct.  Use `gdb`
to locate the bug in the code.   Specifically, we are asking you to
**not** simply perform `printf` debugging where you insert
code and recompile. If you haven't used a debugger before, take
the time now, during this easy assignment, to learn the basic tricks
of the debugger.  Learn how to set breakpoints, step through code, and
inspect variables. Instructions on how to set breakpoints, view variable
values, and more can be found in the
[GDB documentation](https://sourceware.org/gdb/current/onlinedocs/gdb/).

TODO: need basic gdb tutorial.  I'm afraid the full gdb manual as the first
thing will be daunting.  Show how to do basic things.
* start under gdb
* set breakpoint
* run to breakpoint
* single step
* inspect stack frame
* inspect variables
* run gdb on core dump and get backtrace
Maybe there's one we can point to?


TODO: need to set limit (ulimit) on coredumpsize?  (at least on mac, I do)




4. In your report, describe how you found the bug, how you changed the code, and show the message that should have been displayed.

```{include} ../common/aws_caution.md
```

