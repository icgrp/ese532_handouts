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
      - Average Latency ($T_{measured\_avg}$ ns)
      - \% of total latency
      - Average Latency ($T_{measured\_avg}$ cycles)
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

    2. Report the total latency of your program in nanoseconds using `perf stat` (refer to {ref}`profiling/perf` section in the profiling tutorial) (1 line). Report the percentage of time each function (`Scale`, `Filter_horizontal`, `Filter_vertical`, `Differentiate`, `Compress`) takes in your program.

    3. Report the latencies of 2a and 2b in cycles. Assume that each operation takes one clock cycle at 2.3 GHz.

3. **Analyze**
    1. Which function from {numref}`example-table-1` has the highest latency? (1 line)
    2. Assuming that the innermost loop of the first `for` statement
        of `Filter_horizontal` is unrolled completely, draw a Data Flow Graph (DFG)
        of the body of the loop over `X`. You may ignore index computations (i.e. only include the compute operations (multiply, accumulate and shift) that work on `Input`).
        
        Index computations are operations used to calculate the index
        to be used with a pointer to get an element. For e.g. `4*i` in `x[4*i]` is an index computation.
    3. Assuming that the operations in the DFG execute sequentially,
        count the total number of compute operations. Using this number, estimate the average latency in cycles of `Filter_horizontal`. Assume that each operation takes one clock cycle at 2.3 GHz.

        ```{hint}
        This should be a simple calculation, and it won't necessarily match what you found in {numref}`example-table-1`; we'll be working on that
        in subsequent questions. 
        
        Just like 3b, we want you to focus on parts of the function that execute more times than others (i.e. the multiply, shift and accumulate).
        Hence, you are asked to not estimate the impact of the parts that
        contribute little to runtime. We’ll get a better picture of
        that when we look at the assembly code.
        ```
    4. If you would apply a $2\times$ speedup to one of the stages
        (`Scale`, `Filter_horizontal`, `Filter_vertical`, `Differentiate`, `Compress`)
        which one would you choose to obtain the best overall performance? (1 line)
    5. Use Amdahl's Law to determine the highest overall application
        speedup that one could achieve assuming you accelerate the one stage that
        you identified above.  You don't have to restrict yourself to this platform. (1 line)
    6. Assuming a platform that has unlimited resources and you are free 
        to exploit associativity for
        mathematical operations, draw the DFG with the lowest critical path
        delay for the same unrolled loop body (Part 3b) as before.
    7. Determine the critical path length (i.e. assume instructions can
        execute in the same cycle) of the same unrolled loop (Part 3f)
        in terms of compute operations.
    8. Assuming a platform that has 4 multipliers, 2 adders, and a shifter, report the resource capacity lower
        bound for the same loop body (Part 3b) as before. (4 lines)
4. **Refine**
    
    As you hopefully noticed, our model of using a DFG and counting
    compute operations did not estimate `Filter_horizontal` very accurately
    in Part 3c.  Let's see whether we can improve it.

    First, we'll build a table similar to the following, which records the total number of cycles
    for each instruction:
    ```{list-table} Example Table
    :header-rows: 1
    :name: example-table-2

    * - Assembly Instructions
      - Annotation
      - Number of function calls ($N$)
      - Number of cycles per call ($T$)
      - Number of instructions issued ($N_{issue}$)
      - Total number of cycles ($\frac{N}{N_{issue}}$ $\times$ $T$)
    * - `add	x0, x0, #0xc68`
      - addition(s) for array indexing
      - 7
      - 1
      - 3
      - 7
    * - ...
      - ...
      - ...
      - ...
      - ...
      - ...
    ```
    We will then group these instructions into three bins---*fast loads*, *slow loads* and *non-memory*,
    and develop the following model for the runtime of this filter computation:
    ```{math}
    :label: perf-model
    \begin{eqnarray}
    T_{filter\_measured\_avg} = \frac{N_{non\_memory}}{N_{issue}} \times T_{cycle\_non\_memory}
                + \frac{N_{fast\_loads}}{N_{issue}} \times  T_{cycle\_fast\_loads} \\
                + N_{slow\_loads} \times T_{cycle\_slow\_loads} \\
    \end{eqnarray}
    ```
    
    The real model is still more complicated than this, but this is a
    first-order model that can start helping us reason about the performance of
    the computation including memory access.

    1. Make a table like {numref}`example-table-2` and add all the instructions
    in the loop body (not the instructions
    that setup the loop, but the instruction that are executed on each trip
    through the loop) of the innermost loop. (Do not assume that it is unrolled this time.)
    You can see the instructions by:
        - Running your code with: `gdb ./App`.
        - Setting a breakpoint at the `Filter_horizontal` function: `(gdb) b Filter_horizontal`.
        - Stepping over using `n` until you reach the innermost loop: `(gdb) n`
        - Using `disassemble` command to view the assembly: `(gdb) disassemble`.
    
        Which of these instructions are the compute operations you identified in 3c?
    2. Annotate each instruction with one of the descriptions below as appropriate, and
        add to {numref}`example-table-2`.  You will not be able to annotate some instructions.
        Don't worry, that is part of what the question is setting up.
        1. multiplication for array indexing
        2. addition(s) for array indexing
        3. multiplication of coefficient with input
        4. addition to Sum
        5. reads from arrays
        6. increment of loop variable
        7. comparison of loop variable to loop limit
        8. branch to top of loop

        You can use your C code to infer the annotations for the instructions. If you would like
        to understand the assembly, refer to the
        {download}`quick reference guide <pdfs/QRC0001_UAL.pdf>`.
    3. After identifying the called-out instructions above, there
        are additional assembly instructions.  What type of instructions are
        these?  What do these assembly instructions do? Provide a 1 line (or less) description for each type of instruction identified, and use them to annotate the additional instructions in your table.
    4. Fill in the rest of the table by determining the number of function
        calls
        for each instruction. Assume that one instruction completes per
        cycle. Also assume that 3 instructions are issued at the same time. Using your table, estimate the latency ($T_{filter\_analytical}$) of the function
        in cycles. (1 line)
        ````{note}
        The model here is:
        
        ```{math}
        T_{filter\_analytical} = \frac{N_{instr}}{N_{issue}} \times T_{cycle}
        ```

        where $T_{cycle} = 1$ and $N_{issue} = 3$.
        ````
    5. Now assume that only the non-memory instructions identified in 
        {numref}`example-table-2` complete in one cycle, and also assume that the multiple issue of instructions ($N_{issue} = 3$) only applies to non-memory instructions,
        estimate the average latency ($T_{cycle\_memory}$) in cycles of the memory operations. (3 lines)
        ```{hint}
        Use the measured latency of `Filter_horizontal` from
        {numref}`example-table-1` and solve for $T_{cycle\_memory}$.

        ```
        ````{note}
        Refining from 4d, the model here is:
        ```{math}
        N_{instr} = N_{non\_memory} + N_{memory}
        ```
        ```{math}
        T_{filter\_measured\_avg} = \frac{N_{non\_memory}}{N_{issue}}  \times T_{cycle} + N_{memory} \times T_{cycle\_memory}
        ```
        where $T_{cycle} = 1$ and $N_{issue} = 3$.
        ````
    6. For the identified memory operations, how many of these loads and store cycles are to
        memory locations ***not*** loaded  during this invocation
        of `Filter_horizontal`)?

        ```{hint}
        You are finding out $N_{slow\_loads}$ of equation {eq}`perf-model`
        ```
        
        Add a column to your instruction table and identify the fraction of time
        the specified instruction is to a new memory location not previously
        encountered during a call to the function.
    7. Assuming memory locations that have already been loaded
        during a call to this function  (Part 4f)
        also take a single cycle and multiple issue of instructions ($N_{issue} = 3$) also applies to them, what is the average number of
        cycles ($T_{cycle\_slow\_loads}$) for the remaining loads?
        
        This will require you to use the fraction you added to the table in the
        previous question. (3 lines)

        ````{note}
        Refining from 4e, this gives us the model for the runtime of this filter computation:
        ```{math}
        N_{memory} = N_{fast\_loads} + N_{slow\_loads}
        ```
        ```{math}
        T_{filter\_measured\_avg} = \frac{N_{non\_memory}}{N_{issue}} \times T_{cycle}
                    + \frac{N_{fast\_loads}}{N_{issue}} \times  T_{cycle} \\
                    + N_{slow\_loads} \times T_{cycle\_slow\_loads} \\
        ```
        where $T_{cycle} = 1$ and $N_{issue} = 3$.
        ````

## Deliverables
In summary, upload the following in their respective links in canvas:
  - a tarball containing your instrumented code and Makefile with targets for
    compilation and running `perf`.
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
