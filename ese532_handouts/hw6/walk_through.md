# Setup and Walk-through

<style type="text/css">
    table { width: 100%; }
    th { background-color: #4CAF50;color: white;height:50px;text-align: center; }
    td {height:50px;text-align: center;}
    tr:nth-child(even) {background-color: #f2f2f2;}
</style>

## Obtaining and Running the Code
In this homework, we will first run a matrix multiplication function on the cpu and then run the same matrix multiplication
function on the FPGA.

Pull in the latest changes using:
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
                xrt.ini
            sourceMe.sh
    common/
        ...
```

## Useful Resources
Following the previous HW, we will create Vitis project using Vitis IDE.
**Note that Makefiles are automatically generated when we build the project in GUI mode, 
and you are welcome to use Makefiles later in the project.** 
In fact,
many of Vitis tutorials on the web are using Makefile, which we
highly recommend you to browse around while you are doing this lab.

In this HW, we will analyze how the processor
core communicates with an accelerator. We tell you some
specific things to experiment with, but you should do some reading from:
- This HW is highly related to this [Vitis Host Code Optimization Tutorial](https://xilinx.github.io/Vitis-Tutorials/2020-2/docs/build/html/docs/Runtime_and_System_Optimization/Design_Tutorials/01-host-code-opt/README.html)
- Chapter 6, 7, 19, 20 of [UG1393](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1393-vitis-application-acceleration.pdf)
- [Programming for Vitis HLS](https://docs.xilinx.com/r/2020.2-English/ug1399-vitis-hls/Vitis-HLS-Coding-Styles)


The following resources can be helpful for programming HLS and OpenCL host code:
- [Vitis Accel Examples](https://github.com/Xilinx/Vitis_Accel_Examples/tree/2020.2) and [Vitis Tutorials](https://github.com/Xilinx/Vitis-Tutorials/tree/2020.2)
- [OpenCL 1.2 reference card](https://www.khronos.org/files/opencl-1-2-quick-reference-card.pdf)
- [OpenCL Northeastern slides](https://ece.northeastern.edu/groups/nucar/Analogic/)


Note that we are running on Linux. If you want to gain a deeper understanding of what's going on under the hood and how the ***zocl*** driver supplied by Xilinx Runtime (XRT)
manages DMA, refer to the following resources:
- [Mastering DMA and IOMMU APIs](https://elinux.org/images/4/49/20140429-dma.pdf)
- [Contiguous Memory Allocator](https://events.static.linuxfound.org/images/stories/pdf/lceu2012_nazarwicz.pdf)
- [XRT Execution](https://xilinx.github.io/XRT/2020.2/html/execution-model.html)

## Building HW6
- Like we did in HW5, `source sourceMe.sh` first. Note that
you need to adjust the `sourceMe.sh` if you are running
on your local machine. To build the cpu version of mmult, run `make cpu`. To build the FPGA kernel, run `make fpga`. To build the host code, and create the files you need to copy over to the ultra96, run 'make host'.
<!--
- We will create the CPU version's project. 
    - Launch `vitis` and create application project as we did before. 
    All the steps are identical, but when selecting Templates, 
    select ***SW Development templates*** $\rightarrow$ ***Empty Applications (C++)***.
    - Import following files to `src`: 
        - `common/*`
        - `apps/mmult/cpu/Host.cpp`
        - `apps/mmult/fpga/hls/MMult.h`
    - Right click the project and select ***C/C++ Build Settings***.
    Click ***ARM v8 Linux g++ linker*** $\rightarrow$ ***Libraries***.
    Add `xilinxopencl` as shown below.
        ```{figure} images/vitis_cpu_linker.png
        Add linker flag
        ```
    - Right click the project and select ***C/C++ Build Settings***.
    Click ***ARM v8 Linux g++ compiler*** $\rightarrow$ ***Optimization***.
    Set to **O3**.
    - Build the project. You will see `.elf` created in Debug folder.
- Next, we will create FPGA version's project. 
    - Right click the
    white space in the Project Explorer view, then ***New*** 
    $\rightarrow$ ***Application Project***. Set the name of the project as 
    **hw6_fpga**. When selecting Templates,
    select ***SW acceleration templates*** $\rightarrow$
    ***Empty Application***.
    - For the kernel `src`, import following files: 
        - `apps/mmult/fpga/hls/MMult.h`
        - `apps/mmult/fpga/hls/MMult.cpp`
    - For the host `src`, import following files:
        - `common/*`
        - `apps/mmult/fpga/Host.cpp`
        - `apps/mmult/fpga/hls/MMult.h`
    - In kernel project, add `mmult_fpga` to the Hardware Functions.
    - Select ***Hardware*** in Active build configuration on the
    upper right corner. Your project should look something like below.
        ```{figure} images/vitis_fpga_setting.png
        ---
        name: vitis_fpga_setting
        ---
        Add hardware function and set the build configuration to Hardware
        ```
    - In the Assistant view on the lower left corner, you will see
    ***Hardware*** is bolded as shown in {numref}`vitis_fpga_setting`.
    Right click it and build the project. It will take about 30 minutes. 
    If you are run out of disk space, we recommend you to remove sd card image
    generated in HW5.
-->
- Like we did in HW5, copy the related files in `package/sd_card` directory
to Ultra96's `/mnt/sd-mmcblk0p1/` and type `reboot`.
Enable the ethernet connection using `ifconfig`.
Next, `scp` the `.elf` file generated from CPU version.



<!-- ## Environment Setup

### Setting up Ultra96 and Host Computer
We have provided you with:
- An Ultra96 board with a power cable and a JTAG USB cable
- 2 USB-ethernet adapters
- 1 ethernet cable
- 1 SD card and an SD card reader
- USB-C to USB 3.1 adaptor (for those of you who only have USB-C ports in your computer) -->

<!-- notes broke up that list too much... I think they can tolerate after -->
<!-- the list -->
<!-- 
````{note}
Some of you might be receiving the boards disassembled. In that case, make sure you have set the board in SD card mode as follows:
```{figure} images/sd_card_mode.jpg
---
height: 300px
---
SD card mode. 1 is OFF and 2 is ON at SW3.
```

And also make sure you have properly connected the JTAG module as follows:
```{figure} images/jtag.png
---
height: 300px
---
JTAG module
```
````
```{caution}
> Be cautious with ESD protection when using this board with Ultra96. The Ultra96 has exposed pins on the UART and JTAG headers. Be careful not to touch these pins or the circuits on the Pod when plugging the boards together - <http://www.zedboard.org/product/ultra96-usb-jtaguart-pod>
```

We expect you have a personal computer. If you intend to install
Vitis locally, we expect that your computer has at least:
- 16 GB RAM
- 4 cores
- 70 GB free hard disk space

Otherwise, our suggestion is that you compile your code either
on AWS or Biglab (shown later) and then later copy the binaries
to your personal computer, copy them into the board and finally run them on the board.

In the end, your setup should look like {numref}`ultra96-setup`.
We will be using this setup for the rest of the semester.
```{figure} images/env_setup.jpg
---
height: 800px
name: ultra96-setup
---
Development Environment
```

### Setting up the Build Machine
There are 3 ways you can run Vitis 2020.1.
Any of them will work and have pros and cons.
You can use a mix of them.  

#### Installing Vitis 2020.1 on your Personal Computer

Running Vitis on your local computer will likely be the best interactive
experience with the GUI.  However, it will take more time and effort (and
disk space) to get it setup.  Ultimately, we recommend you set it up, but
the other two options means that getting it setup on your local computer
does not need to be in your critical path to starting to use the Ultra96.


Note that Vitis only supports Windows and Linux. Although
you can use Windows, we strongly suggest you install linux,
since we developed our homework code on Linux (Ubuntu 20.04). We won't be able to
help you if you encounter unexpected bugs and issues with tools
that may arise from using a different OS. For MacOS users,
you have no choice other than installing Vitis in a Virtual Machine. Following are two tutorials we have on setting up
a virtual machine. Use Ubuntu 20.04 and the use the instructions
below to install Vitis (the tutorials install SDSoC and you should not install that) on your virtual machine:
- [ESE532 SDSoC on Parallels Desktop](https://youtu.be/HaOWfmCAyCE)
- [ESE532 SDSoC on Virtual Box](https://docs.google.com/document/d/1XKVsD3gt8NeJgvcykNxD37CZME8r-dkUBl1D8KESYZk/edit?usp=sharing)

Follow the instructions below to install Vitis on your personal
computer or in your linux virtual machine:
1. Download  [Xilinx Unified Installer 2020.1: Linux Self Extracting Web Installer](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2020.1_0602_1208_Lin64.bin). Create an account with Xilinx if you don't have one.
1. Open a terminal and use the following command:
    ```
    chmod +x Xilinx_Unified_2020.1_0602_1208_Lin64.bin
    ```
1. Extract the installer:
    ```
    ./Xilinx_Unified_2020.1_0602_1208_Lin64.bin --noexec --target ./xilinx-installer
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
#### Using Vitis on AWS

This is what you are already familiar using.  The plus side is it that
the tools are all setup and ready to go, and you already know how to
use AWS.  It's also possible that the AWS servers run the compiles faster
than your laptop or biglab.
The minus is the high remote latency that makes the GUI harder to
use and your limited amount of credit on AWS.  One best-of-both-world
option might be to only use AWS for slow compiles and use your local
machine for cases where you need to use the GUI.

Follow the instructions from the previous homeworks to create an AWS instance with [Amazon FPGA Developer AMI](https://aws.amazon.com/marketplace/pp/B06VVYBLZZ?qid=1585105385966&sr=0-1&ref_=srh_res_product_title). You can use the `t2.xlarge` instance, which costs about $0.186$/hr.

#### Using Vitis on Biglab

Biglab also allows you to use a setup that is known to work.
It has the plus that its free, so this will work after your Amazon credits
run out.  It will require you learn a bit to get yourself logged in and
setup to use biglab.   For those far from Penn, it may have the same high
latency problems on the GUI as AWS.

You can use UPenn's BigLab as instructed [here](https://cets.seas.upenn.edu/answers/biglab.html). Vitis is installed in the `/mnt/pollux/software/xilinx/2020.1/` directory. We provide you with a shell script (`compile_on_biglab.sh`) that sets up the environment
on BigLab and calls the make commands. Note that biglab can
be busy. You can find out which machine is free by going to <https://www.seas.upenn.edu/checklab/?lab=biglab>

   
## First Vitis Application on Ultra96
We are now going to run an application on the Ultra96 board
and verify our setup.
### Obtaining the Ultra96 Platform
- In your host machine, download the Ultra96 platform that you will use for
this homework (you can use `wget`). Use the asia-specific link if you are not in US
for faster download:
    - [Ultra96 Platform](https://ese532-platforms.s3.amazonaws.com/hw6_platform.tar.gz)
    - [Ultra96 Platform (Asia)](https://ese532-platforms-asia.s3.ap-northeast-2.amazonaws.com/hw6_platform.tar.gz)
- Extract the platform to a desired location.
- Set the `PLATFORM_REPO_PATHS` to the extracted directory. For instance:
    ```
    export PLATFORM_REPO_PATHS=~/ese532_hw6_pfm
    ```
### Obtaining and Building the Code
To verify our setup, we will run a simple vector addition
on the Ultra96.

---
Clone the `ese532_code` repository using the following command:
```
git clone https://github.com/icgrp/ese532_code.git
```
If you already have it cloned, pull in the latest changes
using:
```
cd ese532_code/
git pull origin master
```
The code you will use for this section
is in the `hw6_hello_world` directory. The directory structure looks like this:
```
hw6_hello_world/
    compile_on_biglab.sh
    Makefile
    design.cfg
    package.cfg
    xrt.ini
    vadd.h
    vadd.cpp
    krnl_vadd.cpp
```
- Make sure the `PLATFORM_REPO_PATHS` is setup from
the previous step.
- Open a terminal and issue the following command. Change the command to reflect the directory you installed
    Vitis in. The command sets up the paths used by the Makefile.
    ```
    source /opt/Xilinx/Vitis/2020.1/settings64.sh
    ```
    
- If you are compiling on BigLab:
    - git clone your repo on BigLab.
    - `wget` the Ultra96 platform in BigLab and extract it in a folder.
    - open the `compile_on_biglab.sh` file and change the
        `PLATFORM_REPO_PATHS` to reflect the folder you put the
        platform in.
    - Run `compile_on_biglab.sh` to compile the code. Note that
        by default `compile_on_biglab.sh` calls `make fpga`.
        Change it if you want to run a different make command.
        Also note that you ***need*** to run with a shell script on
        BigLab.
- Use `make fpga -j4` to start the full build. This will take about 20-30 minutes and generate the necessary files that will
go into your SD card. Note that we used `-j4` to build with 4
cpus. If you have more cpus, you can increase this number.
`-j16` is usually the maximum parallel jobs Vitis can handle.
- Use `make clean` to clean all the generated files.
    ```{warning}
    If you do `make clean`, you will lose all the files and the compilation will start from the beginning. You can incrementally build and clean.
    ```
- When modifying only part of the code, you can incrementally compile and build:
    - Use `make kernel.xclbin` to only build the HLS code.
    - Use `make clean-accelerators` to only clean the HLS code.
    - Use `make host` to only build the `vadd.cpp` host code.
    - Use `make clean-host` to only clean the generated files for the host code.
    - Use `make package` to generate the SD card files.
    - Use `make clean-package` to clean the generated SD card files.
- `design.cfg` defines several options for the v++ compiler. Learn more about it [here](https://developer.xilinx.com/en/articles/using-configuration-files-to-control-vitis-compilation.html).
- `package.cfg` contains the v++ compiler options for packaging the SD card.
- `xrt.ini` defines the options necessary for Vitis Analyzer.
- `vadd.cpp` and `vadd.h` contains the OpenCL host code.
- `krnl_vadd.cpp` contains the HLS code.

### Run on the FPGA
#### Write the SD Card Image (one time setup)
Once the build has completed, you will see a generated `package` directory. The package directory contains the following
files that we are interested in:
```
package/sd_card.img
package/sd_card/BOOT.BIN
package/sd_card/boot.scr
package/sd_card/image.ub
package/sd_card/vadd
package/sd_card/kernel.xclbin
```
When you are building for the first time, we will write the
`package/sd_card.img` image to our SD card. You can do that in
several ways:
- First put your SD card into the SD card reader and plug it to your computer.
- In Ubuntu 20.04, open the `Startup Disk Creator`. Select `Disk Images` from the drop down at the bottom right corner and locate
the `package/sd_card.img` file. Continue to write the image.
- After it's done, you can verify that there are two partitions in the SD card now:
    - the first partition has the files we mentioned above. These are the files that will change every time we build our code.
    - the second partition contains the Linux rootfs. This will not change.
- If you don't have `Startup Disk Creator`, you can use other programs like [balenaEtcher](https://www.balena.io/etcher/) or
[Rufus](https://rufus.ie/).
````{note}
We will only have to write our SD card image once.
When we recompile our code, the files that will need to be
updated are:
```
package/sd_card/BOOT.BIN
package/sd_card/boot.scr
package/sd_card/image.ub
package/sd_card/vadd
package/sd_card/kernel.xclbin
```
We will copy those files to the running board using `scp`.
If you compiled on BigLab or AWS, you need to first copy
the files to your local machine and then copy it to the board.
We will then reboot the board, which will load the updated
boot files. The boot files contain the bitstream, which
reconfigures the ***Programmable Logic*** of the Ultra96. Hence,
we need a reboot. If you copy the files, but don't do a reboot,
you will see that your program throws an error.
````
```{caution}
Make sure you don't hot plug/unplug the SD card. This can potentially corrupt the SD card/damage the board. Always shut down the device first and then insert/take out the SD card. You can shut down the device by typing "poweroff" in the serial console of the device.
```

#### Boot the Ultra96
- Make sure you have the board connected as shown in {numref}`ultra96-setup`.
- We will use two terminals on our host computer:
    - the first terminal will be used to copy binaries into the Ultra96
    - the second terminal will be used to access the serial console of the Ultra96
- We will now open the serial console of the Ultra96. You can use
any program like `minicom`, `gtkterm` or `PuTTY` to connect to our serial port. We are using `minicom` and following is the command we use for connecting to the serial port:
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
    height: 300px
    name: boot
    ---
    Switch for booting Ultra96
    ```
- Watch your serial console for boot messages. Following is what ours look like:
    ```
    �Xilinx Zynq MP First Stage Boot Loader 
    Release 2020.1   Oct 17 2020  -  06:29:34
    NOTICE:  ATF running on XCZU3EG/silicon v4/RTL5.1 at 0xfffea000
    NOTICE:  BL31: v2.2(release):v1.1-5588-g5918e656e
    NOTICE:  BL31: Built : 20:07:49, Oct 17 2020
    U-Boot 2020.01 (Oct 17 2020 - 20:08:47 +0000)
    Model: Avnet Ultra96 Rev1
    Board: Xilinx ZynqMP
    DRAM:  2 GiB
    .
    .
    .
    Starting kernel ...
    [    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd034]
    [    0.000000] Linux version 5.4.0-xilinx-v2020.1 (oe-user@oe-host) (gcc version 9.2.0 (GCC)) #1 SMP Sat Oct 17 20:08:16 UTC 2020
    [    0.000000] Machine model: Avnet Ultra96 Rev1
    [    0.000000] earlycon: cdns0 at MMIO 0x00000000ff010000 (options '115200n8')
    [    0.000000] printk: bootconsole [cdns0] enabled
    [    0.000000] efi: Getting EFI parameters from FDT:
    [    0.000000] efi: UEFI not found.
    [    0.000000] Reserved memory: created DMA memory pool at 0x000000003ed40000, size 1 MiB
    [    0.000000] OF: reserved mem: initialized node rproc@3ed400000, compatible id shared-dma-pool
    [    0.000000] cma: Reserved 512 MiB at 0x000000005fc00000
    .
    .
    .
    .
    Starting syslogd/klogd: done
    Starting tcf-agent: OK
    PetaLinux 2020.1 ultra96v2-2020-1 ttyPS0
    root@ultra96v2-2020-1:~# The XKEYBOARD keymap compiler (xkbcomp) reports:
    > Warning:          Unsupported high keycode 372 for name <I372> ignored
    >                   X11 cannot support keycodes above 255.
    >                   This warning only shows for the first high keycode.
    Errors from xkbcomp are not fatal to the X server
    D-BUS per-session daemon address is: unix:abstract=/tmp/dbus-2CuBS4BnDn,guid=63270a6bec61460191859caa5f9022fc
    matchbox: Cant find a keycode for keysym 269025056
    matchbox: ignoring key shortcut XF86Calendar=!$contacts
    matchbox: Cant find a keycode for keysym 2809
    matchbox: ignoring key shortcut telephone=!$dates
    matchbox: Cant find a keycode for keysym 269025050
    matchbox: ignoring key shortcut XF86Start=!matchbox-remote -desktop
    dbus-daemon[641]: Activating service name='org.a11y.atspi.Registry' requested by ':1.0' (uid=0 pid=636 comm="matchbox-desktop ")
    dbus-daemon[641]: Successfully activated service 'org.a11y.atspi.Registry'
    SpiRegistry daemon is running with well-known name - org.a11y.atspi.Registry
    [settings daemon] Forking. run with -n to prevent fork
    ```
- Note that near the end some messages spill, so just press Enter couple of times to see the familiar linux shell:
    ```
    root@ultra96v2-2020-1:~#
    ```
- On the serial console, run your code as follows:
    ```
    cd /mnt/sd-mmcblk0p1
    export XILINX_XRT=/usr
    ./vadd kernel.xclbin
    ```
    You should see the following output:
    ```
    root@ultra96v2-2020-1:/mnt/sd-mmcblk0p1# ./vadd kernel.xclbin
    Loading: 'kernel.xclbin'
    TEST PASSED
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
- Let's copy a file. Copy the `xrt.ini` file from your computer to the `/mnt/sd-mmcblk0p1` directory of the Ultra96 as follows:
    ```
    scp xrt.ini root@10.10.7.1:/mnt/sd-mmcblk0p1/
    ```
    The default password of the device is `root` (you can setup ssh keys so that you don't have to type the passwords all the time).
- Now re-run the program as before. You should now see the generated files:
    ```
    kernel.xclbin.run_summary
    profile_summary.csv
    timeline_trace.csv
    ```
- Copy these files to your computer by issuing the following command. Modify the command with the username of your computer and
    the directory you want to put the files in.
    ```
    scp kernel.xclbin.run_summary timeline_trace.csv profile_summary.csv lilbirb@10.10.7.2:/media/lilbirb/research/
    ```
- You can now use Vitis Analayzer in your host computer to view the trace by doing:
    ```
    vitis_analyzer ./kernel.xclbin.run_summary
    ```
- When you modify your HLS code, that will cause the hardware to
change, and hence the following files will need to be copied to
the `/mnt/sd-mmcblk0p1` directory
    ```
    package/sd_card/BOOT.BIN
    package/sd_card/boot.scr
    package/sd_card/image.ub
    package/sd_card/vadd
    package/sd_card/kernel.xclbin
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
OpenCL host binary, which is `vadd` in this example. You also don't need to reboot the device in that case.

This concludes a top-down walk-through of the steps involved
in running a hardware function on the Ultra96. -->
