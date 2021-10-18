# Setup and Walk-through

<style type="text/css">
    table { width: 100%; }
    th { background-color: #4CAF50;color: white;height:50px;text-align: center; }
    td {height:50px;text-align: center;}
    tr:nth-child(even) {background-color: #f2f2f2;}
</style>

## Obtaining and Running the Code
In this homework, we will compare the matrix multiplication from previous HWs and
the matrix multiplication implemented with systolic array.
We will analyze the trade offs of the two design points.

Pull in the latest changes using:
```
cd ese532_code/
git pull origin master
```
The code you will use for this section
is in the `hw7` directory. The directory structure looks like this:
```
hw7/
    sourceMe.sh
    mmult.cpp
    mmult.h
    sys_ary_mmult.cpp
```
- `sourceMe.sh` will help you to source Xilinx tools
- `mmult.cpp` is the matrix multiplication function from HW6
  of which element is `int` type
- `sys_ary_mmult.cpp` is the matrix multiplication implemented
  with systolic array. It is slightly modified from 
  [Xilinx Accel Example](https://github.com/Xilinx/Vitis_Accel_Examples/tree/master/cpp_kernels/systolic_array).

## Review: Burst Transfers and Task-Level Parallelism
### Burst Transfer
In HW6, when you partition the matrix multiplication into
Load-Compute-Store Pattern
(example [here](https://github.com/Xilinx/Vitis-In-Depth-Tutorial/blob/master/Runtime_and_System_Optimization/Design_Tutorials/01-host-code-opt/reference-files/srcKernel/pass.cpp)), you enabled
**burst transfer**.

The first access to the global memory is expensive while the
subsequent contiguous accesses are not. Therefore,
in `Load` block, we copy a chunk of input to the local memory to compute,
and similarly in `Store` block, we copy a chunk of output to global memory.
Burst read/write is done with the pipelined loop in `Load` and `Store` blocks.

The example of burst read is shown below.
```
readA:
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
#pragma HLS PIPELINE
    	  localA[i][j] = A[i * N + j];
      }
    }
```
<!-- 
In this HW, we will analyze how the processor
core communicates with an accelerator. We tell you some
specific things to experiment with, but you should do some reading from:
- This HW is highly related to [Xilinx Runtime (XRT) and Vitis System Optimization Tutorials](https://xilinx.github.io/Vitis-Tutorials/2020-2/docs/Runtime_and_System_Optimization/README.html)
- Chapter 6, 7, 19, 20 of [UG1393](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1393-vitis-application-acceleration.pdf)
- [Programming for Vitis HLS](https://www.xilinx.com/html_docs/xilinx2020_2/vitis_doc/vitis_hls_coding_styles.html)
 -->


### Task-Level Parallelism
[This example](https://github.com/Xilinx/Vitis-In-Depth-Tutorial/blob/master/Runtime_and_System_Optimization/Design_Tutorials/01-host-code-opt/reference-files/srcKernel/pass.cpp)
from previous HW6 also enables task-level parallelism utilizing `hls::stream`.
[This adder example](https://github.com/Xilinx/Vitis_Accel_Examples/blob/master/cpp_kernels/dataflow_stream/src/adder.cpp)
is also useful.
Key recommendations on `hls::stream` from 
[Xilinx User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1393-vitis-application-acceleration.pdf)
are:
- Data should be transferred in the forward direction only
  avoiding feedback whenever possible.
- Each connection should have a single producer and a 
  single consumer.
- Only the load and store functions should access 
  the primary interface of the kernel

## Using Systolic Array to Matrix Multiply
- In this HW, we will use systolic array to implement matrix multiplication.
    ```{figure} images/sys_ary_0.png
    ---
    height: 150px
    name: sys_ary_0
    ---
    Matrix Multiplication
    ```
    ```{figure} images/sys_ary_1.png
    ---
    height: 350px
    name: sys_ary_1
    ---
    Systolic Array, t=0
    ```
    ```{figure} images/sys_ary_2.png
    ---
    height: 298px
    name: sys_ary_2
    ---
    Systolic Array, t=1
    ```
    ```{figure} images/sys_ary_3.png
    ---
    height: 263px
    name: sys_ary_3
    ---
    Systolic Array, t=2
    ```
    ```{figure} images/sys_ary_4.png
    ---
    height: 220px
    name: sys_ary_4
    ---
    Systolic Array, t=3
    ```
    ```{figure} images/sys_ary_5.png
    ---
    name: sys_ary_5
    ---
    Systolic Array, matrix multiplication done
    ```


## Reference
- <https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1393-vitis-application-acceleration.pdf>
