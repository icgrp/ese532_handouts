# C Refresher
<style type="text/css">
    ol { list-style-type: decimal; }
    ol ol { list-style-type: lower-alpha; }
    ol ol ol { list-style-type: lower-roman; }
</style>

For some of these questions you will need to compile and run C code.
(For others, you may find it useful to experiment with C code.)
For this section, you may use any editor and C compiler.
If you don't have a favorite C compiler on your personal laptop or PC, you
can use the Biglab. On the Linux machines, you can compile a simple, single C file application in `program.c` using:
```
gcc -o program program.c
```
Following are some recommended resources for learning C:
- Pointers on C by Kenneth Reek
- {download}`gccintro <pdfs/gccintro.pdf>`
- {download}`deep C <pdfs/deep-c-cpp.pdf>`

1. Write the C code to reproduce the contents of the stack and heap
as shown in {numref}`pointer-question-1`. You can use any variable and pointer names with int type. For e.g. `0x5C` is filled with `int x = 20;`.
    ```{figure} images/memory_map_1.png
    ---
    height: 300px
    name: pointer-question-1
    ---
    Memory space with stack and heap
    ```

2. The stack grows downward and the heap grows upwards
(with GCC compiler and Armv8-a architecture we are using).
What happens when stack and heap memory space collide? (4-5 lines)
Your answer should include what happens when you are running your
program under an OS vs when you are running in a bare-metal system.
    ```{hint}
    Think of what guarantees you get in an OS vs guarantees you don't get in a
    bare-metal system.

     A bare-metal system will not have virtual guards on memory regions
     and typically omits checks for bounds on stacks and heaps.
    
    Later in the course when we'll use the Ultra96, we may need to
    increase our stack/heap size in the linker script
    to get the correct output in our program!
    ```

3. {numref}`pointer-question-2` shows the content of an 8 element int array on the stack.
    1. Write the C code to allocate this array on the stack as shown in {numref}`Fig. {number}(a) <pointer-question-2>`, as a 2D array.
    2. Building from (a), declare an array of pointers as shown in {numref}`Fig. {number}(b) <pointer-question-2>`, and use it to print out the contents of the 2D array.
    3. Building from (b), declare a double pointer as shown in {numref}`Fig. {number}(c) <pointer-question-2>`, and use it to print out the contents of the 2D array.
      ```{hint}
      A 2D array is not equivalent to a double pointer! Review
      [these slides](https://cs.brynmawr.edu/Courses/cs246/spring2014/Slides/16_2DArray_Pointers.pdf).
      ```
    ```{figure} images/memory_map_2.png
    ---
    height: 450px
    name: pointer-question-2
    ---
    8 element array on the stack
    ```

4. Considering the following code, give an expression to obtain
the address of `b` that can be accessed via the third
element of `x`. (1 line)
    ```C
    struct s2 {
      float a;
      int b;
    };
    
    struct s1 {
      int c;
      struct s2 **d;
    };
    
    struct s1 x[5];
    ```

5. The following array will be stored as a sequence of bits in
memory.  We could also consider these bits as a sequence
of bytes (`unsigned char`).  Show code that prints those
bytes.   Avoid needless copying or losing information.
Note that an IEEE Double-precision floating-point value is
stored in 64 bits.  You can see
<https://www.geeksforgeeks.org/ieee-standard-754-floating-point-numbers/>
for more information on IEEE Double-precision
floating-point format, but understanding this is not
necessary to your solution, only to understanding what it is
your solution is reporting.
    ```C
    double a[] = {3.14, 2.71};
    ```

6. Put together code to print the address associated with each of the
arrays, `a`, `b`, `c`, and `d`.
Include the code and the results of running it and reporting the addresses.
    ```C
    void temp(int i) {
      int a[2];
      int b[3];
      int *c;
      int *d;
      c = (int *)malloc(sizeof(int) * 4);
      d = (int *)malloc(sizeof(int) * 5);
    
      // print addresses for arrays here....
    
      return;
    }
    ```
7. What might happen with the following code?
    ```C
    int a[3];
    int b[4];
    int c[5];

    // intervening code omitted

    b[4]=13;
    ```
    Many different things could happen.  Give multiple answers.  For each
    identified case, what happens and why (2 lines max for each case).


8. Compile and run the following code.
    ```C
    #include "stdio.h"
    #include "stdlib.h"
    
    int main(int argc, char** argv) {
      unsigned char a[3] = {0xFF, 0x01, 73};
      unsigned char sum;
      unsigned int intsum;
    
      signed char sa[3] = {127, 1, 33};
      signed char ssum;
      signed int sintsum;
    
      fprintf(stdout, "Unsigned:\n");
      for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++) {
          sum = a[i] + a[j];
          intsum = a[i] + a[j];
          fprintf(stdout, "in decimal: %d+%d=%d (intsum=%d)\t", a[i], a[j], sum,
                  intsum);
          fprintf(stdout, "in hexadecimal: %x+%x=%x (intsum=%x)\n", a[i], a[j], sum,
                  intsum);
        }
    
      fprintf(stdout, "Signed:\n");
      for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++) {
          ssum = sa[i] + sa[j];
          sintsum = sa[i] + sa[j];
          fprintf(stdout, "in decimal: %d+%d=%d (intsum=%d)\t", sa[i], sa[j], ssum,
                  sintsum);
          fprintf(stdout, "in hexadecimal: %x+%x=%x (intsum=%x)\n", sa[i], sa[j],
                  ssum, sintsum);
        }
    }
    ```
    Explain the results you get.  Why do the `char` and `unsigned char` sums differ
    from the integer sums?  (2-3 lines each) Why does the computer produce the specific values
    that it does for each of the `char` and `unsigned char` sums? (1-3
    lines each)

9. What is the purpose of the preprocessor, compiler, and
linker? (each 3 lines max.)

    Potentially useful:

    - {download}`gccintro <pdfs/gccintro.pdf>`
    - <https://www.tenouk.com/ModuleW.html>

    [We point you at the gcc documentation because it is easily
    available online.  Many of the options and concepts are the same
    across other C compilers.  In some cases, Xilinx tools will use gcc
    internally.  For some of your development (including, perhaps, for
    this section of this assignment) you may find it useful to get
    your C working on a workstation, laptop, or AWS A1 instance using gcc.]

10. If the preprocessor cannot find a file that is included
with `#include`, give at least three different ways you could resolve
the problem so that the preprocessor can find the file? (1--2 lines each)

    Possibly useful:

    - <https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html#Directory-Options>
    - <http://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html>

11. If the linker gives you an error like `undefined reference to ...`,
identify three reasons this could occur and at least one way to resolve each.
(1--2 lines each)

    Possibly useful:

    - <https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html#Directory-Options>
    - <https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html>
