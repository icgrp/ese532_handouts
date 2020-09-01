# Homework Submission

Your writeup should follow [the writeup guidelines](../writeup_guidelines). Your writeup should include the following:

<style type="text/css">
    ol { list-style-type: decimal; }
    ol ol { list-style-type: lower-alpha; }
    ol ol ol { list-style-type: lower-roman; }
</style>

1. **Identify**
    1. Describe the operation performed on the input data by each
        function and why you might want to perform the operation (3
        lines for each of Scale, Filter, Differentiate, Compress).
2. **Measure**
    1. Report the latency of the application in microseconds.  For this, you will
        need to instrument the code (refer to {ref}`profiling/instrumentation`
        in the profiling tutorial). (1 line)
        
        Write a Makefile (refer to the profiling tutorial) and make sure to compile with `-g -pg` options and no optimizations.
        Also note that we are ***not*** asking you to instrument individual functions
        here, but just the whole application.

    2. Create an execution profile of the application using `perf`
        profiling tool (refer to {ref}`profiling/perf` section in the profiling tutorial).
        Add a screenshot of the `perf` report. Make sure to show the percentages for
        `Scale`, `Filter_horizontal`, `Filter_vertical`, `Differentiate`, `Compress`.

        Refer to the Makefile in the profiling tutorial and add a
        target called `perf_report` in your Makefile. If you don't see a percentage for a function, try re-running `perf`.

    3. Using the data from Parts 2a and 2b estimate the latency of
       `Filter_horizontal`. (1 line)
        
        While you can get the latencies by only instrumenting the code
        or by only using perf, we are mixing the two approaches so that you can get some
        experience in both.

3. **Analyze**
    1. Which function has the highest latency? (1 line)
    2. Assuming that the innermost loop of the first `for` statement
        of `Filter_horizontal` is unrolled completely, draw a Data Flow Graph (DFG)
        of the body of the loop over `X`. You may ignore index computations.
        
        Index computations are operations used to calculate the index
        to be used with a pointer to get an element. For e.g. `4*i` in `x[4*i]` is an index computation.
        
    3. Determine the critical path length of the same unrolled loop (Part 3b)
        in terms of ***compute*** operations. (4 lines)
    4. Estimate the ***total number of cycles*** taken by `Filter_horizontal` using 3c,
        and then combine with the clock frequency to estimate the latency of `Filter_horizontal` in microseconds.
        
        Assume that each operation takes one clock cycle at 2.3 GHz and none
        execute in the same cycle (so critical path from previous
        question not relevant to this one). (4 lines)

        ```{hint}
        This should be a simple calculation, and it won't necessarily match
        what you found in Part 2c; we'll be working on that
        in subsequent questions. 
        
        We want you to focus on parts of the function that execute more times than others.
        Hence, you are asked to not estimate the impact of the parts that
        contribute little to runtime, i.e. the index computations.
        ```
    5. If you would apply a $2\times$ speedup to one of the stages
        (`Scale`, `Filter_horizontal`, `Filter_vertical`, `Differentiate`, `Compress`)
        which one would you choose to obtain the best overall performance? (1 line)
    6. Use Amdahl's Law to determine the highest overall application
        speedup that one could achieve assuming you accelerate the one stage that
        you identified above.  You don't have to restrict yourself to this platform. (1 line)
    7. Assuming a platform that has unlimited resources and you are free to exploit associativity for
        mathematical operations, draw the DFG with the lowest critical path delay for the same loop
        body (Part 3b) as before.
    8. Assuming a platform that has 4 multipliers, 2 adders, and a shifter, report the resource capacity lower
        bound for the same loop body (Part 3b) as before. (4 lines)
4. **Refine**
    
    As you hopefully noticed, our model did not estimate `Filter_horizontal` very accurately
    in Part 3d.  Let's see whether we can improve it.

    1. Report all the instructions in the loop body (not the instructions
    that setup the loop, but the instruction that are executed on each trip
    through the loop) of the innermost loop. (Do not assume that it is unrolled this time.)
    You can see the instructions by running with `gcc -S`.
    2. Estimate the latency of the function based on the number of instructions
        in the loop body, assuming one instruction completes per
        cycle. (1 line)
    3. Relate instructions in the assembly code (Q 4a) to operations in the C code.
        1. multiplication for array indexing
        2. addition(s) for array indexing
        3. multiplication of coefficient with input
        4. addition to Sum
        5. reads from arrays
        6. increment of loop variable
        7. comparison of loop variable to loop limit
        8. branch to top of loop
        
        Make a table of all instructions and annotate each instruction with one of
        the above as appropriate.  Not all instructions will be classified.  That
        is part of what the question is setting up.
    4. After identifying the called out instructions above, there
        are additional assembly instructions.  What type of instructions are
        these?  What do these assembly instructions do? (1 line per type of instruction -- add to table)
    5. Assuming the non-memory instructions identified in the previous
        questions (Part 4c and 4d) complete in one cycle,
        estimate the average latency in cycles of the original load and store
        operations identified in  together? (3 lines)
    6. How many of these loads and stores are to
        memory locations ***not*** loaded  during this invocation
        of `Filter_horizontal`)?
        
        Add a column to your instruction table and identify the fraction of time
        the specified instruction is to a new memory location not previously
        encountered during a call to the function.
    7. Assuming memory locations that have already been loaded
        during a call to this function  (Part 4f)
        also take  a single cycle, what is the average number of
        cycles for the remaining loads?
        
        This will require you to use the fraction you added to the table in the
        previous question. (3 lines)


    This gives us a model for the runtime of this filter computation:
    \begin{equation}
    T_{filter} = N_{instr} \times T_{cycle} + N_{fast-loads} \times  T_{cycle} + N_{slow-loads} \times T_{slow-load}
    \end{equation}
    $N_{slow-load}$ is what you estimated in 4f and combining the cycle time
    with the cycle estimates from 4g, you can estimate $T_{slow-load}$.
    The real model is still more complicated than this, but this is a
    first-order model that can start helping us reason about the performance of
    the computation including memory access.

## Deliverables
In summary, upload the following in their respective links in canvas:
  - a tarball containing your instrumented code and Makefile with targets for
    compilation and running `perf`.
  - writeup in pdf.