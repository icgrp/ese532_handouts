# Homework Submission

Your writeup should follow [the writeup guidelines](../writeup_guidelines).
Your writeup should include your answers to the following questions:

<style type="text/css">
    ol { list-style-type: decimal; }
    ol ol { list-style-type: lower-alpha; }
    ol ol ol { list-style-type: lower-roman; }
</style>

1. **Baseline**
    
    Get the source code and run the `baseline` project as shown in
    {doc}`walk_through`.
    1. Determine the throughput of `baseline` in pictures per
        second.  This is your baseline. We use `-O2` for the baseline, so you
        should keep using -O2 for the rest of the homework. Ignore overhead 
        such as loading and storing pictures for this and the following 
        questions. (1 line)

2. **Coarse-grain parallelism**
    
    We will parallelize the application by processing half of each
    picture on core 0 and the other half on core 1, a form of
    coarse-grain, data-level parallelism. 
    The initial implementation can be found in `hw3/assignment/coarse_grain`.
    We have parallelized `Scale` already for you.
    1. Can we parallelize all streaming functions in our application, i.e.
        `Filter_horizontal`, `Filter_vertical`, `Differentiate`,
        and `Compress` in the same way as `Scale`?  Motivate your
        answer.  Assume that we synchronize our cores between each producer-consumer pair.
        (3 lines)
    2. What speedup do you expect from parallelizing the functions
        that you considered parallelizable in the previous question? 
        [Include an equation for the expected parallel runtime and
        show the equation you use for computing the speedup as well as your
        final, numeric result.  Report both per function speedup and
        overall application speedup.] (5--7 lines)
    3. Complete the implementation by parallelizing the functions
        that you considered parallelizable in the previous question.  Provide
        the relevant sections of code in your report.
    4. Measure the throughput of your parallel implementation.
    5. Validate your results.  Make sure that your parallel
        version produces the same answers as the original serial
        version.  Explain how you validated your results; report any
        discrepancies in your final implementation.  (3--5 lines)
    6. Compare your measurement with your ideal, expected speedup. (1 line)
    7. If your speedup is different from ideal, expected, what
        effects are likely to be responsible for the difference? (1-3 lines)

3. **Pipelining**
    
    As an alternative to coarse-grain, data-level parallelism, we will
    investigate a pipelined implementation in this question.  The initial
    implementation can be found in `hw3/assignment/pipeline_2_cores`.
    The provided stream has only $100$ frames, but
    assume in your performance computations that you are dealing with a
    stream of infinite length.
    1. Report the throughput of the initial pipelined 
        implementation on 2 cores in
        pictures per second. (1 lines)
    2. What is the best performance that one could theoretically
        achieve with a pipelined mapping of the streaming application on 2 cores over the single x86 core solution?
        (1 line)
        ```{hint}
        Where is the bottleneck? How does pipelining help in
        hiding the bottleneck?
        ```
    3. Describe the mapping that achieves the best performance. (3 lines)
    4. Reviewing the provided code, explain how it is able to
        deal with filling and draining the pipeline of operators?
        That is, when the application starts, there is only data for
        the first stage in the pipeline (`Scale`) and no data for the
        later stages.  After the input data has been consumed by
        the `Scale` stage, the later stages will still have data to
        process.  How does the code assure the program runs correctly
        to completion on all data?  (4--6 lines)
    5. Review the provided code.  Explain how you can adjust the
        `PIPELINE_PAR` parameter (in `Filter.cpp`) to maximize throughput. (2--3 lines)
    6. Adapt the implementation by changing the parameter
        `PIPELINE_PAR` to optimize the pipeline task or
        implement your own mapping to optimize the 
        pipeline tasks. Include the sections of the code that you modified
        in your report.
    7. Validate your results.  Report on how you validated
        and any discrepancies. (1--3 lines)
    8. Report the throughput of your new application in pictures per
            second.  (1--2 lines)
    9. Let's investigate the performance if we incorporate the optimized
        pipeline in a video broadcast server.  The input data is read from 
        an interface with $300$ MB/s throughput.  $75\%$ of traffic is
        video traffic that is compressed using our pipeline (running on
        2 processors). Assume the 2 cores can pipeline the process perfectly. The remaining
        $25\%$ is other traffic that we protect with an error correction code
        (ECC) running on a dedicated hardware unit that adds $10\%$
        overhead in size.  The hardware ECC unit processes $150$ MB/s.
        The output of the ECC unit and compression pipeline are 
        output to a single $2$-Gigabit/s Ethernet port.
        1. Draw a streaming dataflow diagram for the network server.
            Indicate throughput and data transfer ratios where applicable.
        2. What is the maximum throughput that the server can achieve? (10 lines)
        3. Where is the bottleneck? (1 line)
        4. How much smaller do we have to make the kernel (`FILTER_LENGTH`) of
            `Filter` to move the bottleneck? (7 lines)

4. **CDC Parallel**
    
    Building on techniques and observations from previous parts,
    create a data-parallel implementation of your CDC function from homework 2 that uses four x86 cores to achieve
    additional speedup. The starter code can be found in `hw3/assignment/cdc_parallel`.
    1. What is the best performance that one could theoretically
        achieve with a data-parallel mapping of CDC on 4 cores over the single x86 solution?
        (1 line)
    2. Describe the data-parallel mapping that achieves the best performance.
        Try to achieve the best speedup over the single x86 core solution.
    3. Implement your design and include your code  in your report.
        ```{hint}
        - Use the techniques showed in the walkthrough!
        - You can divide the input file equally for each thread to work on,
            however, make sure that hash calculation for the window of characters between two threads is accounted
            for, in other words, think about the indices you'll pass to your threads.
        ```
    4. Report speedup obtained and relate it to your solution. (3--5 lines)
    5. Validate your design and report on any discrepancies.

## Deliverables
In summary, upload the following in their respective links in canvas:
  - a tarball containing the 4 projects with your modified code.
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

