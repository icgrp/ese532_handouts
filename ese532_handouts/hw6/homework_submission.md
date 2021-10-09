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

    ---
    Following the previous HW, we will create Vitis project using Vitis IDE.
    **Note that Makefiles are automatically generated when we build the project, 
    and you are welcome to use Makefiles in later in the project.** 
    In fact,
    many of Vitis tutorials on the web are using Makefile, which we
    highly recommend you to browse around while you are doing this lab.

    In this HW, we will analyze how the processor
    core communicates with an accelerator. We tell you some
    specific things to experiment with, but you should do some reading from:
    - This HW is based on [Xilinx Runtime (XRT) and Vitis System Optimization Tutorials](https://xilinx.github.io/Vitis-Tutorials/2020-2/docs/Runtime_and_System_Optimization/README.html)
    - Chapter 6, 7, 19, 20 of [UG1393](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1393-vitis-application-acceleration.pdf)
    - [Programming for Vitis HLS](https://www.xilinx.com/html_docs/xilinx2020_2/vitis_doc/vitis_hls_coding_styles.html)

    
    The following resources can be helpful for programming HLS and OpenCL host code:
    - [Vitis Accel Examples](https://github.com/Xilinx/Vitis_Accel_Examples/tree/2020.2) and [Vitis Tutorials](https://github.com/Xilinx/Vitis-Tutorials/tree/2020.2)
    - [OpenCL 1.2 reference card](https://www.khronos.org/files/opencl-1-2-quick-reference-card.pdf)

    
    Note that we are running on Linux. If you want to gain a deeper understanding of what's going on under the hood and how the ***zocl*** driver supplied by Xilinx Runtime (XRT)
    manages DMA, refer to the following resources:
    - [Mastering DMA and IOMMU APIs](https://elinux.org/images/4/49/20140429-dma.pdf)
    - [Contiguous Memory Allocator](https://events.static.linuxfound.org/images/stories/pdf/lceu2012_nazarwicz.pdf)
    - [XRT Execution](https://xilinx.github.io/XRT/2020.2/html/execution-model.html)
    
    ---
    1. Like we did in HW5, `source sourceMe.sh` first. Note that
    you need to adjust the `sourceMe.sh` if you are running
    on your local machine. 
    1. We will create CPU version's project. 
        1. Launch `vitis` and create application project as we did before. 
        All the steps are identical, but when selecting Templates, 
        select ***SW Development templates*** $\rightarrow$ ***Empty Applications (C++)***.
        1. Import following files to `src`: 
            - `common/*`
            - `apps/mmult/cpu/Host.cpp`
            - `apps/mmult/fpga/hls/MMult.h`
        1. Right click the project and select ***C/C++ Build Settings***.
        Click ***ARM v8 Linux g++ linker*** $\rightarrow$ ***Libraries***.
        Add `xilinxopencl` as shown below.
            ```{figure} images/vitis_cpu_linker.png
            Add linker flag
            ```
        1. Right click the project and select ***C/C++ Build Settings***.
        Click ***ARM v8 Linux g++ compiler*** $\rightarrow$ ***Optimization***.
        Set to **O3**.
        1. Build the project. You will see `.elf` created in Debug folder.
    1. Next, we will create FPGA version's project. 
        1. Right click the
        white space in the Project Explorer view, then ***New*** 
        $\rightarrow$ ***Application Project***. Set the name of the project as 
        **hw6_fpga**. When selecting Templates,
        select ***SW acceleration templates*** $\rightarrow$
        ***Empty Application***.
        1. For the kernel `src`, import following files: 
            - `apps/mmult/fpga/hls/MMult.h`
            - `apps/mmult/fpga/hls/MMult.cpp`
        1. For the host `src`, import following files:
            - `common/*`
            - `apps/mmult/fpga/Host.cpp`
            - `apps/mmult/fpga/hls/MMult.h`
        1. In kernel project, add `mmult_fpga` to the Hardware Functions.
        1. Select ***Hardware*** in Active build configuration on the
        upper right corner. Your project should look something like below.
            ```{figure} images/vitis_fpga_setting.png
            ---
            name: vitis_fpga_setting
            ---
            Add hardware function and set the build configuration to Hardware
            ```
        1. In the Assistant view on the lower left corner, you will see
        ***Hardware*** is bolded as shown in {numref}`vitis_fpga_setting`.
        Right click it and build the project. It will take about 30 minutes. 
        If you are run out of disk space, we recommend you to remove sd card image
        generated in HW5.
        1. Like we did in HW5, write the `package/sd_card.img` to the SD card.
        Then, enable the ethernet connection using `ifconfig`. `scp` the `.elf` file
        generated from CPU version.
    1. Run CPU version on Ultra96, and report the latency.
    1. For FPGA version, copy in the `xrt.ini` file into the Ultra96 and run the code.
    Copy the Vitis Analyzer files to your computer and open it with Vitis Analyzer.
    Click ***Profile Summary***, and then ***Summary*** to see
    *Total application runtime* and *Total kernel runtime*.
    Click ***Kernels & Compute Units*** to see only the *kernel execution time*.
    We will check these three latencies throughout this HW.
    Report the latencies.
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
    it should take less than a minute to complete. Note that you do **NOT** have to create a SD card again.
    Copy only neccessary files and report the three latencies in the Vitis Analyzer.
    1. In the Vitis Analyzer, open the application timeline. Zoom in at the beginning of the kernel execution, and
    provide a screenshot in the write up.
    Based on the analyzer, suggest at least two ways of improving the performance of the FPGA code.

    1. Our initial FPGA host code uses an in-order command queue.
    Find out [how to use an out-of-order command queue](https://www.xilinx.com/html_docs/xilinx2020_2/vitis_doc/optimizingperformance.html) 
    to get overlap between communication and computation. Make the necessary change in the `Host.cpp` and provide the change in the report. 
    Build the project with the modified host code. Report the three latencies. Provide a screenshot from Vitis Analyzer.
        ```{hint}
        It's just one additional property in command queue, and you probably won't see the overlap yet.
        ```
    1. How does the code in `Host.cpp` preserve dependencies between computations?
    1. We will now investigate why we still don't see communication-compute overlap.
        - In terminal, make sure you correctly sourced the settings, and open Vitis HLS, with:
            ```
            vitis_hls
            ```
        - Click on ***open project*** and browse to the your build generated directory: `hw6_fpga_kernels/Hardware/build/mmult_fpga/mmult_fpga/mmult_fpga`
        and click open.
        - From the ***Explorer*** tab, open ***solution***$\rightarrow$***syn***$\rightarrow$***report***$\rightarrow$***mmult_fpga_csynth.rpt***.
        - Browse to the ***Interface*** section and examine
        the interface that was generated. Describe how the host processor communicates with the generated interface of the accelerator.

    1. What needs to happen to the HLS code so that we can achieve task-level parallelism?
        ```{hint}
        Look at Figure 18: Host to Kernel Dataflow
        of [UG1393](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1393-vitis-application-acceleration.pdf#page=78)
        ```

    1. Modify the HLS code to enable host to kernel dataflow. Make sure to run C simulation and verify that your HLS code is functionally correct. Provide the code in your report.
        ```{hint}
        - Use [this code](https://github.com/Xilinx/Vitis-In-Depth-Tutorial/blob/master/Runtime_and_System_Optimization/Design_Tutorials/01-host-code-opt/reference-files/srcKernel/pass.cpp) 
        as a reference.
        - You will need to use `hls::stream`.
        - You will need to use `#pragma HLS DATAFLOW`.
        - Look into the warnings generated by Vitis HLS and determine what changes you need to make with `#pragma HLS INTERFACE`.
        - Refer to following resources for more examples on HLS:
            - [pp4fpga](http://kastner.ucsd.edu/wp-content/uploads/2018/03/admin/pp4fpgas.pdf).
            - [HLS Tiny Tutorials](https://github.com/Xilinx/HLS-Tiny-Tutorials)
        ```

    1. Rebuild the project with the dataflow-enabled kernel, copy the binaries and boot files, reboot and test. 
    This will take about 30 minutes to build. Report the latencies. Provide a screenshot of the relevant section of Application Trace from Vitis Analyzer.
    We expect you to see something like {numref}`comp_comm_overlap`.
        ```{figure} images/comp_comm_overlap.png
        ---
        name: comp_comm_overlap
        ---
        Communication and Computation overlap
        ```

    1. Use the following command in your host machine. Report the clocks, memory ports and resources that are available on the platform:
        ```
        platforminfo $PLATFORM_REPO_PATHS/u96v2_sbc_base.xpfm
        ```
    1. Read about kernel and host code synchronization from [here](https://xilinx.github.io/Vitis-Tutorials/2020-1/docs/host-code-opt/README.html#kernel-and-host-code-synchronization). Add a barrier synchronization to your host code. Only compile the host code, run it and provide a screenshot of the relevant section of vitis analyzer.

    1. Assign separate ports to the `mmult_fpga`. In the Assistant view on the lower left corner, 
    ***hw6_fpga_system_hw_link***$\rightarrow$***Hardware***$\rightarrow$***binary_container_1***. 
    Open Binary Container Settings, and in Compute Unit Settings, you can assign the ports.
    This will take about 30 minutes to build. Report the latency. Provide a screenshot of the relevant section of Application Trace from Vitis Analyzer. Does assigning multiple ports on Ultra96 have any impact on your design?
    Save/Move the `hw6_fpga_system_hw_link/Hardware/binary_container_1.build` folder of the project to somewhere else before doing the next question. 
    We will use the outputs from this question in the next part.
        ```{hint}
        - Learn about how to add multiple ports from [here](https://xilinx.github.io/Vitis-Tutorials/2020-2/docs/Runtime_and_System_Optimization/Feature_Tutorials/01-mult-ddr-banks/README.html)
        - Read this [paper](https://ieeexplore.ieee.org/document/8977835/) to find out how to efficiently use the ports on Ultra96.
        ```

    1. Learn about how to use multiple compute units from 
    [here](https://xilinx.github.io/Vitis-Tutorials/2020-2/docs/Runtime_and_System_Optimization/Feature_Tutorials/02-using-multiple-cu/README.html) 
    and apply it to your design. Use 2 `mmult_fpga` units. This can also be done in the Compute Unit Settings we visited in the previous question.    
    Rebuild the FPGA version, 
    copy the binaries and boot files, reboot and test. This will take about 30 minutes to build. Report the latencies. 
    Provide a screenshot of the relevant section of Application Trace from Vitis Analyzer. If you are run out of the FPGA resources, report it.
    
1. **Analyze Implementation**

    In this question, we will investigate what the FPGA implementation
        of the matrix multiplication (1m) look like using Vivado (not
        Vivado HLS).  Vivado is part of the Vitis installation.
    
    1. Report how many resources and utilization percentage of each type (BlockRAM, DSP unit,
    flip-flop, and LUT) the implementation (1-q)
    consumes. You can find this information in the ***Implementation*** tab on the
    left hand side. Click ***Report Utilization*** under ***Open Implemented Design***.
    Launch Vivado using the following commands and open the
    project you saved/moved from the location `binary_container_1.build/link/vivado/vpl/prj/prj.xpr`. (4 lines)
        - In terminal, make sure you correctly sourced the settings, and open Vitis HLS, with:
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
