# Homework Submission

Your writeup should follow [the writeup guidelines](../writeup_guidelines).
Your writeup should include your answers to the following questions:

<style type="text/css">
    ol { list-style-type: decimal; }
    ol ol { list-style-type: lower-alpha; }
    ol ol ol { list-style-type: lower-roman; }
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
    1. Measure the latency and size of the `baseline` target at the
        different optimization levels. Put your measurements in a table like
        {numref}`optimization-table`. You can change
        the optimization level by editing the `CXXFLAGS` in the hw4 Makefile.
    2. Include the assembly code of the innermost loop of `Filter_horizontal`
        at optimization level `-O0` in your report. Use the command:
        ```
        g++ -S -O0 -mcpu=native -fno-tree-vectorize Filter.cpp -o /dev/stdout | c++filt > Filter_O1.s
        ```
        to get the assembly and then look for `Filter_horizontal` in `Filter_O1.s`.
    3. Include the assembly code of inner loop of `Filter_horizontal` at optimization level 
        `-O2` in your report.
    4. Based on the machine code of questions 2b and 2c, explain the most important 
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
    7. Based on the machine code of questions 2c and
        2f, explain the most important difference between the
        `-O2` and `-O3` versions. (1 line)
    8. What are two drawbacks of using a higher optimization level? (5 lines)

3. **Automatic Vectorization**
    
    The easiest way to take advantage of vector instructions is by using
    the automatic vectorization feature of the GCC compiler, which
    automatically generates NEON instructions from loops.
    Automatic vectorization in GCC is sparsely documented in the [GCC documentation](https://gcc.gnu.org/projects/tree-ssa/vectorization.html).
    Although we are not using the ARM compiler, the
    [ARM compiler user guide](http://infocenter.arm.com/help/topic/com.arm.doc.dui0472m/chr1359124204202.html)
    http://hpac.cs.umu.se/teaching/sem-accg-16/slides/08.Schmitz-GGC_Autovec.pdf
    may give some more insight on how to style your code for auto vectorization.
    1. Report the latency of each stage of the baseline application at
        `-O3`. (Start a table that includes each stage and an
        overall application latency; we will continue to expand this
        table throughout this problem.)
    2. Based on your understanding of the C code, which loops in
        the streaming stages of the application have 
        sufficient data parallelism for vectorization?  Motivate your answer.
        (Add a column to the table you started in
        3a for marking suitability; add explanation in 2--5 lines after table.)
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
        available to be used on each cycle. Think about how vectorizing triggers the
        number of computations a NEON unit can do in parallel. 
        ```
    6. What speedup do you expect your application can achieve if the compiler is able to 
        achieve the resource bound identified in 3e? (5 lines)
        ```{hint}
        Remember Amdahl's Law; think about critical path lower
        bounds and resource capacity lower bounds.
        ```
        (Add another column to the table you started in 3a showing expected performance after
        ideal vectorization; separately show Amdahl's Law calculation for overall speedup.)
    7. We will now enable the vectorization in g++. You can enable it by removing
        the `-fno-tree-vectorize` flag from the `CXXFLAGS` in the hw4 Makefile.
        `-O3` optimization automatically turns on the flag `-ftree-vectorize`, which vectorizes
        your code.
    8. Report the speedup of the vectorized code with respect to the baseline. (Add two more  
        columns to the table you started in
        3a showing per stage and overall
        latency (first column) and speedup relative to non-vectorized
        baseline (second column)).
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
        - Use the flag `-fopt-info-loop-optimized` as follows to find out which
            loops got vectorized:
            ```
            g++ -S -O3 -mcpu=native -fopt-info-loop-optimized Filter.cpp -o /dev/stdout | c++filt > Filter_O1.s
            ```
        - Use the flag `-fopt-info-vec-missed` as follows to find out what the compiler
            wasn't able to vectorize:
            ```
            g++ -S -O3 -mcpu=native -fopt-info-vec-missed Filter.cpp -o /dev/stdout | c++filt > Filter_O1.s
            ```
        ````
    10. Show how you can resolve the issue(s) (if you can) that you identified in
        the previous problem. (1 line)
    11. Report the speedup with respect to the baseline after resolving
        the issue in both `Filter_horizontal` and `Filter_vertical`.
        (Add two more columns to the table you started in
        3a showing per stage and overall speedup after resolving.)

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
    
    We will accelerate the `Filter_vertical` function using intrinsics.
    1. The {doc}`walk_through` talked about how you get lanes by packing
        data into vectors. Flowing data through the lanes is key to getting full
        throughput out of the NEON units. As we saw, our `Filter_vertical`
        function works on seven 8-bit data elements at a time.
        How can we deal with a number of data elements that is not divisible
        by the number of vector lanes without losing significant
        performance? (3 lines)
        ````{hint}
        - Is there anything about the structure of the filter 
        (coefficients array) that will help you?
        - Following are two animations. What can you figure out from it?
            ```{figure} images/baseline-filter.gif
            ---
            height: 250px
            name: baseline-filter
            ---
            Filter without vectorization
            ```
            ```{figure} images/vectorized-filter.gif
            ---
            height: 250px
            name: vectorized-filter
            ---
            Filter with vectorization
            ```
        ````
    2. Explain at which granularity and in which order you should
        process the input data with vector instructions to achieve a good
        performance.  Motivate your answer. (7 lines)
        ```{hint}
        - Minimize the number of loads.
        - Look at the animation above again and see if it tells you
            something.
        ```
    3. Using NEON intrinsics, accelerate the `Filter_vertical`
        function. Add the vectorized code under the empty prototype function
        in `Filter.cpp`. Build and run using `make vectorized` and `vectorized`.
        Include the accelerated function in your report.  Make
        sure that you verify your optimized code functions properly.
        ```{hint}
        Our solution uses the intrinsics mentioned in {ref}`coding-neon`,
        however you could use other intrinsics as you see fit. Note that
        some intrinsics might not be available, e.g. `vld1q_u8_x4`.
        ```
    4. Report the latency of `Filter_vertical` and the application
        as a whole. (2 lines)
    5. Compare your performance with the lower bounds. (1 lines)
    6. Compare the performance of manual and automatic vectorization. (1 lines)

6. **Reflection**

    Reflect on the cooperation in your team.
    1. Compare your actual time on tasks with your original
        estimates. (table with 1-2 line explanation of major discrepancies)
    2. Reflect on your task decomposition (1a).
        Were you able to complete the task as you originally planned?
        What aspects of your original task distribution worked well and why?
        Did you refine the plan during the assignment? How and why?  In
        hindsight, how should you have distributed the tasks? (paragraph)
    3. What was the most useful thing you learned from or working with
        your teammate? (2--4 lines)
    4. What do you believe was the most useful thing that you were
        able to  contribute to your team? (1--3 lines)


