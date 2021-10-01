# Homework Submission
<!-- ```{include} ../common/aws_caution.md
``` -->
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

1. **Initial CPU implementation and HLS Kernel**
    1. Find the latency of the matrix multiplier (mmult kernel) using `stopwatch` class in
        `hw5/hls/Testbench.cpp`. Use `-O3` and report it in ms. This is our baseline. (1 line)
    1. We will now simulate the matrix multiplier in
        Vitis HLS.
        - First, cd to the HW5 directory and source settings to be able to run vitis_hls.
          `source sourceMe.sh`.
          If you work locally, source `settings64.sh` in vitis installation directory.
        - Start Vitis HLS by `vitis_hls &` in the terminal. You should now see the IDE.
        - Create a new project and add `hw5/hls/MatrixMultiplication.cpp` and `hw5/hls/MatrixMultiplication.h` as source files.
        - Specify `mmult` as top function.
        - Add `hw5/hls/Testbench.cpp` as TestBench files.
        - Select the `xczu3eg-sbva484-1-e` in the device
            selection. Use a ***8ns***
            clock, and select ***Vitis Kernel Flow Target*** for the Flow Target.
            Click Finish.
        - Right-click on ***solution1*** and select
            ***Solution Settings***.
        - In the ***General*** tab, click on ***Add***.
        - Select ***config_compile*** command and set
            ***pipeline_loops*** to ***0***. Vitis HLS automatically does loop pipelining. For the purpose of this homework, we will turn it off,
            since we are going to do it ourselves.
        - ***Run C simulation*** by right-clicking on the project on the ***Explorer*** view, and verify that the test
            passes in the console.  Include the console output in your
            report.
    1. Look at the testbench.  How does the testbench
        verify that the code is correct? (3 lines)
        (We provide you a testbench here.  As you develop your own
            components for the project, you will need to develop your own
            testbenches.  Our testbenches can serve as an example and
            template for you.)
    1. Synthesize the matrix multiplier in Vitis HLS.  
       Analyze the ***Synthesis Report*** by expanding the ***solution1*** tab in the ***Explorer*** view, browsing to ***syn/report*** and opening the `.rpt` file.
        What is the expected latency of the hardware accelerator in ms? (1 line)
    1. How many resources of each type (BlockRAM, DSP unit, flip-flop,
            and LUT) does the implementation consume? (4 lines)
    1. Analyze how the computations are scheduled in time.  You can
            see this information in the ***Schedule Viewer*** of the
            ***Analysis*** perspective.  How many cycles does a
            multiplication take? (1 line)
    1. Make a schematic drawing of the hardware implementation
            consisting of the data path and state machine similar to Figure 2
            of the [Vitis HLS User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_1/ug1399-vitis-hls.pdf#page=9).
            You can ignore the addressing and loop hardware (such as
            `phi_mux` and `icmp`) in your data path.
    1. Explain why the performance of this accelerator is
            worse than the software implementation. (3 lines)
2. **HLS Kernel Optimization: Loop Unrolling**
    1. Go back to the ***Synthesis perspective***, and unroll the
        loop with label `Main_loop_k` 2 times using an `unroll`
        pragma (See [this](https://www.xilinx.com/html_docs/xilinx2020_1/vitis_doc/hlspragmas.html#ariaid-title25) for an example of unroll pragma). Synthesize the code and look again at the schedule. Explain how the schedule for the unrolled loop is able to
        reduce the latency of the entire loop evaluation (all
        iterations) compared to the original (non-unrolled)
        loop.  (3-4 lines).
        ```{hint}
        What characteristic of the original code prevented
        this optimization? and why is the unrolled loop able to exploit
        more parallelism?
        ```
    1. We could also have unrolled the loop manually.
        What would the
            equivalent C code look like?
    1. Inspect the resource usage in the ***Resource Profile***
            view of the ***Analysis*** perspective, as we increase the unroll factor. Of the
            computational resources (`fmul` and `fadd`)
            which one(s) are shared by  multiple operations? (1 line)
    1. Unroll the loop with label `Main_loop_k`
        completely, and
        synthesize the design again.
        You may notice that the estimated clock period in the ***Synthesis Report*** is shown in red. What does this mean? (3 lines)
        ```{note}
        Due to
        variation among Vitis HLS versions, sometimes it works and
        nothing is flagged.  The intent of this question is to
        illustrate things you may encounter and (with the following
        questions) show you how to address them.  If it's not
        flagged in red, just report the estimated clock period.
        ```
        
    1. Change the clock period to 20ns, and
        synthesize it again. What is the expected latency of the new accelerator in ms? (1 line)
    1. How many resources of each type (BlockRAM, DSP unit, flip-flop,
            and LUT) does this implementation consume? (4 lines)
    1. You may have noticed that all floating-point additions are
            scheduled in series.  What does this imply about floating-point
            additions? (2 lines)
    1. We want to multiply two streams of matrices with each other.  We
            can fill the FPGA with copies of one of the accelerators from question
            1d or 2d.  Which
            accelerator would you choose for the highest throughput?

        ```{hint}
         We are just asking for a Resource Bound analysis here.
         How many copies of the each design can you fit in the resources available in Ultra96's logic? What throughput does each design achieve?
        ```
			
3. **HLS Kernel Optimization: Pipelining**
    1. Remove the unroll pragma, and pipeline the `Main_loop_j`
            loop with the minimal initiation
            interval (II) of 1 using the `pipeline` pragma.  Restore the
            clock period to 8ns.  Synthesize the design again.  Report the
            initiation interval that the design achieved. (You may find the timing is
            still not met. It does not matter, we will fix it later.) (1 line)
    1. Draw a schematic for the data path of `Main_loop_j`
            and show how it is connected to the memories.  You can find the
            variables that are mapped onto memories in the ***Resource Profile*** view of the
            ***Analysis*** perspective.
    1. Assuming a continuous flow of input data, how many data words
            does the pipelined loop need per clock cycle from `Buffer_1`?
            (1 line)
    1. Considering what you found in the two previous questions, why does
            the tool not achieve an initiation interval of 1? (3 lines)
    1. We can partition `Buffer_1` and `Buffer_2` to
            achieve a better performance.  Illustrate the best way to partition
            each of the arrays with a picture that shows how the elements of
            these arrays are accessed by one iteration of the pipelined loop.
    1. Partition the buffers according to your description in the
            previous question with the `array_partition` pragma. (See ***Partitioning Arrays to Improve Pipelining*** [Section of the Vitis HLS User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_1/ug1399-vitis-hls.pdf#page=231) 
            for examples of array partitioning pragma). Synthesize the design and report the expected latency in ms. Provide the modified `mmult` code in your report.
    1. How many resources of each type (BlockRAM, DSP unit, flip-flop,
            and LUT) does this implementation consume? (4 lines)
    1. Pipeline the `Init_loop_j` loop also with an II of
        1 and synthesize your design. Before exporting the synthesized design, you can run C/RTL co-simulation to verify
        that the RTL is functionally identical to the C code.
    1. Export your synthesized design by right-clicking on ***solution1*** and then selecting ***Export RTL***. Choose ***Vitis Kernel (.xo)*** as the
        ***Format***. Select output location to be your
        `ese532_code/hw5` directory and select OK.
        Save your design and quit Vitis HLS. Open a terminal and go to your `ese532_code/hw5` directory.
        Run by following the instruction in {ref}`vitis` section.
        Commit the Vitis Analyzer files in your repo. We will use it in the next section.

4. **Vitis Analyzer**
    
    We will now use Vitis Analyzer to analyze the trace of our matrix multiplication on the FPGA.
    <!-- ```{note}
    Note that the only way to view the Vitis Analyzer is using the GUI.
    So collaborate with your partner if you are not able to use the GUI
    or try to [install Vitis toolchain locally](https://github.com/Xilinx/Vitis-In-Depth-Tutorial/blob/master/Getting_Started/Vitis/Part2.md#vitis-flow-101--part-2--installation-guide).
    ``` -->
    1. Run `vitis_analyzer ./xclbin.run_summary` to open Vitis Analyzer. 
    1. Find the latency of the matrix multiplication (mmult kernel) by hovering on the kernel call in the application timeline.
    1. Take a screenshot of the ***Application Timeline***. Try to zoom into the relevant section and have everything in one screenshot. Figure out which lines from `Host.cpp` correspond to the sections in the screenshot and annotate the screenshot. Include the annotated screenshot in your report. If you can't fit everything in one screenshot, take multiple screenshots and annotate. For your reference, following is an example screenshot.
        Keep the trace in Vitis Analyzer open, we will use the numbers from it in the next section.
        ```{figure} images/vitis_analyzer.png
        ---
        height: 300px
        ---
        Example screenshot
        ```

5. **Breakeven and Net Acceleration**

    We can model an accelerator with setup and transfer time as:
    ```{math}
    :label: accelerator-model
    T_{accel} = T_{setup}+T_{transfer}+T_{fpga}
    ```
    Let $T_{seq}$ be the time for an operation (such as the matrix multiply) on the ARM that your found in 1a
    and $T_{fpga}$ be the time for the operation on the FPGA that you found in 4d.
    
    Let $S_{fpga}=\frac{T_{seq}}{T_{fpga}}$ or $T_{fpga}=\frac{T_{seq}}{S_{fpga}}$.
    
    $T_{setup}$ is the time to setup the operation and $T_{transfer}$ is the time to move the data for the operation to the FPGA and back.

    1. What is $S_{fpga}$ for the matrix-multiply operation above?
    2. Find $T_{setup}$ using the trace in 4f.
    3. Find $T_{transfer}$ using the trace in 4f.
    4. Using $S_{fpga}$, $T_{setup}$, and $T_{transfer}$ from the above, how
    large would $T_{seq}$ need to be to get an actual overall speedup?
        ````{hint}
        Solve for $T_{seq}$ in:
        ```{math}
        \frac{T_{seq}}{T_{accel}} > 1
        ```
        ````
    5. How does $T_{seq}$ scale with the matrix dimension $N$? (write an
    equation for $T_{seq}$ as a function of $N$).
    6. How does $T_{fpga}$ scale with the matrix dimension $N$? (write an
    equation for $T_{fpga}$ as a function of $N$) for your fully unrolled
    loop strategy from Problem 3 (`Main_loop_j` pipelined, `Main_loop_k` unrolled).
    7. How does $T_{transfer}$ scale with the matrix dimension $N$? (write an
    equation for $T_{transfer}$ as a function of $N$).
    8. Based on 5e, 5f, 5g, for what value of $N$ would $T_{accel}$ be equal to the value of $T_{seq}$?
    9. Based on the above, for what value of $N$ would $T_{accel}=\frac{T_{seq}}{10}$, i.e. what value of $N$ would show a 10x speedup?
    10. For the value of $N$ found in 5i, what is the value of $S_{fpga}$?
    11. If you perform a large number of accelerator invocations, you only need to perform the setup operations once.
        ```{math}
        :label: accelerator-model-k-invoke
        T_{accel} = T_{setup}+k \cdot (T_{transfer}+T_{fpga})
        ```
        Assuming the number of invocations, $k$, is large (say 1 million), how does
        this change the value of N for 10x speedup (
        $T_{accel}=\frac{T_{seq}}{10}$) ?

6. **Reflection**
    1. Problems 1--3 in this assignment took you through
        a specific optimization sequence for this task.
        Describe the optimization sequence in terms
        of identification and reduction of bottlenecks. (4 lines)
    1. Make an area-time plot for the three designs with
        a curve for DSPs and BlockRAMs.
        ```{hint}
        Expected latency (ms) on X-axis, DSPs and BlockRAMs as separate curves on the Y-axis.
        ```
<!--     1. Go to your AWS Billing page and report the total
        amount of credit used so far (make sure to add up credit used from September). -->

## Deliverables
In summary, upload the following in their respective links in canvas:
  - writeup in pdf.

<!-- ```{include} ../common/aws_caution.md
``` -->
