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
1. Download 
***Xilinx Unified Installer 2020.2: Linux Self Extracting Web Installer*** in
[here](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vitis/2020-2.html). Create an account with Xilinx if you don't have one.
1. Open a terminal and use the following command:
    ```
    chmod +x Xilinx_Unified_2020.2_1118_1232_Lin64.bin
    ```
1. Extract the installer:
    ```
    ./Xilinx_Unified_2020.2_1118_1232_Lin64.bin --noexec --target ./xilinx-installer
    ```
1. Login with your Xilinx account:
    ```
    ./xsetup -b AuthTokenGen
    ```
    Type the email you have registered for xilinx and press enter.
    Type the password and press enter - the command from step 4 completes with `Saved authentication token file successfully`.
1. Save the attached {download}`ese532_install_config.txt <misc/ese532_install_config.txt>` and add your preferred installation location in the `Destination` field. The default location is `/opt/Xilinx`.
1. Start the installation with the following command:
    ```
    ./xsetup -b Install -a XilinxEULA,3rdPartyEULA,WebTalkTerms -c ese532_install_config.txt
    ```
    The full installation will take about 30 min - 1 hour.
1. Open the file `~/.bashrc` in your terminal and add the following line. This is the license for using Vitis:
    ```
    export LM_LICENSE_FILE="2100@potato.cis.upenn.edu;1709@potato.cis.upenn.edu;1717@potato.cis.upenn.edu;27010@potato.cis.upenn.edu;27009@potato.cis.upenn.edu"
    ```
    Do `source ~/.bashrc` to update the terminal environment
    with this variable.
1. You might need to issue the following commands if you encounter an error with `libtinfo`:
    ```
    sudo apt update
    sudo apt install libtinfo-dev
    sudo ln -s /lib/x86_64-linux-gnu/libtinfo.so.6 /lib/x86_64-linux-gnu/libtinfo.so.5
    ```

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
```
- `sourceMe.sh` will help you to source Xilins tools
- `xrt.ini` defines the options necessary for Vitis Analyzer.
- The `common` folder has header files and helper functions.
- You will mostly be working with the code in the `hls` folder. The 
    `hls/MatrixMultiplication.cpp` file has the function that gets compiled
    to a hardware function (known as a kernel in Vitis). The `Host.cpp` file has
    the "driver" code that transfers the data to the fpga, runs the kernel,
    fetches back the result from the kernel and then verifies it for correctness.
- Read [this](https://github.com/Xilinx/Vitis-Tutorials/blob/2020.2/Getting_Started/Vitis/Part3.md#the-source-code-for-the-vector-add-kernel) to learn about the syntax of the code in `hls/MatrixMultiplication.cpp`.
- Read [this](https://github.com/Xilinx/Vitis-Tutorials/blob/2020.2/Getting_Started/Vitis/Part3.md#the-source-code-for-the-host-program) to learn about how the hardware function is
utilized in `Host.cpp`
- Read [this](https://developer.xilinx.com/en/articles/example-1-simple-memory-allocation.html) to learn about simple memory allocation and OpenCL execution.
- Read [this](https://developer.xilinx.com/en/articles/example-3-aligned-memory-allocation-with-opencl.html) to learn about aligned memory allocation with OpenCL.

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
our hardware function using Vitis HLS IDE first and then re-compile it and run it on the FPGA in the end. 
Scroll to {ref}`vitis_hls` to learn about how to use Vitis HLS.

Once you have 3i completed from the {doc}`homework_submission`,
proceed {ref}`vitis`.

---

(vitis_hls)=
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
The different pragmas that you can use in your functions are listed in [Vitis HLS User Guide](https://www.xilinx.com/html_docs/xilinx2020_2/vitis_doc/hls_pragmas.html#okr1504034364623).

When you have obtained a satisfying hardware description in Vitis HLS, you will [Export Vitis Kernel](https://github.com/Xilinx/Vitis-Tutorials/blob/2020.2/Getting_Started/Vitis_HLS/dataflow_design.md#export-the-vitis-kernel), i.e. a Xilinx object file (.xo).
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
### Creating Vitis Project
Make sure you have 3i completed from the {doc}`homework_submission`.
- First, cd to the HW5 directory and source settings to be able to run vitis:
  `source sourceMe.sh`. If you work locally, source `settings64.sh` in vitis
  installation directory.
- Start Vitis by `vitis &` in the terminal. You should now see the IDE.
- Select Workspace as you want and click ***Launch***.
- Select ***Create Application Project***.
- You will see Ultra96 platform as shown below. Click ***Next***.
    ```{figure} images/vitis_ultra96_platform.png
    Select Ultra96 platform
    ```
- Set project name as you want. e.g. hw5_vitis. Then, click ***Next***.
- You will see Sysroot path, Root FS, and Kernel Image are already set.
  Click ***Next***.
    ```{figure} images/vitis_domain.png
    Application settings should have been already set
    ```
- We will create our own application. So, select Empty Application
  and click ***Finish***. The Vitis IDE creates the project and opens the Design perspective.
- In the Project Explorer view, you will see ***hw5_vitis [Petalinux]***.
  This is where the host code should be placed. Right-click the ***src*** folder
  under ***hw5_vitis [Petalinux]***, and select ***Import Sources***.
- Check all the utility codes in `ese532_code/hw5/common` and
  click ***Finish***.
- Right-click the ***src*** folder again, and similarly import `Host.cpp`
  in `ese532_code/hw5/`.
- This time, you want to add the kernel you just generated with Vitis HLS.
  You will see ***hw5_vitis_kernels*** in the Project Explorer.
  Right-click the ***src*** folder under
  ***hw5_vitis_kernels***, and select ***Import Sources***. Similarly,
  add `mmult.xo` to kernel's src folder and click ***Finish***. You now
  have the host application, `host.cpp`, and the Vitis HLS kernel,
  `mmult.xo`, in the project.
  Click ***Next***.
    ```{figure} images/vitis_import_src.jpg
    Import source files
    ```
- Double-click kernel project in the Project Exploer to open up
  the Hardware Kernel Project Settings.
- In the Hardware Functions section of the Project Settings view, select
  ***Add Hardware Functions***.
- You will see mmult function in the `mmult.xo`. Select mmult function
  and click ***OK***.
    ```{figure} images/vitis_hw_xo.jpg
    Add hardware function
    ```
- You will see Active build configuration on the upper right corner.
  Set it to ***Hardware***.
- In the Assistant view on the lower-left corner, you will see ***Hardware***
  is selected. Right-click ***Hardware*** and click ***build***. This process will
  take >20 minutes depending on your kernel design.


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
Your setup should look like {numref}`ultra96-setup-hw5`.
We will be using this setup for the rest of the semester.
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
Once the build has completed in {ref}`vitis` section, you will see a generated `package` directory. e.g. `hw5_vitis_system/Hardware/package`.
The package directory contains the following
files that we are interested in:
```
package/sd_card.img
package/sd_card/BOOT.BIN
package/sd_card/boot.scr
package/sd_card/image.ub
package/sd_card/hw5_vitis
package/sd_card/binary_container_1.xclbin
```
We suggest you to copy files above to your local machine and proceed.
If your laptop is Linux, you can use `scp` and if you are using
Windows you can use programs like [WinSCP](https://winscp.net/eng/index.php).
When you are building for the first time, we will write the
`package/sd_card.img` image to our SD card.

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
We will only have to write our SD card image once.
When we recompile our code, the files that will need to be
updated are:
```
package/sd_card/BOOT.BIN
package/sd_card/boot.scr
package/sd_card/image.ub
package/sd_card/hw5_vitis
package/sd_card/binary_container_1.xclbin
```
We will copy those files to the running board using `scp`.
We will then reboot the board, which will load the updated
boot files. The boot files contain the bitstream, which
reconfigures the ***Programmable Logic*** of the Ultra96. Hence,
we need a reboot. If you copy the files, but don't do a reboot,
you will see that your program throws an error.
````

````{note}
  If your Ultra96 is connected to a different machine from the one where
  you are running Vitis (e.g., you are running Vitis on a detkin machine,
  but your Ultra96 is connected to your laptop), you will need to first
  copy the files from the Vitis machine to the Ultra96-host machine and
  then copy them from the Ultra96-host to the Ultra96.
````

```{caution}
Make sure you don't hot plug/unplug the SD card. This can potentially corrupt the SD card/damage the board. Always shut down the device first and then insert/take out the SD card. You can shut down the device by typing "poweroff" in the serial console of the device.
```

#### Boot the Ultra96
````{note}
Please make sure you have set the board in SD card mode as follows:
```{figure} images/sd_card_mode.jpg
---
height: 300px
---
SD card mode. 1 is OFF and 2 is ON at SW3.
```

If you are receiving the boards disassembled, 
make sure you have properly connected the JTAG module as follows:
```{figure} images/jtag.png
---
height: 300px
---
JTAG module
```
````
- From now on, the setup is really similar to the one in HW4.
  But this time, we have something to run on FPGA's programmable logic!
- Make sure you have the board connected as shown in {numref}`ultra96-setup-hw5`.
- We will use two terminals on our host computer:
    - the first terminal will be used to copy binaries into the Ultra96
    - the second terminal will be used to access the serial console of the Ultra96
- We will now open the serial console of the Ultra96. You can use any program like `minicom`, `gtkterm` or `PuTTY` to connect to our serial port. We are using `minicom` and following is the command we use for connecting to the serial port:
    ```
    sudo minicom -D /dev/ttyUSB1
    ```
    `/dev/ttyUSB1` is the port where the Ultra96 dumps all
    the console output. If you are on Windows, this will be
    something different, like `COM4`. When you want to get out
    of `minicom`, use `CTRL-A Z q`
- After you have connected to the serial port, boot the board
by pressing the boot switch as shown in {numref}`boot`.
    ```{figure} images/boot.png
    ---
    name: boot
    height: 300px
    ---
    Switch for booting Ultra96
    ```
- Watch your serial console for boot messages.
- Note that near the end some messages spill, so just press Enter couple of times, and you see that you need to login. Login as `root` with Password: `root`.
    ```
    root@u96v2-sbc-base-2020-2:~#
    ```
- We will now enable ethernet connection between our Ultra96 and
    the host computer, such that we can copy files between
    the devices. Issue the following command in the serial console:
    ```
    ifconfig eth0 10.10.7.1 netmask 255.0.0.0
    ```
- Now in your second console in the host computer, first
    find out the name that has been assigned to the USB-ethernet
    device by issuing `ifconfig`
    ```
    enx000ec6c4b500: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
            inet 10.10.7.2  netmask 255.0.0.0  broadcast 10.255.255.255
            ether 00:0e:c6:c4:b5:00  txqueuelen 1000  (Ethernet)
            RX packets 213  bytes 32750 (32.7 KB)
            RX errors 0  dropped 0  overruns 0  frame 0
            TX packets 249  bytes 25958 (25.9 KB)
            TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
    lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
            inet 127.0.0.1  netmask 255.0.0.0
            inet6 ::1  prefixlen 128  scopeid 0x10<host>
            loop  txqueuelen 1000  (Local Loopback)
            RX packets 570887  bytes 920673672 (920.6 MB)
            RX errors 0  dropped 0  overruns 0  frame 0
            TX packets 570887  bytes 920673672 (920.6 MB)
            TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
    ```
    In our case, the USB-ethernet device is `enx000ec6c4b500`.
    Now issue the following command:
    ```
    sudo ifconfig enx000ec6c4b500 10.10.7.2 netmask 255.0.0.0
    ```
- We have now assigned IP `10.10.7.1` to our Ultra96 and IP `10.10.7.2` to our USB ethernet device connected to our host computer.
You can test the connection by doing `ping 10.10.7.2` from the Ultra96 serial console, and doing `ping 10.10.7.1` from the host
computer.

- If you haven't already done so, you can now use scp to copy files from
package/ to /mnt/sd-mmcblk0p1/ on the Ultra96.

- On the serial console, you can now run your code as follows:
    ```
    cd /mnt/sd-mmcblk0p1
    export XILINX_XRT=/usr
    ./hw5_vitis binary_container_1.xclbin
    ```
    You should see the following output:
    ```
    root@u96v2-sbc-base-2020-2:/mnt/sd-mmcblk0p1# ./hw5_vitis binary_container_1.xclbin
    Loading: 'binary_container_1.xclbin'
    TEST PASSED
    ```

- Let's copy another file. Copy the `xrt.ini` file from your computer to the `/mnt/sd-mmcblk0p1` directory of the Ultra96 as follows:
    ```
    scp xrt.ini root@10.10.7.1:/mnt/sd-mmcblk0p1/
    ```
    The default password of the device is `root` (you can setup ssh keys so that you don't have to type the passwords all the time).

- Now re-run the program as before. You should now see the generated files:
    ```
    binary_container_1.xclbin.run_summary
    profile_summary.csv
    timeline_trace.csv
    ```
- Copy these files to your computer by issuing the following command. Modify the command with the username of your computer and
    the directory you want to put the files in.
    ```
    scp binary_container_1.xclbin.run_summary timeline_trace.csv profile_summary.csv lilbirb@10.10.7.2:/media/lilbirb/research/
    ```

````{note}
  If your Ultra96 is connected to a different machine from the one where
  you are running Vitis (e.g., you are running Vitis on a detkin machine,
  but your Ultra96 is connected to your laptop), you will need to first
  copy the files the Ultra96-host machine as above, then copy from the Ultra96-host machine 
  to the Vitis machine.
````

- You can now use Vitis Analayzer in your host computer to view the trace by doing:
    ```
    vitis_analyzer ./binary_container_1.xclbin.run_summary
    ```
- When you modify your HLS code, that will cause the hardware to
change, and hence the following files will need to be copied to
the `/mnt/sd-mmcblk0p1` directory
    ```
    package/sd_card/BOOT.BIN
    package/sd_card/boot.scr
    package/sd_card/image.ub
    package/sd_card/hw5_vitis
    package/sd_card/binary_container_1.xclbin
    ```
    After you copy these files, type `reboot` in the serial
    console and that will reprogram the device.
    Note that everytime you reboot the device, you will
    need to issue the following commands:
    ```
    export XILINX_XRT=/usr
    ifconfig eth0 10.10.7.1 netmask 255.0.0.0
    ```
    You can put these commands in your `~/.bashrc` of the Ultra96 (use `vim` to edit this file in Ultra96), so that
    you don't have to type it all the time.
- When you only modify your host code, you don't have to copy any of the files mentioned above and only neeed to copy the
OpenCL host binary, which is `hw5_vitis` in this example. You also don't need to reboot the device in that case.

This concludes a top-down walk-through of the steps involved
in running a hardware function on the Ultra96.

#### Boot the Ultra96 (for Windows users only)
- Connect your ultra96 jtag usb to your computer. Also connect the ethernet-usb to ultra96 and the computer. Go to device managers and note down the serial port of the usb. In the example case, it's COM4.
    ```{figure} images/win_eth_0.jpg
    Find the port
    ```
- Download and install MobaXterm from [here](https://download.mobatek.net/2042020100805218/MobaXterm_Installer_v20.4.zip).
- Start MobaXterm. Click ***Session*** in the left top corner and select ***Serial***.
  Set the serial port as the one you found in the previous step and bps. In the example case,
  it's COM4 and 115200. Click ***OK***.
- Boot the board by pressing the boot switch as shown in {numref}`boot`.
- Note that near the end some messages spill, so just press Enter couple of times, and you see that you need to login. Login as `root` with Password: `root`.
    ```
    root@u96v2-sbc-base-2020-2:~#
    ```

- In the local machine's session, type ifconfig and find out the ip address and netmask assigned to the USB-ethernet device. Following is the example:
    ```{figure} images/win_eth_1.jpg
    ifconfig to find out your local machine's ip
    ```
- Assign your Ultra96 an ip address on the same subnet as the USB-ethernet, e.g. from the
  previous step, the ip address of the local machine is `169.254.123.23` and netmask is
  `255.255.0.0`. So, let's assign the ultra96 to a ip of `169.254.123.24`(**note that
  this is 24!**) as follows:
    ```{figure} images/win_eth_2.jpg
    Connect you machine and Ultra96
    ```
- Your devices are not connected. Go to the local machine's tab and ssh into the Ultra96:
    ```{figure} images/win_eth_3.jpg
    ssh in to the Ultra96 and transfer files
    ```

- If you haven't already done so, you can now use WinSCP to copy files from
BOOT to /mnt/sd-mmcblk0p1 on the Ultra96.

- On the serial console, you can now run your code as follows:
    ```
    cd /mnt/sd-mmcblk0p1
    export XILINX_XRT=/usr
    ./hw5_vitis binary_container_1.xclbin
    ```
    You should see the following output:
    ```
    root@u96v2-sbc-base-2020-2:/mnt/sd-mmcblk0p1# ./hw5_vitis binary_container_1.xclbin
    Loading: 'binary_container_1.xclbin'
    TEST PASSED
    ```

- You can see that you can view the files of the Ultra96 on the left hand side.
  You can easily drag and drop files from/to the local machine to/from Ultra96.
  Copy `xrt.ini` file from your computer to the `/mnt/sd-mmcblk0p1` directory
  of the Ultra96.

- Now re-run the program as before. You should now see the generated files:
    ```
    binary_container_1.xclbin.run_summary
    profile_summary.csv
    timeline_trace.csv
    ```
- Copy these files back to your local machine and analyze with Vitis Analyzer.
  <!-- If you installed Vitis on Windows, launch Vitis first and ***Xilinx*** $\rightarrow$ ***Vitis Shell*** to launch the shell. Then `vitis_analyer` to launch vitis_analyzer. -->


## Reference
<!-- - <https://github.com/Xilinx/Vitis-AWS-F1-Developer-Labs/blob/master/setup/instructions.md>
- <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html>
- <https://www.ni-sp.com/setting-up-access-to-the-nice-dcv-license-in-ec2/>
- <https://github.com/aws/aws-fpga/blob/master/Vitis/docs/Setup_AWS_CLI_and_S3_Bucket.md>
 -->
- <https://github.com/Xilinx/Vitis-Tutorials/tree/master/Getting_Started>
- <https://xilinx.github.io/Vitis-Tutorials/2020-1/docs/vitis_hls_analysis/using_the_kernel.html>
<!-- - <https://github.com/Xilinx/Vitis-Tutorials/blob/master/docs/Pathway3/BuildingAnApplication.md>
 -->
 <!-- - <https://github.com/aws/aws-fpga/blob/master/Vitis/README.md>
 -->

