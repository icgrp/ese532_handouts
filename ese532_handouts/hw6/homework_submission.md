# Homework Submission
```{include} ../common/aws_caution.md
```
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

1. **Setup**

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
        ```

1. **Accelerator Interface**

    ---
    In this question, we will analyze how the processor
    core communicates with an accelerator.  We tell you some
    specific things to experiment with, but you should do some reading from:
    - Chapter 6, 7, 19, 20 of [UG1393](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_1/ug1393-vitis-application-acceleration.pdf)
    - [Programming for Vitis HLS](https://www.xilinx.com/html_docs/xilinx2020_1/vitis_doc/programmingvitishls.html#jro1585107736856)

    
    The following resources can be helpful for programming HLS and OpenCL host code:
    - [Vitis Accel Examples](https://xilinx.github.io/Vitis_Accel_Examples/master/html/index.html) and [Vitis Tutorials](https://xilinx.github.io/Vitis-Tutorials/master/docs/README.html)
    - [OpenCL 1.2 reference card](https://www.khronos.org/files/opencl-1-2-quick-reference-card.pdf)

    
    Note that we are running on Linux. If you want to gain a deeper understanding of what's going on under the hood and how the ***zocl*** driver supplied by Xilinx Runtime (XRT)
    manages DMA, refer to the following resources:
    - [Mastering DMA and IOMMU APIs](https://elinux.org/images/4/49/20140429-dma.pdf)
    - [Contiguous Memory Allocator](https://events.static.linuxfound.org/images/stories/pdf/lceu2012_nazarwicz.pdf)
    - [XRT Execution](https://xilinx.github.io/XRT/2020.1/html/execution-model.html)
    
    ---
    1. Build and run the cpu version of Matrix Multiplication by doing `make cpu`. Report the latency.
    1. Build and run the initial FPGA version by doing `make fpga && make host`. This build will take about 30 minutes.
    To run the code, open two terminals - one that is connected
    to the serial console and the other where you ssh'd into the
    Ultra96. Run the code from the ssh'd terminal to see only
    the output of the code. After you ran the code, look into the serial console terminal. You will see some useful
    information, such as bitstream being loaded, whether pointers
    are aligned etc. Report the latency of the initial FPGA version. Give at least two reasons based on the console outputs, why you think the initial FPGA implementation has
    a higher latency than the software version.
    1. You will now allocate contiguous host memories. Learn about how to do that from [here](https://developer.xilinx.com/en/articles/example-3-aligned-memory-allocation-with-opencl.html) and modify the `Host.cpp` code. Only build the host code by doing `make host` and copy it into the Ultra96 and run your modified code. Report the new latency.
    1. Copy in the `xrt.ini` file into the Ultra96 and run the FPGA code again to get the Vitis Analyzer files. Copy the 
    Vitis Analyzer files to your computer and open it with Vitis Analyzer. Zoom in at the beginning and provide a screenshot.
    Learn about the different metrics and your design topology by
    looking at the tabs on the left.
    Based on the analyzer, suggest at least two ways of improving
    the performance of the FPGA code.
    1. Our initial FPGA host code uses an in-order command queue.
    Find out [how to use an out-of-order command queue](https://xilinx.github.io/Vitis-Tutorials/master/docs/host-code-opt/README.html) to get overlap between communication and computation. Make the necessary change in the `Host.cpp`. Compile only the host code and run it. Report the latency. Provide a screenshot from Vitis Analyzer.
    1. How does the code in `Host.cpp` preserve dependencies between computations?
    1. We will now investigate why we still don't see communication-compute overlap.
        - Open a terminal and do:
            ```
            source /opt/Xilinx/Vitis/2020.1/settings64.sh
            vitis_hls
            ```
        - Click on ***open project*** and browse to the your build generated directory: `hw6/apps/mmult/_x/kernel/mmult_fpga/mmult_fpga/` and click open.
        - From the ***Explorer*** tab, open ***solution***$\rightarrow$***syn***$\rightarrow$***report***$\rightarrow$***mmult_fpga_csynth.rpt***.
        - Browse to the ***Interface*** section and examine
        the interface that was generated.
    Describe how the host processor communicates with the generated interface of the accelerator.
        ```{hint}
        Use the following resources:
        - [Learn about the interface](https://www.xilinx.com/html_docs/xilinx2020_1/vitis_doc/programmingvitishls.html#jro1585107736856)
        - [Learn about kernel execution model](https://xilinx.github.io/XRT/2020.1/html/xrt_kernel_executions.html)
        ```
    1. What needs to happen to the HLS code so that we can achieve task-level parallelism?
        ```{hint}
        Look at Figure 20: Host to Kernel Dataflow
        of [UG1393](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_1/ug1393-vitis-application-acceleration.pdf#page=87)
        ```
    1. Modify the HLS code to enable host to kernel dataflow. Make sure to run C simulation and verify that your HLS code is functionally correct. Provide the code in your report.
        ```{hint}
        - Use [this code](https://github.com/Xilinx/Vitis-Tutorials/blob/master/Runtime_and_System_Optimization/Design_Tutorials/01-host-code-opt/reference-files/srcKernel/pass.cpp) as a reference.
        - You will need to use `hls::stream`.
        - You will need to use `#pragma HLS DATAFLOW`.
        - Look into the warnings generated by Vitis HLS and determine what changes you need to make with `#pragma HLS INTERFACE`.
        - Refer to following resources for more examples on HLS:
            - [pp4fpga](http://kastner.ucsd.edu/wp-content/uploads/2018/03/admin/pp4fpgas.pdf).
            - [HLS Tiny Tutorials](https://github.com/Xilinx/HLS-Tiny-Tutorials)
        ```
    1. Rebuild the FPGA version by doing `make fpga`, copy the binaries and boot files, reboot and test. This will take about 30 minutes to build. Report the latency. Provide a screenshot of the relevant section of Application Trace from Vitis Analyzer.
    1. Use the following command in your host machine. Report the clocks, memory ports and resources that are available on the platform:
        ```
        platforminfo $PLATFORM_REPO_PATHS/ese532_hw6_pfm.xpfm
        ```
    1. Read about kernel and host code synchronization from [here](https://github.com/Xilinx/Vitis-Tutorials/blob/master/Runtime_and_System_Optimization/Design_Tutorials/01-host-code-opt/README.md#kernel-and-host-code-synchronization). Add a barrier synchronization to your host code. Only compile the host code, run it and provide a screenshot of the relevant section of vitis analyzer.
    1. Assign separate ports to the `mmult_fpga` in `design.cfg`. Rebuild the FPGA version by doing `make fpga`, copy the binaries and boot files, reboot and test. This will take about 30 minutes to build. Report the latency. Provide a screenshot of the relevant section of Application Trace from Vitis Analyzer. Does
    assigning multiple ports on Ultra96 have any impact on your design? Save/Move the `_x` folder of the project to somewhere else before doing the next question. We will use the outputs from this question in the next part.
        ```{hint}
        - Learn about how to add multiple ports from [here](https://github.com/Xilinx/Vitis-In-Depth-Tutorial/blob/master/Runtime_and_System_Optimization/Feature_Tutorials/01-mult-ddr-banks/README.md)
        - Read this [paper](https://ieeexplore.ieee.org/document/8977835/) to find out how to efficiently use the ports on Ultra96.
        ```
    1. Learn about how to use multiple compute units from [here](https://github.com/Xilinx/Vitis-Tutorials/blob/master/Runtime_and_System_Optimization/Feature_Tutorials/02-using-multiple-cu/README.md) and apply it to your design. Use 2 `mmult_fpga` units. Rebuild the FPGA version by doing `make fpga`, copy the binaries and boot files, reboot and test. This will take about 30 minutes to build. Report the latency. Provide a screenshot of the relevant section of Application Trace from Vitis Analyzer.
    
1. **Analyze Implementation**

    In this question, we will investigate what the FPGA implementation
        of the matrix multiplication (1m) look like using Vivado (not
        Vivado HLS).  Vivado is part of the Vitis installation.
    
    1. Report how many resources of each type (BlockRAM, DSP unit,
    flip-flop, and LUT) the implementation (1m)
    consumes.  You can find this information in the ***Implementation*** tab of Vivado and clicking on ***Report Utilization***.  Launch Vivado using the following commands and open the
    project at the location `hw6/apps/mmult/_x/link/vivado/vpl/prj/prj.xpr`. (4 lines)

        ```
        source /opt/Xilinx/Vitis/2020.1/settings64.sh
        vivado
        ```
    1. Report the expected power consumption of this design by clicking ***Report Power*** of the ***Implementation*** tab. (1 line)
    1. Open the ***Address Editor*** by choosing the corresponding
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
            clicking the modules in the netlist view and selecting
            ***Highlight Leaf Cells***.  Include a screenshot of the entire
            device in your report.

## Deliverables
In summary, upload the following in their respective links in canvas:
  - writeup in pdf.

```{include} ../common/aws_caution.md
```