# Homework Submission

Your writeup should follow [the writeup guidelines](../writeup_guidelines).
Your writeup should include your answers to the following questions:

<style type="text/css">
    ol { list-style-type: decimal; }
    ol ol { list-style-type: lower-alpha; }
    ol ol ol { list-style-type: lower-roman; }
    table { width: 100%; }
    td {height:50px;text-align: center;}
    tr:nth-child(even) {background-color: #f2f2f2;}
</style>

1. **Teamwork**

    As the difficulty of homework is ramping up, we encourage you to spend
    a moment planning on how to tackle the homework as a team.
    1. Describe which tasks of this homework you will perform, which
        tasks will be performed by your teammate(s), and which tasks
        you will perform together (e.g., pair programming, where you
        both sit together at the same terminal).  Motivate your task
        distribution. (5 lines)
    2. Give an estimate of the duration of each of the tasks. (5 lines)
    3. Record the actual time spent on tasks as you work through
        the assignment.
    4. Explain how you will make sure that the lessons and
        knowledge gained from the exercises are shared with
        everybody in the team. (3 lines)

2. **Compiler Optimizations**
    
    Before we dive into the vector optimizations, we will investigate the
    effects of different levels of compiler optimizations.
    ```{list-table} Latency and Code size per Optimization Level
    :header-rows: 1
    :name: optimization-table

    * - Optimization level
      - Latency (ns)
      - Code size (bytes)
    * - `-O0`
      -  
      -  
    * - `-O1`
      -  
      -  
    * - `-O2`
      -  
      -  
    * - `-O3`
      -  
      -  
    * - `-Os`
      -  
      -  
    ```
    ```{important}
    - You will compile all code in this homework directly in the Ultra96.
    The `g++` compiler in the Ultra96 is the ARM compiler.
    - You should edit your code in your host computer (`vim` in the Ultra96
    doesn't work properly). Every time you edit, you can `scp` your revised code,
    or:
        - use *Remote Explorer* in VSCode to open a connection to the Ultra96 or
        - if on Windows, use MobaXterm to directly edit the files in the device.
    - Make sure that you are able to keep track of your edited files. Given
    there is no internet connection in the Ultra96 at the moment, you should
    copy back results as needed and version control your code using git repositories in your host computer.
    ```
    1. Measure the latency and size of the `baseline` target at the
        different optimization levels. Put your measurements in a table like
        {numref}`optimization-table`. You can change
        the optimization level by editing the `CXXFLAGS` in the hw4 Makefile.
    2. Include the assembly code of the innermost loop of `Filter_horizontal`
        at optimization level `-O0` in your report. Use the following command to get the assembly and then look for `Filter_horizontal` in `Filter_O1.s`:
        ```
        g++ -S -O0 -mcpu=native -fno-tree-vectorize Filter.cpp -o /dev/stdout | c++filt > Filter_O1.s
        ```

        ```{note}
        `-fno-tree-vectorize` disables automatic vectorization. We will
        look at automatic vectorization in the next section.
        ```
    3. Include the assembly code of the innermost loop of `Filter_horizontal` at optimization level 
        `-O2` in your report.
    4. Based on the machine code of questions 2.2 and 2.3, explain the most important 
        difference between the `-O0` and `-O2` versions. (2 lines)
        ```{hint}
        Leading questions:
        - for each case (`-O0`, `-O2`), how many times does the
            loop read the variable i?
        - for each case (`-O0`, `-O2`), how many times does the
            loop read and write the variable Sum?
        - why is the `-O2` loop able to avoid
            recalculating `Y*INPUT_WIDTH+X` inside the loop
            body? 
        - what else is the `-O2` loop able to avoid reading from
            memory or recaculating?
        - how is the `-O2` loop able to perform fewer operations?
        ```
    5. Why would you want to use optimization level `-O0`? (3 lines)
        ```{hint}
        Compile the code with `-O3` and track the values of the
        variables `X`, `Y`, and `i` as you step through
        `Filter_horizontal`.  
        ```
    6. Include the assembly code of the innermost loop of
        `Filter_horizontal` at optimization level `-O3` in your report.
    7. Based on the machine code of questions 2.3 and
        2.6, explain the most important difference between the
        `-O2` and `-O3` versions. (1 line)
    8. What are two drawbacks of using a higher optimization level? (5 lines)

3. **Automatic Vectorization**
    
    The easiest way to take advantage of vector instructions is by using
    the automatic vectorization feature of the GCC compiler, which
    automatically generates NEON instructions from loops.
    Automatic vectorization in GCC is sparsely documented in the [GCC documentation](https://gcc.gnu.org/projects/tree-ssa/vectorization.html).
    Although we are not using the ARM compiler, the
    [ARM compiler user guide](http://infocenter.arm.com/help/topic/com.arm.doc.dui0472m/chr1359124204202.html)
    may give some more insight on how to style your code for auto
    vectorization.  This
    [talk on GCC vectorization](http://hpac.cs.umu.se/teaching/sem-accg-16/slides/08.Schmitz-GGC_Autovec.pdf)
    may also be useful.
    ````{admonition} Vectorization Speedup Summary
    :class: full-width

    ```{list-table} Vectorization Speedup Summary
    :header-rows: 2
    :name: vectorization-table

    * -  
      - Baseline
      -  
      -  
      - Baseline with SIMD 
      -  
      - Baseline with SIMD Modified
      -  
    * -  
      - Latency (ns) 
      - Suitability (Y/N)
      - Ideal Vectorization Speedup 
      - Latency (ns)
      - Speedup
      - Latency (ns)
      - Speedup
    * - `Scale`
      -  
      -  
      -  
      -  
      -  
      -  
      -  
    * - `Filter_horizontal`
      -  
      -  
      -  
      -  
      -  
      -  
      -  
    * - `Filter_vertical`
      -  
      -  
      -  
      -  
      -  
      -  
      -  
    * - `Differentiate`
      -  
      -  
      -  
      -  
      -  
      -  
      -  
    * - `Compress`
      -  
      -  
      -  
      -  
      -  
      -  
      -  
    * - Overall
      -  
      - N/A
      - 
      -  
      -  
      -  
      -  
    ```
    ````
    
    1. Report the latency of each stage of the baseline application at
        `-O3`. (Start a table like {numref}`vectorization-table`; we will continue to fill in this
        table throughout this problem.)
    2. Based on your understanding of the C code, which loops in
        the streaming stages of the application have 
        sufficient data parallelism for vectorization?  Motivate your answer.
        (Mark suitability by filling in Yes or No in the suitability column of {numref}`vectorization-table`; add explanation in 2--5 lines after table.)
    3. Identify the critical path lower bound for `Filter_vertical` in
        terms of compute operations.  Focus on the data path.  Ignore
        control flow and offset computations. You may assume
        associativity for integer arithmetic. (5 lines)
        ```{hint}
        Consider only the dependencies in the computation.  What
        happens if you unroll the loops completely?
        ```
    4. What is the size of the (non-index) multiplications performed in
        `Filter_vertical`?  (How many bits for each of the input
        operands?  How many bits are necessary to hold the output?)
        (one line)
    5. Report the resource capacity lower bound for
        `Filter_vertical`. Focus on the computation; you may ignore control flow and
        addressing computations. There are many resources that may limit the performance.  
        (5 lines)
        ```{hint}
        - As with any resource capacity lower bound analysis, you
        may have multiple resources and may need to consider them each
        to identify the one that is most constraining.
        - You will need to review the NEON architecture (which we
        discussed in class and in {doc}`walk_through`) and reason  about what resources it has
        available to be used on each cycle. Think about how vectorization
        could exploit the set of computations a NEON unit can do in parallel. 
        - You may also need to review whether the size of variables involved in the computation are optimal
        ```
    6. What speedup do you expect your application can achieve if the compiler is able to 
        achieve the resource bound identified in 3e? (5 lines)
        ```{hint}
        Remember Amdahl's Law; think about critical path lower
        bounds and resource capacity lower bounds.
        ```
        (Fill in the ideal vectorization speedup column in {numref}`vectorization-table`; separately show Amdahl's Law calculation for overall speedup.)
    7. We will now enable the vectorization in g++. You can enable it by removing
        the `-fno-tree-vectorize` flag from the `CXXFLAGS` in the hw4 Makefile.
        `-O3` optimization automatically turns on the flag `-ftree-vectorize`, which vectorizes
        your code.
    8. Report the speedup of the vectorized code with respect to the baseline. (Fill in the "Baseline with SIMD" columns in {numref}`vectorization-table`.)
    9. Explain the discrepancy between your measured and ideal
        performance based on the optimization of `Filter_horizontal`.
        (3 lines)
        ````{hint}
        - Look at the size of the multiplications in the assembly code.
        - To read this code, you probably need to understand the
          relation between Q and V registers.  Perhaps useful:
          - <http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dht0002a/ch01s03s02.html>
          - <https://developer.arm.com/docs/den0024/latest/armv8-registers/neon-and-floating-point-registers/scalar-register-sizes>
          - <https://developer.arm.com/docs/den0024/latest/armv8-registers/neon-and-floating-point-registers/vector-register-sizes>
        ````
    10. Show how you can resolve the issue that you identified 
        in the previous problem. (1 line) Include the assembly code of
        `Filter_vertical` after you have resolved the issue.
    11. Report the speedup with respect to the baseline after resolving
        the issue in both `Filter_horizontal` and `Filter_vertical`.
        (Fill in the "Baseline with SIMD Modified" columns in {numref}`vectorization-table`.)

4. **NEON Intrinsics Example**

    Review the {doc}`walk_through` to learn about NEON intrinsics.
    1. Review the code in the `hw4/assignment/neon_example` directory.  Note how the
        Neon version instantiates Neon vector intrinsics to perform
        the operation.  Convince yourself the C version and Neon
        version perform the same computation. (no turn in)
    2. Build and run the code by doing `make example` and `./example`.
    3. Report the speedup for the Neon version compared
        to the C version. (1 line)
    4. Review the assembly code produced for both the C and Neon
        versions.  Based on the assembly code, explain how the Neon
        version is able to achieve the speedup you observed compared to
        the C version.  Include assembly code to support your
        description.  (probably 3--5 lines of description in addition to
        snippets of assembly)

5. **Using NEON Intrinsics**
    
    You will now accelerate the `Scale` function using neon intrinsics. Accelerate this function by using vector loads and stores. If you look at `Filter_vertical` in `Filter.cpp` right after the `#ifdef VECTORIZED`, you will see an implimentation of `Filter_vertical` using neon intrinsics, which may help you become more familiar with using intrinsics. [This](https://developer.arm.com/documentation/den0018/a/NEON-Code-Examples-with-Intrinsics/Swapping-color-channels/How-de-interleave-and-interleave-work) page should give you some idea about how to exploit certain vector loads to help perform Scale. You can use [this](https://developer.arm.com/architectures/instruction-sets/intrinsics/#f:@navigationhierarchiessimdisa=[Neon]) page to help you find documentation for particular intrinsics. You can use [this](https://github.com/gcc-mirror/gcc/blob/master/gcc/config/arm/arm_neon.h) page to help you figure out how to work with different neon datatypes, especially for those that use structs.

    1. Explain your strategy for accelerating `Scale`, and include a screenshot of your function in the report. You will also submit code for this section (see the Deliverables section).

    2. Compile the target `baseline` with `-O3` but autovectorization turned off with `-fno-tree-vectorize`. Run it and report the latency of `Scale`.

    3. Compile the target `baseline` with `-O3` but this time with autovectorization. Run it and report the latency of `Scale`.

    4. Compile the target `neon`. Run it and report the latency of `Scale`.

    5. How much faster was your neon implimentation over the two baseline implimentations?


6. **Reflection**

    Reflect on the cooperation in your team.
    1. Compare your actual time on tasks with your original
        estimates. (table with 1-2 line explanation of major discrepancies)
    2. Reflect on your task decomposition (1.1).
        Were you able to complete the task as you originally planned?
        What aspects of your original task distribution worked well and why?
        Did you refine the plan during the assignment? How and why?  In
        hindsight, how should you have distributed the tasks? (paragraph)
    3. What was the most useful thing you learned from or working with
        your teammate? (2--4 lines)
    4. What do you believe was the most useful thing that you were
        able to  contribute to your team? (1--3 lines)

## Deliverables
In summary, upload the following in their respective links in canvas:
  - a tarball containing the hw4 source code with your modified neon intrinsics code.
    ````{admonition} Quick linux commands for tar files
    :class: dropdown, tip
    ```
    # Compress
    tar -cvzf <file_name.tgz> directory_to_compress/
    # Decompress
    tar -xvzf <file_name.tgz>
    ```
    ````
  - writeup in pdf.
