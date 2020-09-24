# Setup and Walk-through
```{include} ../common/aws_caution.md
```
<style type="text/css">
    table { width: 100%; }
    th { background-color: #4CAF50;color: white;height:50px;text-align: center; }
    td {height:50px;text-align: center;}
    tr:nth-child(even) {background-color: #f2f2f2;}
</style>
## Vectorization
We will divide the computation into vectors that run on 
the NEON units in our ARM cores.
{numref}`cortex-a72` shows the microarchitecture of the
ARM cores in our A1 instance. It's a 3-way decode, out-of-order
core with two 128-bit NEON SIMD units.
```{figure} images/cortex-a72.png
---
height: 500px
name: cortex-a72
---
Microarchitecture of ARM Cortex A-72. Source: [PC Watch](https://pc.watch.impress.co.jp/video/pcw/docs/699/491/p4.pdf)
```
The Ultra96 boards have ARM Cortex A-53 cores. Compared to the A-72, it's a
2-way decode, in-order core with one 64-bit NEON SIMD unit,
as shown in {numref}`arm-core-table`.
```{list-table} ARM Core Comparison, Source: [A-53](https://www.anandtech.com/show/8718/the-samsung-galaxy-note-4-exynos-review/3), [A-72](https://www.anandtech.com/show/9184/arm-reveals-cortex-a72-architecture-details)
:header-rows: 1
:name: arm-core-table

* -  
  - Cortex A-53
  - Cortex A-72
* - ARM ISA
  - ARMv8 (32/64-bit)
  - ARMv8 (32/64-bit)
* - Decoder Width
  - 2 micro-ops
  - 3 ops (5 micro-ops)
* - Maximum Pipeline Length
  - 8
  - 16 stages
* - Integer Add
  - 2
  - 2
* - Integer Mul
  - 1
  - 1
* - Load/Store Units
  - 1
  - 1 + 1 (Dedicated L/S)
* - Branch Units
  - 1
  - 1
* - FP/NEON ALUs
  - 1x64-bit
  - 2x128-bit
* - L1 Cache
  - 8KB-64KB I\$ + 8KB-64KB D\$
  - 48KB I\$ + 32KB D\$
* - L2 Cache
  - 128KB - 2MB (Optional)
  - 512KB - 4MB
```
 
We will use the NEON Intrinsics API to program the NEON
Units in our cores. An intrinsic behaves syntactically like a function,
but the compiler translates it to a specific instruction that is inlined
in the code. In the following sections, we will guide you through
reading the NEON Programmer's guide and learning to use these APIs.

## Obtaining and Running the Code
In the previous homework, we dealt with a streaming application that
compressed a video stream, and explored how to implement coarse-grain data-level parallelism
and pipeline parallelism using `std::threads` to speedup the application. For this homework,
we will use the same application and implement coarse-grain data-level parallelism,
but using auto vectorization with the compiler and also hand-crafted NEON intrinsics.

- Login to your `a1.xlarge` instance and clone the `ese532_code`
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
            Input.bin (symlinks to hw3)
            Golden.bin (symlinks to hw3)
    ```
- There are 3 targets. You can build all of them by executing `make all`
    in the `hw4/assignment` directory. You can build separately by:
    - `make baseline` and `./baseline` to run the project with no vectorization of 
      `Filter_vertical` function.
    - `make vectorized` and `./vectorized` to run the project with `Filter_vertical` vectorized
      (you will write the vectorized code).
    - `make example` and `./example` to run the neon example.
- The `data` folder contains the input data, `Input.bin`, which has 100 frames of
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
guide is a skill by itself and we want to learn it now than later.
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
- Read (supplemental) [Optimizing C Code with Neon Intrinsics](https://developer.arm.com/architectures/instruction-sets/simd-isas/neon/neon-programmers-guide-for-armv8-a/optimizing-c-code-with-neon-intrinsics/single-page)
- Read (supplemental) [Coding for NEON](https://developer.arm.com/architectures/instruction-sets/simd-isas/neon/neon-programmers-guide-for-armv8-a/coding-for-neon/single-page)
- Read (supplemental) [Neon Intrinsics Chromium Case Study](https://developer.arm.com/architectures/instruction-sets/simd-isas/neon/neon-programmers-guide-for-armv8-a/neon-intrinsics-chromium-case-study/single-page)
- Read (supplemental) [Program Optimization through Loop Vectorization](http://www.cs.utexas.edu/~pingali/CS377P/2017sp/lectures/david-vectorization.pdf)

### More Resources:
- [NEON Quick reference guide](https://community.arm.com/developer/tools-software/oss-platforms/b/android-blog/posts/arm-neon-programming-quick-reference)
- [NEON Intrinsics Reference](https://developer.arm.com/architectures/instruction-sets/simd-isas/neon/intrinsics)

