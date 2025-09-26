# Homework Submission

Your writeup should follow [the writeup guidelines](../writeup_guidelines).
Your writeup should include your answers to the questions below. Even if a certain
question(like 1-(c) or 1-(f)) is just a "step", please include it in your report and leave the bullet blank
for the sake of easy grading.

<style type="text/css">
    ol { list-style-type: decimal; }
    ol ol { list-style-type: lower-alpha; }
    ol ol ol { list-style-type: lower-roman; }
    table { width: 100%; }
    td {height:50px;text-align: center;}
    tr:nth-child(even) {background-color: #f2f2f2;}
</style>

<!-- 1. **Setup**

    ---
    - We have updated the platform to have contiguous memory support. Please
    remove the platform you downloaded in the hello world section and
    download the platform again from the following links:
        - [Ultra96 Platform](https://ese532-platforms.s3.amazonaws.com/hw6_platform_v2.tar.gz)
        - [Ultra96 Platform (Asia)](https://ese532-platforms-asia.s3.ap-northeast-2.amazonaws.com/hw6_platform_v2.tar.gz)
    - Extract the platform to a desired location.
    - Set the `PLATFORM_REPO_PATHS` to the extracted directory. For instance:
        ```
        export PLATFORM_REPO_PATHS=~/ese532_hw6_pfm
        ```
    - Get the source code from the `ese532_code` repository by pulling in the latest changes
    using:
        ```
        cd ese532_code/
        git pull origin master
        ```
        The code you will use for this section
        is in the `hw6` directory. The directory structure looks like this:
        ```
        hw6/
            apps/
                mmult/
                    cpu/
                        Host.cpp
                    fpga/
                        hls/
                            MMult.cpp
                            MMult.h
                            testbench.cpp
                        Host.cpp
                        design.cfg
                        package.cfg
                        xrt.ini
                    Makefile
                    compile_on_biglab.sh
            common/
                ...
        ```
    - cd into `hw6/apps/mmult/` directory.
    - Use `make cpu` to build the cpu baseline and run with `./mmult_cpu`.
    - Use `make fpga -j4` to start the Vitis build. This will take about 20-30 minutes and generate the `xclbin`. Note that we used `-j4` to build with 4
    cpus. If you have more cpus, you can increase this number.
    `-j16` is usually the maximum parallel jobs Vitis can handle.
    - Use `make host` to build the OpenCL host code. This produces the `package` folder.
    - Copy the files from `package` folder to the Ultra96, reboot and run on the fpga.
    - Use `make clean` to clean all the generated files.
        ```{warning}
        If you do `make clean`, you will lose all the files and the compilation will start from the beginning. You can incrementally build and clean as mentioned in the walk-through.
        ``` -->

1. **Accelerator Interface**

    1. Run CPU version on Ultra96, and report the latency.
    1. For FPGA version, run the code,
    copy the Vitis Analyzer files to your computer and open them with Vitis Analyzer.
    Click ***Profile Summary***, and then ***Summary*** to see
    *Total application runtime* and *Total kernel runtime*.
    Click ***Kernels & Compute Units*** to see only the *kernel execution time*.
    We will check these three latencies throughout this HW.
    Report the latencies.
         <!--```{note}
         There are two types of platforms: datacenter and embedded. 
         Ultra96, we are using in class, is an embedded platform.
         In `host.cpp`, many [examples](https://github.com/Xilinx/Vitis_Accel_Examples/blob/2020.2/host/data_transfer/src/host.cpp)
         on the web, targeting datacenter cards, use `aligned_allocator` to avoid warnings regarding *unaligned host pointer*.
         Note that we use `enqueueMapBuffer`, and this approach is portable accross both datacenter and embedded platforms,
         as explained in Step 2 of [this tutorial](https://github.com/Xilinx/Vitis-Tutorials/blob/2020.2/Getting_Started/Vitis/Part3.md).
         ```
        1. In the previous step, you must have seen warnings regarding unaligned host pointer.
        You will now allocate contiguous host memories. 
        Take a look at Step 2 in [this tutorial](https://github.com/Xilinx/Vitis-Tutorials/blob/2020.2/Getting_Started/Vitis/Part3.md).
        In `apps/mmult/fpga/HostAligned.cpp`, we kindly provide three TODOs for this step.
            ```{hint}
            As shown in the example link, you should only use the following flags when allocating memory 
            using cl::Buffer: CL_MEM_READ_ONLY, CL_MEM_WRITE_ONLY, CL_MEM_READ_ONLY | CL_MEM_WRITE_ONLY. 
            All other flag usage prevents contiguous memory allocation or behaves non-deterministically on the Ultra96 
            (i.e. when using CL_MEM_USE_HOST_PTR).
            ```
        1. Build the project with the modified host code. Because only the host code is modified,
        it should take less than a minute to complete.
        Copy only neccessary files and report the three latencies in the Vitis Analyzer. -->
    1. In the Vitis Analyzer, open the application timeline. Zoom in at the beginning of the kernel execution, and
    provide a screenshot in the write up.
    Based on the analyzer, suggest at least two ways of improving the performance of the FPGA code.

        <!-- 1. How does the code in `Host.cpp` preserve dependencies between computations?

        1. We will now investigate why we still don't see communication-compute overlap.
            - In terminal, make sure you correctly sourced the settings, and open Vitis HLS, with:
                ```
                vitis_hls
                ```
            - Click on ***open project*** and browse to the your build generated directory: `hw6/apps/mmult/_x/kernel/mmult_fpga/mmult_fpga`
            and click open.
            - From the ***Explorer*** tab, open ***solution***$\rightarrow$***syn***$\rightarrow$***report***$\rightarrow$***mmult_fpga_csynth.rpt***.
            - Browse to the ***Interface*** section and examine
            the interface that was generated. Describe how the host processor communicates with the generated interface of the accelerator. -->

        <!-- 1. What needs to happen to the HLS code so that we can achieve task-level parallelism?
            ```{hint}
            Look at Figure 18: Host to Kernel Dataflow
            of [UG1393](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1393-vitis-application-acceleration.pdf#page=78)
            ``` -->

    1. We will now modify the kernel code.
        - In terminal, make sure you correctly sourced the settings, and open Vitis HLS, with:
            ```
            vitis_hls
            ```
        - Click on ***open project*** and browse to the your build generated directory: `hw6/apps/mmult/_x/kernel/mmult_fpga/mmult_fpga`
        and click open.

1. Partition the HLS code into Load-Compute-Store Pattern as can be seen in [this example](https://github.com/Xilinx/Vitis_Accel_Examples/tree/2021.1/cpp_kernels/dataflow_stream)    
    <!-- DJP: I think compute_add example is better -->
    <!-- [this code](https://github.com/Xilinx/Vitis-In-Depth-Tutorial/blob/master/Runtime_and_System_Optimization/Design_Tutorials/01-host-code-opt/reference-files/srcKernel/pass.cpp) -->
    and [this tutorial](https://github.com/Xilinx/Vitis-Tutorials/blob/2020.2/Getting_Started/Vitis_HLS/dataflow_design.md).
    Enable dataflow with `HLS DATAFLOW` pragma and use `hls::stream`
    to pass data between Load, Compute, Store functions. Make additional changes to the code to achieve II=1.

    1. Make sure to run C simulation and verify that your HLS code is functionally correct. Provide the code in your report.
    Also, provide the screenshot of ***Performance & Resource Estimates*** table in
    the Synthesis Summary Report. Because you have Load, Compute, Store functions,
    expand each function in the table to show that you achieved II=1.

    1. Rebuild the project with the dataflow-enabled kernel, copy the binaries and boot files, reboot and test. 
    This will take about 30 minutes to build. Report the latencies. Provide a screenshot of the relevant section of Application Trace from Vitis Analyzer.

    1. Our initial FPGA host code uses an in-order command queue.
    Find out how to use an out-of-order command queue 
    to get [overlap between communication and computation](https://docs.amd.com/r/2024.1-English/ug1393-vitis-application-acceleration/Overlapping-Data-Transfers-with-Kernel-Computation). 
    Make the necessary change in the `Host.cpp` and provide the change in the report. 
    Build the project with the modified host code. Report the three latencies. Provide a screenshot from Vitis Analyzer.
    We expect you to see something like {numref}`comp_comm_overlap` or {numref}`comp_comm_overlap_2`.
        ```{figure} images/comp_comm_overlap.png
        ---
        name: comp_comm_overlap
        ---
        Communication and Computation overlap
        ```
        ```{figure} images/comp_comm_overlap_2.png
        ---
        name: comp_comm_overlap_2
        ---
        Communication and Computation overlap when a kernel runtime is longer
        ```

    1. Use the following command in your host machine. Report the clocks, memory ports and resources that are available on the platform:
        ```
        platforminfo $PLATFORM_REPO_PATHS/u96v2_sbc_base.xpfm
        ```

    1. Assign separate ports to the `mmult_fpga`, then rebuild and run the kernel.
    This will take about 30 minutes to build. Report the latencies. Provide a screenshot of the relevant section of Application Trace from Vitis Analyzer. 
    Does assigning multiple ports on Ultra96 have any impact on your design?
    Save/Move the `hw6/apps/mmult/_x` folder of the project to somewhere else before doing the next question. 
    We will use the outputs from this question in the next part.
        ```{hint}
        - Learn about how to add multiple ports from [here](https://xilinx.github.io/Vitis-Tutorials/2020-2/docs/build/html/docs/Runtime_and_System_Optimization/Feature_Tutorials/01-mult-ddr-banks/README.html)
        - Under hw6/apps/mmult/fpga there is a file called design.cfg. In that file you will need to add the commands to map the kernel arguments to the ports under the `[connectivity]` section. You can find the commands in the tutorial linked above. You can use the memory ports available from part i. There is no need to create a separate connectivity.cfg file and modify the Makefile.
        - Read this [paper](https://ieeexplore.ieee.org/document/8977835/) to find out how to efficiently use the ports on Ultra96 (optional).

        ```

    1. Learn about how to use multiple compute units from 
    [here](https://xilinx.github.io/Vitis-Tutorials/2020-2/docs/build/html/docs/Runtime_and_System_Optimization/Feature_Tutorials/02-using-multiple-cu/README.html) 
    and apply it to your design. Note that you need to modify your host code to get multiple compute units working.
    Use 2 `mmult_fpga` units. This can be done by modifying `design.cfg`.    
    Rebuild the FPGA version, 
    copy the binaries and boot files, reboot and test. This will take about >30 minutes to build (While this is building, you can work on Part 2: Analyze Implementation). Report the latencies. 
    Provide a screenshot of the relevant section of Application Trace from Vitis Analyzer.
    ```{hint}
        - You may need to reduce the number of NUM_MAT and/or the size of your array partition from 2.1 
        ```

    1. Put your latency results from the CPU version in part a, and your FPGA implementations in parts b, g, j, and k into a table, and show the speedup relative to the CPU version.
    
1. **Analyze Implementation**

    In this question, we will investigate what the FPGA implementation
        of the matrix multiplication (Part 1k) look like using Vivado (not
        Vivado HLS).  Vivado is part of the Vitis installation.
    
    1. Report how many resources and utilization percentage of each type (BlockRAM, DSP unit,
    flip-flop, and LUT) the implementation (Part 1k)
    consumes. You can find this information in the ***Implementation*** tab on the
    left hand side. Click ***Report Utilization*** under ***Open Implemented Design***.
    Launch Vivado using the following commands and open the
    project you saved/moved from the location `hw6/apps/mmult/_x/link/vivado/vpl/prj/prj.xpr`. (4 lines)
        - In terminal, make sure you correctly sourced the settings, and open Vivado, with:
            ```
            vivado
            ```
    1. Report the expected power consumption of this design by clicking ***Report Power*** of the ***Implementation*** tab. (1 line)
    1. On the left top corner, you will see ***IP Integrator***. Click ***Open Block Design*** under
    ***IP Integrator***.  Open the ***Address Editor*** by choosing the corresponding
            tab above the block design.  In which memory region is the control interface of the
            accelerator wrapper `mmult_fpga_1` mapped?  This region
            is used for such communication as starting the accelerator and
            querying its status.  Writes and reads by the ARM processor are to
            this region are sent over an AXI4-Lite bus to the accelerator
            wrapper, which handles them and controls the accelerator. (1 line)
    1. Open the timing report by going to the ***Implementation*** tab and pressing ***Design Timing Summary*** from the ***Timing*** tab.  Click on
            the number next to [Worst Negative Slack](http://www.vlsi-expert.com/2011/03/static-timing-analysis-sta-basic-timing.html).
  Look at the
            `Path Properties`.  Report in which of the hardware modules that we
            saw in the block design the path begins and ends. (1 line)
    1. Include a screenshot of the critical path in your writeup.
            Zoom in to make sure all elements of the path are clearly visible.
            Indicate the type of each element (e.g. LUT, flip-flop,
            carry chain) on the screenshot.
    1. Highlight the accelerators in green, the interconnect (`M_AXI` and `S_AXI`) in yellow.  You can do this by right-
            clicking the modules in the Netlist view and selecting
            ***Highlight Leaf Cells***.  Include a screenshot of the entire
            device in your report.

## Deliverables
In summary, upload the following in their respective links in canvas:
  - writeup in pdf.
