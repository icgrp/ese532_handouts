# Setup and Walk-through

<style type="text/css">
    .table { margin-left:auto; margin-right:auto;}
    .table { width: 70%; }
    th { background-color: #4CAF50;color: white;height:50px;text-align: center; }
    td {height:50px;text-align: center;}
    tr:nth-child(even) {background-color: #f2f2f2;}
</style>
## Vectorization
We will divide the computation into vectors that run on 
the NEON units in our ARM cores.
{numref}`cortex-a53` shows the high level block diagram of
the ARM core in Ultra96 board.

```{figure} images/cortex-a53.png
---
name: cortex-a53
---
ARM Cortex A-53 Overview. Source: [ANANDTECH](https://www.anandtech.com/show/7591/answered-by-the-experts-arms-cortex-a53-lead-architect-peter-greenhalgh)
```
The Ultra96 boards have ARM Cortex A-53 cores. It's a
2-way decode, in-order core with one 64-bit NEON SIMD unit,
as shown in {numref}`arm-core-table`.
```{list-table} ARM Core, Source: [A-53](https://www.anandtech.com/show/8718/the-samsung-galaxy-note-4-exynos-review/3)
:header-rows: 1
:name: arm-core-table

* -  
  - Cortex A-53
* - ARM ISA
  - ARMv8 (32/64-bit)
* - Decoder Width
  - 2 micro-ops
* - Maximum Pipeline Length
  - 8
* - Integer Add
  - 2
* - Integer Mul
  - 1
* - Load/Store Units
  - 1
* - Branch Units
  - 1
* - FP/NEON ALUs
  - 1x64-bit
* - L1 Cache
  - 8KB-64KB I\$ + 8KB-64KB D\$
* - L2 Cache
  - 128KB - 2MB (Optional)
```
We will use the NEON Intrinsics API to program the NEON
Units in our cores. An intrinsic behaves syntactically like a function,
but the compiler translates it to a specific instruction that is inlined
in the code. In the following sections, we will guide you through
reading the NEON Programmer's guide and learning to use these APIs.

## Obtaining the Code
In the previous homework, we dealt with a streaming application that
compressed a video stream, and explored how to implement coarse-grain data-level parallelism
and pipeline parallelism using `std::threads` to speedup the application. For this homework,
we will use the same application and implement fine-grain, data-level
parallelism on a vector architecture;  we will explore both auto
vectorization with the compiler and hand-crafted NEON vector intrinsics. 

- On you local machine, clone the `ese532_code`
    repository using the following command:
    ```
    git clone https://github.com/icgrp/ese532_code.git
    ```
    If you already have it cloned, pull in the latest changes
    using:
    ```
    cd ese532_code/
    git pull origin master
    ```
    The code you will use for [homework submission](homework_submission)
    is in the `hw4` directory. The directory structure looks like this:
    ```
    hw4/
        assignment/
            Makefile
            common/
                App.h
                Constants.h
                Stopwatch.h
                Utilities.h
                Utilities.cpp
            src/
                App.cpp
                Compress.cpp
                Differentiate.cpp
                Filter.cpp
                Scale.cpp
            neon_example/
                Example.cpp
        data/
            Input.bin
            Golden.bin
    ```
- We will now copy the `hw4` directory into the Ultra96.

## Environment Setup
### Setting up Ultra96 and Host Computer
We have provided you with:
- An Ultra96 board with a power cable and a JTAG USB cable
- 2 USB-ethernet adapters
- 1 ethernet cable
- 1 SD card and an SD card reader
- USB-C to USB 3.1 adaptor (for those of you who only have USB-C ports in your computer)

Your setup for this HW should look like {numref}`ultra96-setup`.
```{figure} images/env_setup.jpg
---
name: ultra96-setup
---
Development Environment
```

### Run on the FPGA
#### Write the SD Card Image
- Download a sample SD card image for Ultra96 from
[here](https://www.element14.com/community/docs/DOC-95649/l/ultra96-v2).
  - In the **Reference Designs** tab:
    - Click on the **Ultra96-V2 – Vitis PetaLinux Platform 2020+ Vector Add (Sharepoint site)** link.
    - Browse to **2020.2** -> **Vitis_PreBuilt_Example** -> **u96v2_sbc_vadd_2020_2.tar.gz**
    - Click on the download button
- Then, unzip the file. The .gz file contains `sd_card.img` and `README.txt`.
    ```
    tar -xvzf u96v2_sbc_vadd_2020_2.tar.gz
    ```
- Write `sd_card.img` to your SD card.
    - In Ubuntu 20.04, you can use `Startup Disk Creator`.
    - You can also use [Rufus](https://rufus.ie/) or
      [balenaEtcher](https://www.balena.io/etcher/).
- Once you finish writing the image to the SD card, slide it into your Ultra96's SD card slot.

#### Boot the Ultra96 (Environment - Personal Computer with Linux)
- The instructions here are for users running Linux on their personal computers. For Windows users, skim these through, and
  go to {ref}`boot_windows`.
- Make sure you have the board connected as shown in {numref}`ultra96-setup`.
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
- Let's copy `hw4` directory to Ultra96:
    ```
    scp -r hw4 root@10.10.7.1:/home/root/
    ```

(boot_windows)=
#### Boot the Ultra96 (Environment - Personal Computer or Detkin Machines with Windows)
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

- Click plus sign to open up the local machine's session(new tab).
  Type `ifconfig` and find out the ip address and netmask assigned to the USB-ethernet device. Following is the example:
    ```{figure} images/win_eth_1.jpg
    ifconfig to find out your local machine's ip
    ```
- Assign your Ultra96 an ip address on the same subnet as the USB-ethernet, e.g. from the
  previous step, the ip address of the local machine is `169.254.123.23` and netmask is
  `255.255.0.0`. So, let's assign the ultra96 to a ip of `169.254.123.24`(note that
  this is 24!) as follows:
    ```{figure} images/win_eth_2.jpg
    Connect you machine and Ultra96
    ```
- Your devices are now connected. Go to the local machine's tab and ssh into the Ultra96:
    ```{figure} images/win_eth_3.jpg
    ssh in to the Ultra96 and transfer files
    ```
- You can view the files of the Ultra96 on the left hand side.
  You can easily drag and drop files from/to the local machine to/from Ultra96.
  Drag and drop `hw4` folder on the left hand side to start this HW.

## Running the Code
- There are 3 targets, which we will build **in the Ultra96**. You can build all of them by executing `make all`
    in the `hw4/assignment` directory. You can build separately by:
    - `make baseline` and `./baseline` to run the project with no vectorization of 
      `Filter_vertical` function.
    - `make neon_filter` and `./neon_filter` to run the project with `Filter_vertical` vectorized
      (you will modify the vectorized code later).
    - `make example` and `./example` to run the neon example.
- The `data` folder contains the input data, `Input.bin`, which has 200 frames of
    size $960$ by $540$ pixels, where each pixel is a byte. `Golden.bin` contains the
    expected output. Each program uses this file to see if there is a mismatch between
    your program's output and the expected output.
- The `assignment/common` folder has header files and helper functions used by the
    four parts.
- You will mostly be working with the code in the `assignment/src` folder.

## Working with NEON
We are going to do some reading from the arm developer website articles and
the NEON Programmer's Guide in the following sections.
### Basics

Read [Introducing Neon for Armv8-a](https://developer.arm.com/architectures/instruction-sets/simd-isas/neon/neon-programmers-guide-for-armv8-a/introducing-neon-for-armv8-a/single-page) and answer the
following questions. We have given you the answers, however make sure you
do the reading! Knowing where to look in a programmer's
guide is a skill by itself and we want to learn it now rather than later.
```{admonition} 1. Give an example of a SISD instruction.
:class: dropdown
`add r0, r5`

and any instruction from the {download}`ARM and Thumb-2 ISA quick reference guide <../hw2/pdfs/QRC0001_UAL.pdf>`
```
```{admonition} 2. Give an example of a SIMD instruction.
:class: dropdown
`add v10.4s, v8.4s, v9.4s`

and any instruction from the [NEON quick reference guide](https://community.arm.com/developer/tools-software/oss-platforms/b/android-blog/posts/arm-neon-programming-quick-reference)
```
```{admonition} 3. What is the size of a register in a Armv8-A NEON unit?
:class: dropdown
128-bit
```
```{admonition} 4. What does a NEON register contain?
:class: dropdown
vectors of elements of the same data type
```
```{admonition} 5. How many sizes of NEON vectors are there and what are those sizes?
:class: dropdown
Two sizes: 64-bit and 128-bit NEON vectors
```
```{admonition} 6. What is a lane?
:class: dropdown
The same element position in the input and output registers is referred to as a lane.
```
```{admonition} 7. How many lanes are there in a uint16x8_t NEON vector data type?
:class: dropdown
8
```
```{admonition} 8. How many lanes are there in a uint32x2_t NEON vector data type?
:class: dropdown
2
```
```{admonition} 9. Can there be a carry or overflow from one lane to another?
:class: dropdown
No.
```

---
Read [NEON and floating-point registers](https://developer.arm.com/documentation/den0024/a/armv8-registers/neon-and-floating-point-registers) and answer the
following questions:
```{admonition} 1. How many NEON registers are there in ARMv8 and what are they labeled as?
:class: dropdown
32 128-bit NEON registers, labeled as V0-V31.
```
```{admonition} 2. What is the difference between an operand labeled v0.16b and an operand labeled q0?
:class: dropdown
v0.16b is a vector register and has 16 lanes with each lane having 1 byte.
q0 is a scalar register of 128-bits.
```
```{admonition} 3. Are registered labeled b0, h0, s0, d0, q0 separate registers?
:class: dropdown
No, all of them belong to the same register v0. They are qualified names for registers when a NEON instruction operate on scalar data. 
```

---
Read chapter four from the {download}`NEON Programmer's Guide <pdfs/neon_programmers_guide.pdf>` and answer the following questions:
```{admonition} 1. Where are the NEON Intrinsics declared?
:class: dropdown
in `arm_neon.h` header file
```
```{admonition} 2. What NEON data type are you going to use for an unsigned char array of size 16 elements?
:class: dropdown
uint8x16_t. It will got to Q register.
```
```{admonition} 3. When should you use intrinsics with 'q' suffix vs intrinsics without 'q' suffix?
:class: dropdown
When the input and output vectors are 64-bit vectors, don't use intrinsics with 'q' suffix.
When the input and output vectors are 128-bit vectors, do use intrinsics with 'q' suffix.
```

(coding-neon)=
### Coding with NEON Intrinsics
Read chapter four from the NEON Programmer's Guide and answer the following questions.
Use the [Neon Intrinsics Reference](https://developer.arm.com/architectures/instruction-sets/simd-isas/neon/intrinsics) website to find and understand any instruction.
```{tip}
This will help you in coding for your homework.
```
```{admonition} 1. Which intrinsic should you use to duplicate a scalar value to a variable of type uint16x8_t?
:class: dropdown
`vdupq_n_u16`
```
```{admonition} 2. Which intrinsic should you use to load 16 bytes from a pointer to a variable of type uint8x16_t?
:class: dropdown
`vld1q_u8`
```
```{admonition} 3. Which intrinsic should you use to add two vectors of type uint8x8_t without overflowing?
:class: dropdown
`vaddl_u8`
```
```{admonition} 4. Which intrinsic should you use to get the first 8 lanes (low) of a variable of type uint8x16_t?
:class: dropdown
`vget_low_u8`
```
```{admonition} 5. Which intrinsic should you use to get the second 8 lanes (high) of a variable of type uint8x16_t?
:class: dropdown
`vget_high_u8`
```
```{admonition} 6. Which intrinsic should you use to multiply two vectors of type uint16x8_t?
:class: dropdown
`vmulq_u16`
```
```{admonition} 7. Which intrinsic should you use to multiply two vectors of type uint16x8_t and accumlate the result to a variable of type uint16x8_t?
:class: dropdown
`vmlaq_u16`
```
```{admonition} 8. Which intrinsic should you use to shift a variable of type uint16x8_t to the right?
:class: dropdown
`vshrq_n_u16`
```
```{admonition} 9. Which intrinsic should you use to cast the uint8_t values in a variable of type uint8x8_t to be uint16_t?
:class: dropdown
`vmovl_u8`
```
```{admonition} 10. Which intrinsic should you use to cast the uint16_t values in a variable of type uint16x8_t to be uint8_t?
:class: dropdown
`vmovn_u16`
```
```{admonition} 11. Which intrinsic should you use to join two uint8x8_t vectors into a uint8x16_t vector?
:class: dropdown
`vcombine_u8`
```
```{admonition} 12. Which intrinsic should you use to store data from a uint8x16_t variable to a pointer?
:class: dropdown
`vst1q_u8`
```

### Optimization:
- Read section 2.1.10, 2.8, and chapter 5 from the NEON Programmer's Guide.
- Watch the talk: [Taming ARMv8 NEON: from theory to benchmark results](https://youtu.be/ixuDntaSnHI)
- Read (supplemental) [Optimizing C Code with Neon Intrinsics](https://developer.arm.com/architectures/instruction-sets/simd-isas/neon/neon-programmers-guide-for-armv8-a/optimizing-c-code-with-neon-intrinsics/single-page)
- Read (supplemental) [Coding for NEON](https://developer.arm.com/architectures/instruction-sets/simd-isas/neon/neon-programmers-guide-for-armv8-a/coding-for-neon/single-page)
- Read (supplemental) [Neon Intrinsics Chromium Case Study](https://developer.arm.com/architectures/instruction-sets/simd-isas/neon/neon-programmers-guide-for-armv8-a/neon-intrinsics-chromium-case-study/single-page)
- Read (supplemental) [Program Optimization through Loop Vectorization](http://www.cs.utexas.edu/~pingali/CS377P/2017sp/lectures/david-vectorization.pdf)

### More Resources:
- [NEON Quick reference guide](https://community.arm.com/developer/tools-software/oss-platforms/b/android-blog/posts/arm-neon-programming-quick-reference)
- [NEON Intrinsics Reference](https://developer.arm.com/architectures/instruction-sets/simd-isas/neon/intrinsics)

