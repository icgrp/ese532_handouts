# Debug an Application
```{include} ../common/aws_caution.md
```

<!-- \fixme{should they use eclipse for this to get prepared for Xilinx later?
  Do they need a bit of a getting-started-on-eclipse exercise before this
  (was a first SDSoC project before this that removed)?} -->

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
2. % Build and run...
3. You will notice that the output is not correct.  Use the debugger
to locate the bug in the code.   Specifically, we are asking you to
**not** simply perform `printf` debugging where you insert
code and recompile. If you haven't used a debugger before, take
the time now, during this easy assignment, to learn the basic tricks
of the debugger.  Learn how to set breakpoints, step through code, and inspect variables. Instructions on how to set breakpoints, view variable values, and more can be found in the [Eclipse documentation](http://help.eclipse.org/mars/index.jsp?topic=\%2Forg.eclipse.cdt.doc.user\%2Ftasks\%2Fcdt_o_run.htm).

4. In your report, describe how you found the bug, how you changed the code, and show the message that should have been displayed. 
<!-- 

 \fixme{FUTURE note: should we also force them to use gdb? \\
   Claim is that many students for the project are developing in gcc to
   avoid the longer SDSoC compile time, but don't know how to debug.
    So, do they need to be shown that they can use gdb for debugging?} -->

% AMD: thinking should prioritize additional C warmup stuff (Below).
%%   Maybe gdb should be on P1?

