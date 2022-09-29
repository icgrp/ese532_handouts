# Setup and Walk-through
<!-- ```{include} ../common/aws_caution.md
``` -->
<style type="text/css">
    table { width: 100%; }
    th { background-color: #4CAF50;color: white;height:50px;text-align: center; }
    td {height:50px;text-align: center;}
    tr:nth-child(even) {background-color: #f2f2f2;}
</style>

## Hardware Acceleration
To implement a hardware function, it will ultimately be necessary
to perform low-level placement and routing of the hardware onto the
FPGA substrate.  That is, the tools must decide which particular instance of
each primitive is used (placement) or which wires to use for connections
(routing).  These tasks are typically much slower (at least 20 minutes, can take
hours) than the compilation time for software (a few minutes).  This means you
will need to plan your time carefully for this lab and for subsequent labs.
One way to optimize our development time is to be careful about when we
invoke low-level placement and routing and when we can avoid it.   This lab
and next will show you a few techniques that allow you to reduce the number of
times you need to invoke low-level placement and routing and introduce
 simulation and emulation you can use validate your design before
 invoking low-level placement and routing.

In the homework, you could either use linux machines in Detkin/Ketterer or 
install Vitis locally. If you want to install Vitis locally, we expect that your computer has at least:
- Linux OS
- 16 GB RAM
- 4 cores
- 70 GB free hard disk space
If you want to install Vitis locally, follow the instructions in 
{ref}`install_locally`. If you want to use Detkin/Ketterer machines, 
jump to {ref}`software_code`.

(install_locally)=
### Installing Vitis 2020.2 on your Personal Computer(Linux OS)
<!-- Running Vitis on your local computer will likely be the best interactive
experience with the GUI.  However, it will take more time and effort (and
disk space) to get it setup.  Ultimately, we recommend you set it up, but
the other two options means that getting it setup on your local computer
does not need to be in your critical path to starting to use the Ultra96. -->

<!-- Note that Vitis only supports Windows and Linux. Although
you can use Windows, we strongly suggest you install linux,
since we developed our homework code on Linux (Ubuntu 20.04). 
We won't be able to
help you if you encounter unexpected bugs and issues with tools
that may arise from using a different OS. For MacOS users,
you have no choice other than installing Vitis in a Virtual Machine. Following are two tutorials we have on setting up
a virtual machine. Use Ubuntu 20.04 and the use the instructions
below to install Vitis (the tutorials install SDSoC and you should not install that) on your virtual machine:
- [ESE532 SDSoC on Parallels Desktop](https://youtu.be/HaOWfmCAyCE)
- [ESE532 SDSoC on Virtual Box](https://docs.google.com/document/d/1XKVsD3gt8NeJgvcykNxD37CZME8r-dkUBl1D8KESYZk/edit?usp=sharing) -->

Note that Vitis is fully supported in Linux OS only.
Follow the instructions below to install Vitis on your linux machine:
1. Go to [this link](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html) and
select ***2020.2***. Then, download
***Xilinx Unified Installer 2020.2: Linux Self Extracting Web Installer***. Create an account with Xilinx if you don't have one.

1. We found [this video](https://youtu.be/debP5oI28l8) useful to install Vitis.

1. When selecting devices, selecting Zynq UltraScale+ MPSoC should be enough for this class.

    ```{figure} images/ese5320_vitis_devices.png
    ---
    name: ese5320_vitis_devices
    ---
    Selecting devices when installing Vitis
    ```
    The full installation will take about 30 min - 1 hour.

1. Open the file `~/.bashrc` in your terminal and add the following line. This is the license for using Vitis:
    ```
    export LM_LICENSE_FILE="2100@potato.cis.upenn.edu:1709@potato.cis.upenn.edu:1717@potato.cis.upenn.edu:27010@potato.cis.upenn.edu:27009@potato.cis.upenn.edu"
    ```
    Do `source ~/.bashrc` to update the terminal environment
    with this variable.
1. You might need to issue the following commands if you encounter an error with `libtinfo`:
    ```
    sudo apt update
    sudo apt install libtinfo-dev
    sudo ln -s /lib/x86_64-linux-gnu/libtinfo.so.6 /lib/x86_64-linux-gnu/libtinfo.so.5
    ```
1. As of January 1st 2022, there needs a patch. Download ***y2k22_patch-1.2.zip*** in [this link](https://support.xilinx.com/s/article/76960?language=en_US).
    Follow the instructions to apply y2k22 patch. If need help on this, please contact TAs.

1. Get the Ultra96 platform from [here](https://www.avnet.com/wps/portal/us/products/avnet-boards/avnet-board-families/ultra96-v2/).
   Scroll down and click **Reference Designs** tab. Then, click **Ultra96-V2 – Vitis Platform 2020+ (Sharepoint site)**.
   Click **2020.2**$\rightarrow$**Vitis_Platform**. Download **u96v2_sbc_vitis_2020_2.tar.gz**.
    ```
    tar -xvzf u96v2_sbc_vitis_2020_2.tar.gz
    ```
    Locate the extracted folder to wherever you want.

(software_code)=
### Obtaining and Running the Code
In this homework, we will first run a matrix multiplication function on the cpu and then run the same matrix multiplication
function on the FPGA.

Pull in the latest changes using:
```
cd ese532_code/
git pull origin master
```

The code you will use for [homework submission](homework_submission)
is in the `hw5` directory. The directory structure looks like this:
```
hw5/
    sourceMe.sh
    xrt.ini
    common/
        Constants.h
        EventTimer.h
        EventTimer.cpp
        Utilities.cpp
        Utilities.h
    hls/
        MatrixMultiplication.h
        MatrixMultiplication.cpp
        Testbench.cpp
    Host.cpp
    Makefile
    u96_v2.cfg
```
- `sourceMe.sh` will help you to source Xilinx tools
- `xrt.ini` defines the options necessary for Vitis Analyzer.
- The `common` folder has header files and helper functions.
- You will mostly be working with the code in the `hls` folder. The 
    `hls/MatrixMultiplication.cpp` file has the function that gets compiled
    to a hardware function (known as a kernel in Vitis). The `Host.cpp` file has
    the "driver" code that transfers the data to the fpga, runs the kernel,
    fetches back the result from the kernel and then verifies it for correctness.
- Read [this tutorial](https://github.com/Xilinx/Vitis-Tutorials/tree/2022.1/Getting_Started/Vitis) to get an idea of how the Vitis flow works.
  Note that there are *Data Center Platform* and *Embedded Platform*. Our ultra96 board belongs to *Embedded Platform*.
<!-- - Read [this](https://developer.xilinx.com/en/articles/example-1-simple-memory-allocation.html) to learn about simple memory allocation and OpenCL execution. -->
<!-- - Read [this](https://github.com/Xilinx/Vitis-Tutorials/blob/2020.2/Getting_Started/Vitis/Part3.md#the-source-code-for-the-vector-add-kernel) to learn about the syntax of the code in `hls/MatrixMultiplication.cpp`.
- Read [this](https://github.com/Xilinx/Vitis-Tutorials/blob/2020.2/Getting_Started/Vitis/Part3.md#the-source-code-for-the-host-program) to learn about how the hardware function is
utilized in `Host.cpp` -->

<!-- - Read [this](https://developer.xilinx.com/en/articles/example-3-aligned-memory-allocation-with-opencl.html) to learn about aligned memory allocation with OpenCL. -->

<!-- - Run the matrix multiplication on the cpu by doing:
    ```
    # compile
    source $AWS_FPGA_REPO_DIR/vitis_setup.sh
    export PLATFORM_REPO_PATHS=$(dirname $AWS_PLATFORM)
    make all TARGET=sw_emu

    # run
    source $AWS_FPGA_REPO_DIR/vitis_runtime_setup.sh
    export XCL_EMULATION_MODE=sw_emu
    ./host mmult.xclbin
    ```
- We will now use Vitis Analyzer to view the trace of our matrix multiplication on cpu
    and find out how long each API call took.
    1. Read about how to use Vitis Analyzer from [here](https://github.com/Xilinx/Vitis-Tutorials/blob/master/Getting_Started/Vitis/Part5.md).
<!--     1. Open a remote desktop session on your `z1d.2xlarge` instance. -->
<!--     1. Run `vitis_analyzer ./xclbin.run_summary` to open Vitis Analyzer and try to associate the api calls with the code in `Host.cpp`.
    1. Hover over an API call to find out long it took.
 -->
We are now going to start working on the {doc}`homework_submission` where we will follow a bottom-up approach and optimize 
our hardware function using Vitis HLS IDE first and then re-compile it and run it on the FPGA in the end. <!-- Scroll to {ref}`vitis_hls` to learn about how to use Vitis HLS. -->
[This tutorial](<https://github.com/Xilinx/Vitis-Tutorials/tree/2022.1/Getting_Started/Vitis_HLS>
) will give you a basic idea on Vitis HLS.

Once you have 3i completed from the {doc}`homework_submission`,
proceed {ref}`vitis`.

---

<!-- (vitis_hls)=
### Using Vitis HLS
Creating a new project in Vitis HLS is explained [here](https://github.com/Xilinx/Vitis-Tutorials/blob/2020.2/Getting_Started/Vitis_HLS/new_project.md#1-creating-a-vitis-hls-project).
Make sure you enter the top-level function during the creation of the
project (although you can also change it later). The top-level function is
the function that will be called by the part of your application that runs
in software.  Vitis HLS needs it for synthesis.  You can also indicate
which files you want to create.  It is wise to add a testbench file too,
while you are creating the project.

We have provided a testbench in Vitis HLS to debug the hardware.
The requirements for testbenches are not any different from other
software applications written in C.  Similar to them, testbenches
have a `main` function that is invoked.  To the main function you can
add any functionality needed to test your function.  That includes calling
the top function that you would like to test.  When the testbench is
satisfied that the function is correct, it should return 0.  Otherwise, it
should return another value.

You can run the testbench by selecting ***Project*** $\rightarrow$ ***Run C Simulation*** from the menu.  A window should pop up.  The default settings of the dialog
should be fine.  You can dismiss the dialog by pressing ***OK***.  You
can see in the ***Console*** whether your test has passed.  If your test
fails, you can run the test in debug mode.  This can be done by repeating
the same procedure, except that you should check the box in front of
***Launch Debugger*** this time before you dismiss the dialog.  This
will take you to the ***Debug*** perspective, where you can set breakpoints and use the step into/step over buttons to debug.  You can go back to the original perspective by pressing the ***Synthesis*** button in the top, right corner.  

To rebuild the code, you should go back to Synthesis mode, and click ***Run C Simulation*** again to rebuild the code.

Once you are satisfied with your code, you can run ***Solution***
$\rightarrow$ ***Run C Synthesis*** $\rightarrow$ ***Active Solution*** from the menu
to synthesize your design.  You can also verify the synthesized version of
your accelerator in your testbench.  If you choose to do so, Vitis HLS
will run your accelerator in a simulator, so this method is called C/RTL
Cosimulation.  The employed cycle-level simulation is much slower than
realtime execution, so this method may not be
practical for every testbench.  It avoids needing to run low
level-placement and routing and will give you more visibility into the
behavior of your design.  Anyway, you can start it by choosing
***Solution*** $\rightarrow$ ***Run C/RTL Cosimulation*** from the menu.

The hardware implementation that Vitis HLS selects can be controlled
by including pragmas, e.g. `#pragma HLS inline`, in your code.
The different pragmas that you can use in your functions are listed in [Vitis HLS User Guide](https://docs.xilinx.com/r/en-US/ug1399-vitis-hls/HLS-Pragmas).

When you have obtained a satisfying hardware description in Vitis HLS, you will [Export Vitis Kernel](https://github.com/Xilinx/Vitis-Tutorials/blob/2020.2/Getting_Started/Vitis_HLS/dataflow_design.md#export-the-vitis-kernel), i.e. a Xilinx object file (.xo).
 -->

<!-- We will then [use this object file/kernel](https://github.com/Xilinx/Vitis-In-Depth-Tutorial/blob/master/Getting_Started/Vitis_HLS/using_the_kernel.md) and link it together in our existing Vitis application. -->

<!-- ```{note}
We are using the GUI mode of Vitis HLS so that we can see the HLS schedule.
In this class, our preferred method of compiling is using the command line
and we'll only use GUI when it's required.

If your remote desktop connection is lagging, you can run Vitis HLS
from the command line using the script, `export_hls_kernel.sh`, 
in the `hw5/hls` directory. This script runs the TCL script, `run_hls.tcl`, 
with Vitis HLS. Vitis HLS GUI actually calls the commands in this TCL script.
If you look inside the TCL script, you can relate it to the GUI steps
we mentioned above. Additionally, you can learn more about the TCL commands
from:
- <https://www.xilinx.com/html_docs/xilinx2020_1/vitis_doc/tre1585063528538.html>
- <https://www.xilinx.com/html_docs/xilinx2020_1/vitis_doc/nfj1539734250759.html>

Note that the only way to see the HLS schedule is through the GUI.
So collaborate with your partner if you are unable to use the GUI in AWS or try
to [install Vitis toolchain locally](https://github.com/Xilinx/Vitis-In-Depth-Tutorial/blob/master/Getting_Started/Vitis/Part2.md#vitis-flow-101--part-2--installation-guide).
``` -->


(vitis)=
### Building the code
Make sure you have 3i completed from the {doc}`homework_submission`.
Vitis flow consists of **1)compiling the host code, 2)generating kernel object(.xo file), 3)generating FPGA binary(.xclbin file), 4)packaging to a bootable image.**
If you take a look at the Makefile, `make all` will execute steps specified above.

Because we already generated `mmult.xo` file, the command to generate Xilinx object file(`.xo`) is commented out.
Vitis compiler(`v++`) performs this step with `--copmile` flag. You can use `-c` for short.
You can also generate `.xo` file directly using Vitis HLS like we just did. FYI, you can create `.xo` file from RTL code too(obviously).

Next step, which is usually called "linking" step, calls Vivado to perform
logic synthesis, placement, and routing to generate a FPGA binary container file(`.xclbin`, Yes, this file encapsulates the bitstream that's necessary to program the FPGA).
Vitis compiler(`v++`) performs this step with `--linking` or `-l` for short.

The last step is called "packaging" step and is done with `--package` or `-p` for short.
This step packages your design and define various files required for booting/configuring the device.

- Make sure that `mmult.xo` exists in HW5 directory.
- Source settings to be able to run vitis:
  `source sourceMe.sh`. 
  
  **If you work locally**, source `settings64.sh` in vitis
  installation directory and do `export PLATFORM_REPO_PATHS=/PATH/TO/U96_V2_PLATFORM`.
  
  (e.g. `export PLATFORM_REPO_PATHS=/home/user/ese5320/u96v2_sbc_base`)
- `make all` to generate .xclbin file and bootable image.
  This process will take >20 minutes depending on your kernel design. 
  If you are working in Detkin/Ketterer, make sure that you have enough space in your user directory so that the image file does not exceed the quota.
    ```{note}
    In `u96_v2.cfg`, we commented out the profiling block.
    As mentioned in [here](https://docs.xilinx.com/r/2020.2-English/ug1393-vitis-application-acceleration/profile-Options),
    we can monitor data ports with Vitis Analyzer when the profiling is enabled. But it costs additional resources on the FPGA that makes
    the compilation longer, and we commented out for this assignment.
    ```
    ```{note}
    You may want to speedup the hardware later in your project. 
    To increase the clock frequency, you need to include a flag like `--clock.defaultFreqHz 200000000` when you do linking (`v++ --link`).
    If you search these useful information on the web, please make sure that it's applicable to the embedded platform.
    As mentioned earlier, there are datacenter platform and embedded platform; Ultra96 belong to the embedded platform.
    ```

## Environment Setup
### Setting up Ultra96 and Host Computer
<!-- We have provided you with:
- An Ultra96 board with a power cable and a JTAG USB cable
- 2 USB-ethernet adapters
- 1 ethernet cable
- 1 SD card and an SD card reader
- USB-C to USB 3.1 adaptor (for those of you who only have USB-C ports in your computer) -->

<!-- We expect you have a personal computer. If you intend to install
Vitis locally, we expect that your computer has at least:
- 16 GB RAM
- 4 cores
- 70 GB free hard disk space

Otherwise, our suggestion is that you compile your code either
on AWS or Biglab (shown later) and then later copy the binaries
to your personal computer, copy them into the board and finally run them on the board.
 -->
<!-- In the end,  -->
Your setup should look like {numref}`ultra96-setup-hw5` like we did in HW3 and HW4.
<!-- You can also use Windows PCs in Detkin/Ketterer. -->


```{figure} images/env_setup.jpg
---
height: 300px
name: ultra96-setup-hw5
---
Development Environment
```

### Run on the FPGA
#### Write the SD Card Image (one time setup)
Once the build has completed in {ref}`vitis` section, you will see a generated `package` directory. e.g. `hw5/package`.
The package directory contains the following
files that we are interested in:
```
package/sd_card.img
package/sd_card/BOOT.BIN
package/sd_card/boot.scr
package/sd_card/image.ub
package/sd_card/host
package/sd_card/mmult.xclbin
```
If you are working in Detkin/Ketterer machines, we suggest you to copy files above to your 
local machine and proceed. You can plug in USB disk to the Detkin/Ketterer machines and copy the
generated `package` directory over to your laptop. You can also use `scp` or WinSCP.
<!-- If your laptop is Linux, you can use `scp` and if you are using
Windows you can use programs like [WinSCP](https://winscp.net/eng/index.php).
When you are building for the first time, we will write the
`package/sd_card.img` image to our SD card. -->

- If another image is already written on your SD card(from HW3/HW4), delete the partitions.
  On Linux, you can do this from *Disks* application.
- Write `sd_card.img` to your SD card.
    - In Ubuntu 20.04, you can use `Startup Disk Creator`.
    - You can also use [Rufus](https://rufus.ie/) or
      [balenaEtcher](https://www.balena.io/etcher/).
- Once you finish writing the image to the SD card, slide it into your Ultra96's SD card slot.

<!-- - First put your SD card into the SD card reader and plug it to your computer.
- In Ubuntu 20.04, you can use `Startup Disk Creator`.
- You can also use [Rufus](https://rufus.ie/) or
      [balenaEtcher](https://www.balena.io/etcher/).
- After it's done, you can verify that there are two partitions in the SD card now:
    - the first partition has the files we mentioned above. These are the files that will change every time we build our code.
    - the second partition contains the Linux rootfs. This will not change. -->

````{note}
We will only have to write our SD card image **once**.
When we recompile our code, the files that will need to be
updated are:
```
package/sd_card/BOOT.BIN
package/sd_card/boot.scr
package/sd_card/image.ub
package/sd_card/host
package/sd_card/mmult.xclbin
```
We will copy those files to the running board using `scp`.
We will then reboot the board, which will load the updated
boot files. The boot files contain the bitstream, which
reconfigures the **Programmable Logic** of the Ultra96. Hence,
we need a reboot. If you copy the files, but don't do a reboot,
you will see that your program throws an error.
````

````{note}
  If your Ultra96 is connected to a different machine from the one where
  you are running Vitis (e.g., you are running Vitis on a Detkin machine,
  but your Ultra96 is connected to your laptop), you will need to first
  copy the files from the Vitis machine(Detkin machine) to the Ultra96-host machine(your laptop) and
  then copy them from the Ultra96-host(your laptop) to the Ultra96.
````

```{caution}
Make sure you don't hot plug/unplug the SD card. This can potentially corrupt the SD card/damage the board. Always shut down the device first and then insert/take out the SD card. You can shut down the device by typing "poweroff" in the serial console of the device.
```

#### Boot the Ultra96
- Boot the ultra96 as we did in HW3 and HW4. Login as `root` with Password: `root`.
- On the serial console, you can now run your code as follows:
    ```
    cd /media/sd-mmcblk0p1
    export XILINX_XRT=/usr
    ./host mmult.xclbin
    ```
    You should see the log message that the xclbin file is being loaded.
    ```
    Loading: 'mmult.xclbin'
    ```
    In the last line of the log message, you should see the testing message.
    ```
    TEST PASSED
    ```    
- You should see the generated files:
    ```
    mmult.xclbin.run_summary
    profile_summary.csv
    timeline_trace.csv
    ```
- Copy these files to your computer by issuing the following command. Modify the command with the username of your computer and
    the directory you want to put the files in.
    ```
    scp mmult.xclbin.run_summary timeline_trace.csv profile_summary.csv YOURNAME@10.10.7.2:/YOUR_DIR/
    ```
- If you are using Detkin/Ketterer machines, copy these files to Detkin/Ketterer machines and run
Vitis Analayzer in your host computer to view the trace by doing:
    ```
    vitis_analyzer ./mmult.xclbin.run_summary
    ```
- As stated in the note above, when you modify your HLS code, that will cause the hardware to
change, and hence the following files(regenerated) will need to be copied to
the `/media/sd-mmcblk0p1` directory
    ```
    package/sd_card/BOOT.BIN
    package/sd_card/boot.scr
    package/sd_card/image.ub
    package/sd_card/host
    package/sd_card/mmult.xclbin
    ```
    After you copy these files, type `reboot` in the serial
    console and that will reprogram the device.
- When you only modify your host code, you don't have to copy any of the files mentioned above and only neeed to copy the
OpenCL host binary, which is `host` in this example. You also don't need to reboot the device in that case.

This concludes a top-down walk-through of the steps involved
in running a hardware function on the Ultra96.


## Reference
<!-- - <https://github.com/Xilinx/Vitis-AWS-F1-Developer-Labs/blob/master/setup/instructions.md>
- <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html>
- <https://www.ni-sp.com/setting-up-access-to-the-nice-dcv-license-in-ec2/>
- <https://github.com/aws/aws-fpga/blob/master/Vitis/docs/Setup_AWS_CLI_and_S3_Bucket.md>
 -->
- <https://docs.xilinx.com/r/en-US/ug1393-vitis-application-acceleration> 
- <https://github.com/Xilinx/Vitis-Tutorials/tree/2022.1/Getting_Started/Vitis>
- <https://github.com/Xilinx/Vitis-Tutorials/tree/2022.1/Getting_Started/Vitis_HLS>
<!-- - <https://github.com/Xilinx/Vitis-Tutorials/blob/master/docs/Pathway3/BuildingAnApplication.md>
 -->
 <!-- - <https://github.com/aws/aws-fpga/blob/master/Vitis/README.md>
 -->

