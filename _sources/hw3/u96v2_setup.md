# Ultra96 Setup

## Linux vs Bare-Metal
```{figure} images/zynq-eg-block.png
---
height: 550px
name: zynq
---
AMD-Xilinx Zynq UltraScale+ MPSoC diagram
```
<!-- 
```{figure} images/topo.png
---
height: 450px
name: topo
---
An 8-core machine with 2 hyper-threads
``` 
-->

Ultra96 v2 board features Xilinx
[Zynq UltraScale+ MPSoC](https://www.xilinx.com/products/silicon-devices/soc/zynq-ultrascale-mpsoc.html#productAdvantages).
Zynq UltraScale+ MPSoC is a heterogeneous SoC that consists of 
Processing System (PS) and Processing Logic (PL).
PS includes the quad-core ARM Cortex A53-based APU (Application Processing Unit)
and the dual-core ARM Cortex R5-based RPU (Real-Time Processing Unit).
PL refers to FPGA hardware resources LUTs (Look-Up Tables), FFs (Flip-Flops), 
Block RAMs, DSPs, etc.
In this lab, we will first run Linux on the A53, and
we will divide the computation into threads that run on different cores.
<!-- {numref}`topo` shows a machine on Biglab. Some nodes in Biglab have 4 cores with
2 hyper-threads each and others have 8 cores with 1 thread each.
We will be running these threads on the Linux OS and hence, all the
heavy lifting of sharing main memory global address is taken care of
by the OS.  -->
Because we will be running multiple threads on the Linux OS, 
all the heavy lifting of sharing main memory global address is taken care of
by the OS.

However, in a bare-metal system:
- we would have to map the main memory (DRAM) into the address spaces of each processor.
    Only then can the processors distribute and coordinate the work (which
    involves communicating pointers to shared memory areas and synchronization).
- in order to share data, the processors in the bare-metal system must
    agree on the location and organization of the data.
- we must make sure that the processors respect each other's private memory areas.
    We can do that in a bare-metal system by mapping private code and data of
    individual processors at different locations.
- Sharing DRAM is complicated by the fact that DRAM is cached in L1 and L2 caches.
    Data that one processor attempts to write to DRAM may not have been written to
    shared DRAM yet, but instead remain in the private L1 cache of the processor.
    When another processor reads the same memory location, it may observe an old
    value. Fortunately, 
    <!-- our x86 processors (and the ARM on the Zynq we will later
    use) have  -->
    the ARM on the Zynq a Snoop Control Unit, which bypasses data directly between processors
    as needed to maintain a consistent view of the DRAM. Therefore, this is no concern.


Another problem that we face when we communicate via shared memory is that
the reading processor should not start reading the memory until the writing
processor has completed writing the data.  In other words, we need a form
of synchronization between the cores.  Design of synchronization functions
is a rather complex subject, which is dealt with in other courses such as
CIS 471 or CIS 505. In this assignment, we will use the APIs of `std::thread`
to accomplish synchronization between cores. We will show you exactly how to
use these APIs in the following sections, but if you would like to learn about
`std::threads`, here are some useful links:
- [Concurrency in C++](https://www.classes.cs.uchicago.edu/archive/2013/spring/12300-1/labs/lab6/)
- [C++11 threads, affinity and hyperthreading](https://eli.thegreenplace.net/2016/c11-threads-affinity-and-hyperthreading/)
- [C++ threads tutorial](https://www.bogotobogo.com/cplusplus/C11/1_C11_creating_thread.php)
- [Measuring Mutexes, Spinlocks and how Bad the Linux Scheduler Really is](https://probablydance.com/2019/12/30/measuring-mutexes-spinlocks-and-how-bad-the-linux-scheduler-really-is/)

If you prefer a book, refer to ***C++ Concurrency in Action*** by Anthony D. Williams.


## Environment Setup
### Setting up Ultra96 and Host Computer
**Starting this lab, we strongly suggest you to use Linux OS.**
If you have enough disk space, try installing Linux OS(e.g. Ubuntu) along with your original OS and dual-boot.

We have provided you with:
- An Ultra96 board with a power cable and a JTAG USB cable
  - Please check SW3 as the Note below. 
    1 should be in the "off" position, 
    and 2 should be in the "on" position.
- 2 USB-ethernet adapters
- 1 ethernet cable
- 1 SD card and an SD card reader
- USB-C to USB 3.1 adaptor (for those of you who only have USB-C ports in your computer)

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
> Be cautious with ESD protection when using this board with Ultra96. The Ultra96 has exposed pins on the UART and JTAG headers. Be careful not to touch these pins or the circuits on the Pod when plugging the boards together - <https://www.avnet.com/opasdata/d120001/medias/docus/190/5362-PB-AES-ACC-U96-JTAG-V3b.pdf>
```


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
[here](https://drive.google.com/file/d/1kWw6ch8QSahcWVRYBYGbf04U_CsNLFTY/view?usp=sharing).
  <!-- - In the **Reference Designs** tab:
    - Click on the **Ultra96-V2 – Vitis PetaLinux Platform 2020+ Vector Add (Sharepoint site)** link.
    - Browse to **2020.2** -> **Vitis_PreBuilt_Example** -> **u96v2_sbc_vadd_2020_2.tar.gz**
    - Click on the download button -->
- Then, unzip the `u96v2_sbc_vadd_2020_2.tar.gz`. The .gz file contains `sd_card.img` and `README.txt`.
    ``` bash
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
- We will now open the serial console of the Ultra96. 
  You can use any program like `minicom`, `gtkterm` or `PuTTY` to connect to our serial port. 
  We are using `PuTTY` and launch `PuTTY` by `sudo putty`. 
  The settings are shown in {numref}`putty`. `/dev/ttyUSB1` is the port where the Ultra96 dumps all
  the console output. If you are on Windows, this will be
  something different, like `COM4`. 
    ```{figure} images/putty.png
    ---
    name: putty
    ---
    PuTTY settings
    ```
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
    ```bash
    root@u96v2-sbc-base-2020-2:~#
    ```
- We will now enable ethernet connection between our Ultra96 and
    the host computer, such that we can copy files between
    the devices. Issue the following command in the serial console:
    ```bash
    ifconfig eth0 10.10.7.1 netmask 255.0.0.0
    ```
- Now in your second console **on the host computer**, first
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
- Unfortunately, currently every time you boot your Ultra96, you will have to login via serial and configure the IP address, before you can connect via ssh. To fix this, create a new file **on your host computer** `.profile` (make sure you don't do this in your home directory, or else you may overwrite an existing one). In `.profile`, add the following:
    ```bash
    ifconfig eth0 10.10.7.1 netmask 255.0.0.0

    alias ls="ls --color"
    alias ll="ls -laF --color"
    ```
    Then create another file (also not in your home directory), called `.bashrc`, and add the following:
    ```bash
    source .profile
    ```
    Next, copy these files over to to the Ultra96:
    ``` bash
    scp .profile .bashrc root@10.10.7.1:/home/root/
    ```
    Now when the Ultra96 boots, you should be able to connect directly over ssh without having to configure the board via serial.

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

- Unfortunately, currently every time you boot your Ultra96, you will have to login via serial and configure the IP address, before you can connect via ssh. To fix this, create a new file **on your host computer** `.profile` (make sure you don't do this in your home directory, or else you may overwrite an existing one). In `.profile`, add the following:
    ```bash
    ifconfig eth0 10.10.7.1 netmask 255.0.0.0

    alias ls="ls --color"
    alias ll="ls -laF --color"
    ```
    Then create another file (also not in your home directory), called `.bashrc`, and add the following:
    ```bash
    source .profile
    ```
    Next, drag and drop these files over to the Ultra96 in /home/root/. Now when the Ultra96 boots, you should be able to connect directly over ssh without having to configure the board via serial.