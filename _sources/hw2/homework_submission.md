# Homework Submission

Your writeup should follow [the writeup guidelines](../writeup_guidelines). Your writeup should include the following:

<style type="text/css">
    ol { list-style-type: decimal; }
    ol ol { list-style-type: lower-alpha; }
    ol ol ol { list-style-type: lower-roman; }
</style>

1. **Identify**
    1. For the application you downloaded in hw2/assignment, describe the
        operation performed on the input data by each 
        function and why you might want to perform the operation (3
        lines for each of Scale, Filter, Differentiate, Compress).
2. **Measure**
    
    Build a table similar to the following, and populate it when answering the following questions:
    ```{list-table} Example Profile
    :header-rows: 1
    :name: example-table-1

    * - Functions
      - Average Latency $T_{measured\_avg}$ (ns)
      - \% of Total Latency
      - Average Latency $T_{measured\_avg}$ (cycles)
    * - Scale
      -  
      -  
      -  
    * - Filter_horizontal
      -  
      -  
      -  
    * - Filter_vertical
      -  
      -  
      -  
    * - Differentiate
      -  
      -  
      -  
    * - Compress
      -  
      -  
      -  
    ```
    1. Report the average latencies (i.e. time to execute one call of the function) of `Scale`, `Filter_horizontal`, `Filter_vertical`, `Differentiate`, `Compress` in nanoseconds.  For this, you will
        need to instrument the code (refer to {ref}`profiling/instrumentation`
        in the profiling tutorial).
        
        Write a Makefile (refer to the profiling tutorial) and use `-O2`
        optimization (we will explore optimization levels more in HW4).

    2. Report the percentage of time each function (`Scale`, `Filter_horizontal`, `Filter_vertical`, `Differentiate`, `Compress`) takes in your program. For this, you will
        need to use `gprof` (refer to {ref}`profiling/gprof`
        in the profiling tutorial).

    3. Calculate and report the latencies of (Part 2.1) in cycles and add it to {numref}`example-table-1`. Use your computer's CPU clock frequency to calculate this. If running on biglab you can find this by running the `lscpu` command.

3. **Analyze**

    In the rest of this class, you will be working with an Ultra96 development board which has an ARM processor. Since you don't have access to one in this homework, we have profiled the application on it for you, and have provided you with the results:
    ```{list-table} Ultra96 Profiling Data
    :header-rows: 1
    :name: ultra96_profile

    * - Functions
      - Average Latency (ns)
    * - Scale
      -  8.42684e+08
    * - Filter_horizontal
      -  5.24131e+09
    * - Filter_vertical
      -  5.29961e+09
    * - Differentiate
      -  1.63245e+09
    * - Compress
      -  5.36313e+09
    ```
    1. Assuming the Ultra96 runs at a clock frequency of 1.2GHz, add a column to {numref}`ultra96_profile` with the average latency of each function in cycles.
    2. Which function from {numref}`ultra96_profile` has the highest latency? (1 line)
    3. Assume that `LOOP3`
        of `Filter_horizontal` is unrolled completely into the body of `LOOP2`. Draw a Data Flow Graph (DFG)
        of the operations that are performed in the body of `LOOP2`. You may ignore index computations (i.e. only include the compute operations (multiply, accumulate and shift) that work on `Input`). Index computations are operations used to calculate the index to be used with a pointer to get an element. For e.g. `4*i` in `foo[4*i]` is an index computation. When drawing the DFG, only consider the *body* of `LOOP2` (not any of the looping).
    4. Assuming that the operations in the DFG execute sequentially,
        count the *total* number of compute operations involved in the execution of `Filter_horizontal` (consider how many times the compute operations in the DFG will run, when taking the looping of loops 1 and 2 into account) (1 line). Assuming that each operation takes one clock, estimate the average latency of `Filter_horizontal` in cycles (1 line).

        ```{hint}
        This should be a simple calculation, and it won't necessarily match what you found in (Part 3.1); we'll be working on that
        in subsequent questions. 
        
        Just like (Part 3.3), we want you to focus on parts of the function that execute more times than others (i.e. the multiply, shift and accumulate).
        Hence, you are asked to not estimate the impact of the parts that
        contribute little to runtime. We’ll get a better picture of
        that when we look at the assembly code.
        ```
    5. If you would apply a $2\times$ speedup to one of the stages
        (`Scale`, `Filter_horizontal`, `Filter_vertical`, `Differentiate`, `Compress`)
        which one would you choose to obtain the best overall performance? (1 line)
    6. Use Amdahl's Law to determine the highest overall application
        speedup that one could possibly achieve assuming you accelerate the one stage that
        you identified above.  You don't have to restrict yourself to this platform. (1 line)
    7. Assuming a platform that has unlimited resources, and you are free 
        to exploit associativity for
        mathematical operations, draw a new DFG with the lowest critical path
        delay for the unrolled body of `LOOP3` with the same considerations as in (Part 3.3). To draw the DFG you may use as many or as few 2 input adders/subtractors, 2 input multipliers, or shifters as you want.
    8. Determine the critical path length of the unrolled `LOOP3` with the new DFG you created in (Part 3.7)
        in terms of compute operations. Assume that any number of instructions can execute in the same cycle.
    9. Assuming a platform that has 4 multipliers, 2 adders, and a shifter, report the resource capacity lower
        bound for `LOOP3`, again only considering the operations outlined in (Part 3.3). (4 lines)
4. **Refine**
    
    As you hopefully noticed, our model of using a DFG and counting
    compute operations in (Part 3.4) did not estimate `Filter_horizontal` very accurately.  We will now construct a better model by examining the assembly code of `Filter_horizontal`. As mentioned previously, in the rest of this class, you will be working with an Ultra96 development board which has an ARM processor. Therefore instead of asking you to analyze x86 assembly compiled on your own PC, we are providing you with an assembly program that was compiled on the Ultra96: `hw2/assignment/Filter_O2.s`. The code pertaining to `Filter_horizontal` is on lines 14-50 of `Filter_O2.s`. To get you started analyzing, we have annotated the instructions between labels `.L2` and `.L3`. These are setup instructions, and are outside of any loops. 
    ```{hint}
    Here are some links which can help you get up to speed with ARM Assembly.
    - [Calling Convention](https://en.wikipedia.org/wiki/Calling_convention#ARM_(A64))
    - [Registers](https://developer.arm.com/documentation/102374/0100/Registers-in-AArch64---general-purpose-registers)
    - [Loads](https://developer.arm.com/documentation/den0024/a/The-A64-instruction-set/Memory-access-instructions/Load-instruction-format)
    - [Addressing Modes](https://developer.arm.com/documentation/den0024/a/The-A64-instruction-set/Memory-access-instructions/Specifying-the-address-for-a-Load-or-Store-instruction)
    ```

    To develop our new model, we will begin by building a table similar to the following, which records the total number of executions for each instruction in the program:
    ```{list-table} Example Table
    :header-rows: 1
    :name: example-table-2

    * - Assembly Instructions
      - Annotation
      - Number of executions: $N$
    * - `add w0, w0, 1`
      - addition(s) for array indexing
      - 100
    * - ...
      - ...
      - ...
    ```
    We will then group these executions into three sets: executions of non-memory instructions, fast executions of memory instructions, and slow executions of memory instructions. We will then use these to develop the following model for the runtime of `Filter_horizontal`:
    ```{math}
    :label: perf-model
    \begin{align}
    T_{filter\_h\_measured} & = \frac{N_{non\_mem}}{N_{par}} \times T_{cycle\_non\_mem} \\
                                 & + N_{fast\_mem} \times  T_{cycle\_fast\_mem} \\
                                 & + N_{slow\_mem} \times T_{cycle\_slow\_mem} \\
    \end{align}
    ```
    
    The real model is still more complicated than this, but this is a
    first-order model that can help us start reasoning about the performance of
    the computation including memory access.
    ```{hint}
    Here are some links which can help you get up to speed with ARM Assembly.
    - [Calling Convention](https://en.wikipedia.org/wiki/Calling_convention#ARM_(A64))
    - [Registers](https://developer.arm.com/documentation/102374/0100/Registers-in-AArch64---general-purpose-registers)
    - [Loads](https://developer.arm.com/documentation/den0024/a/The-A64-instruction-set/Memory-access-instructions/Load-instruction-format)
    - [Addressing Modes](https://developer.arm.com/documentation/den0024/a/The-A64-instruction-set/Memory-access-instructions/Specifying-the-address-for-a-Load-or-Store-instruction)
    ```
    ```{hint}
        Note, assembly identifiers that start with a period, such as ".p2align" are assembly directives and not instructions.
    ```

    1. Record the runtime of `Filter_horizontal` in cycles (1 line). You should have calculated this in (Part 3.1). This value will be referred to as ($T_{filter\_h\_measured}$).

    2. Make a table like {numref}`example-table-2` and add all the instructions that are *inside* the loops (that is, the instructions on lines 30-52 of `Filter_O2.s`). Don't add the setup instructions that we annotated for you, to the table, however be sure to examine them as you will need to understand them to comprehend the rest of the code. Note that because the compiler optimized the code, the looping in the assembly works differently than how it reads in the C program. We will revisit optimization in HW4.
    
    3. Annotate each instruction with an appropriate description such as one of those listed below, and
        add to {numref}`example-table-2`. This is not necessarily an exhaustive list, and some instructions may require a combination of some of the descriptions listed. 
        1. addition(s) for array indexing
        2. multiplication of coefficient with input
        3. addition to Sum
        4. shift to Sum
        5. reads from arrays
        6. writes to array
        7. increment of a loop variable
        8. comparison of a loop variable to a loop limit
        9. branch to top of a loop
        
        You can use your C code to infer the annotations for the instructions. Which of the instructions in your table are the compute operations you identified in (Part 3.3) (2 lines)?
    4.  Calculate how many times each of the instructions are executed, and fill in the table. Looking at the loops in both C and assembly can help with this.

    5. Calculate the total number of instruction executions ($N_{instr}$) (1 line). Assuming that each instruction takes 1 cycle to execute, and that 2 instructions can be executed in parellel ($N_{par}$), calculate the runtime of the function ($T_{filter\_h\_analytical}$) in cycles (1 line).
        ````{note}
        The model here is:
        
        ```{math}
        T_{filter\_h\_analytical} = \frac{N_{instr}}{N_{par}} \times T_{cycle}
        ```

        where $T_{cycle} = 1$ and $N_{par} = 2$.
        ````
        Notice that our simple model doesn't work very well, and so $T_{filter\_h\_analytical}$ is very different from $T_{filter\_h\_measured}$.
    6. Calculate the total number of executions of memory instructions in {numref}`example-table-2` ($N_{mem}$) (1 line). Next, calculate the total number of executions of non-memory instructions ($N_{non\_mem}$) (1 line). Now assume that each non-memory instruction takes 1 cycle to execute, and that 2 of these can be executed in parellel. Also assume that each memory instruction takes $T_{cycle\_mem}$ cycles to execute, and that only 1 can be executed at a time. Write an expression for the runtime of the function in cycles, and set it equal to $T_{filter\_h\_measured}$ (1 line). Now solve for $T_{cycle\_mem}$ (1 line).
        ````{note}
        Refining from (Part 4.4), the model here is:
        ```{math}
        N_{instr} = N_{non\_mem} + N_{mem}
        ```
        ```{math}
        \begin{align}
        T_{filter\_h\_measured} & = \frac{N_{non\_mem}}{N_{par}}  \times T_{cycle\_non\_mem} \\
                                     & + N_{mem} \times T_{cycle\_mem}
        \end{align}
        ```
        where $T_{cycle\_non\_mem} = 1$ and $N_{par} = 2$.
        ````
        Our model now produces the correct runtime, and gives us a rough idea of how much time is spent in memory vs compute, but we can do better.
    7. Consider the memory instructions in {numref}`example-table-2`. For each instruction, record *approximately* what fraction of its executions will be slow (1 or 2 lines per memory instruction).
        ```{hint}
        Think about which loads will be from new memory locations, vs. locations which will have already been read from earlier during the function's execution, and thus will be fast due to caching. Assume that writes will be slow.
        ```
        With these fractions, calculate the total number of slow executions of memory instructions ($N_{slow\_mem}$), and the total number of fast executions of memory instructions ($N_{fast\_mem}$) (2 lines).
    8. Assume that each non-memory instruction takes 1 cycle to execute, and that 2 of these can be executed in parellel. Also assume that a fast execution of a memory instruction takes 1 cycle and that only 1 can happen at a time. Also assume that a slow execution of a memory instruction takes $T_{cycle\_slow\_mem}$ cycles to execute, and that only 1 can happen at a time. Write an expression for the runtime of the function, and set it equal to $T_{filter\_h\_measured}$ (1 line). Now solve for $T_{cycle\_slow\_mem}$ (1 line). 
        ````{note}
        Refining from (Part 4.5), this gives us the model for the runtime of this filter computation:
        ```{math}
        N_{mem} = N_{fast\_mem} + N_{slow\_mem}
        ```
        ```{math}
        \begin{align}
        T_{filter\_h\_measured} & = \frac{N_{non\_mem}}{N_{par}} \times T_{cycle\_non\_mem} \\
                                  & + N_{fast\_mem} \times  T_{cycle\_fast\_mem} \\
                                     & + N_{slow\_mem} \times T_{cycle\_slow\_mem} \\
        \end{align}
        ```
        where $T_{cycle\_fast\_mem} = T_{cycle\_non\_mem} = 1$ and $N_{par} = 2$.
        ````
        Now our model gives us the correct runtime of the function, and gives us more insight into the benefits of caching, and the consequences of a cache miss.
4. **Coding**
    ```{note}
        This section may seem unrelated, however hashing and CDC are used in the final project, and we are introducing it here to prepare you.
    ```
    1. Implement the `hash_func` and `cdc` functions from the following Python code in C/C++. You can find the starter code at `hw2/cdc/cdc.cpp`. You are free to use C/C++ standard library data structures
    as you see fit. 
        ```Python
        win_size = 16
        prime = 3
        modulus = 256
        target = 0


        def hash_func(input, pos):
            hash = 0
            for i in range(0, win_size):
                hash += ord(input[pos+win_size-1-i])*(pow(prime, i+1))
            return hash


        def cdc(buff, buff_size):
            for i in range(win_size, buff_size-win_size):
                if((hash_func(buff, i) % modulus)) == target:
                    print(i)


        def test_cdc(filename):
            with open(filename) as f:
                buff = f.read()
                cdc(buff, len(buff))


        test_cdc("prince.txt")

        ```
        Verify that your program outputs the following:
        ```{admonition} Output
        299
        366
        367
        838
        1001
        1263
        2141
        2283
        2660
        2708
        2748
        2820
        3143
        3210
        3211
        3682
        3845
        4107
        4985
        5127
        5504
        5552
        5592
        5664
        5987
        6054
        6055
        6526
        6689
        6951
        7829
        7971
        8348
        8396
        8436
        8508
        8831
        8898
        8899
        9370
        9533
        9795
        10673
        10815
        11192
        11240
        11280
        11352
        11675
        11742
        11743
        12214
        12377
        12639
        13517
        13659
        14036
        14084
        14124
        14196
        ```
        ```{tip}
        - To verify, you can first create a text file with the output, e.g. `golden.txt`
        - You can then write the output of your program to another text file by
        redirecting the output in the command line, e.g. `./cdc > out.txt`
        - You can then use `diff` which will show differences in values if any, e.g. `diff out.txt golden.txt`
        ```
    2. It is more efficient to not recompute the whole hash at every window.
    Convince yourself that the next hash computation can be expressed as:
        ```Python
        hash_func(input, pos+1) = (hash_func(input, pos)*prime - 
                       ord(input[pos])*pow(prime, win_size+1) +
                       ord(input[pos+win_size])*prime)
        ```
        Develop a second, revised `cdc` function that uses this observation to reduce the work. Verify that your program is producing the same outputs with the changes.
    3. Time the two `cdc` implementations and compare.
        ```{tip}
        - Read the following resources to gain more context about the code:
          <br> Content-Defined Chunking (Rabin Fingerprint)
          - https://moinakg.wordpress.com/tag/rabin-fingerprint/
          - https://en.wikipedia.org/wiki/Rabin_fingerprint
        ```

## Deliverables
In summary, upload the following in their respective links in canvas:
  - a tarball containing your instrumented code and Makefile with targets for
    compilation and running `gprof`.
    ````{admonition} Quick linux commands for tar files
    :class: dropdown, tip
    ```
    # Compress
    tar -cvzf <file_name.tgz> directory_to_compress/
    # Decompress
    tar -xvzf <file_name.tgz>
    ```
    ````
  - a tarball containing your two `cdc` implementations code and Makefile to compile it.
  - writeup in pdf.
