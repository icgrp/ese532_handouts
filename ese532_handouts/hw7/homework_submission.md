# Homework Submission

Your writeup should follow [the writeup guidelines](../writeup_guidelines).
Your writeup should include your answers to the questions below. Even if a certain
is just a "step", please include it in your report and leave the bullet blank
for the sake of easy grading.

<style type="text/css">
    ol { list-style-type: decimal; }
    ol ol { list-style-type: lower-alpha; }
    ol ol ol { list-style-type: lower-roman; }
    table { width: 100%; }
    td {height:50px;text-align: center;}
    tr:nth-child(even) {background-color: #f2f2f2;}
</style>

1. **Accelerating the Differentiate**
   1. Create a new Vitis HLS project and add the provided source files.
      Use a clock `xczu3eg-sbva484-1-i` in the device selection. Use a **150 MHz** clock, 
      and select the **Vitis Kernel Flow Target** for the Flow Target.
      Write a testbench that invokes the hardware implementation
      that you will write later, `Differentiate_HW`. You can use the testbench from HW5 as
      a reference. The testbench should compare the result of `Differentiate_SW` and 
      `Differentiate_HW` and exit your program with a value
      of 1 if the output is not correct.
      The input of the functions can be arbitrary values.
      Verify that your test function works. Include the
      testbench in your report.
   1. How many times does `Differentiate_SW` load each pixel on average(ignoring the edge)? (1 line)
   1. Can we use streaming in `Differentiate_SW` to handle arbitrary large frames?
      Assume that we do not change the code except for adding pragmas and changing
      the dimensions of the data. Motivate your answer. (1 line)
   1. We could store pixels that are used multiple times in a buffer that is mapped to
      a local memory. Assuming we still produce the output pixels in the same order,
      what is the smallest buffer that we can use? Motivate your answer. (3 lines)
      <!-- 1. In some iterations, we must write a value to the local memory and read multiple
         values. An array is typically mapped on a BRAM, which has only two ports.
         Consequently, we need more bandwidth than the BRAM offers. Give two ways in
         which we could resolve this issue. (4 lines) -->
   1. Implement the function `Differentiate_HW` that exploits **data reuse**. 
      It loads the input pixels only once and sequentially. 
      Verify your code using your test function. Include the test function's output and the
      `Differentiate_HW` function in your report. The test function's output could be simply
      "TEST PASSED" depending on your implementation of testbench.
   1. Pipeline the loop body of your implementation with an II of 1. What is the
      latency(in cycles) that Vitis HLS predicts? 
         <!-- You can ignore whether Vitis HLS meets
         the clock period or not for now. -->
   1. On a microprocessor, branches are generally undesirable because they introduce
      delays when they are predicted wrong. Why is this not a problem in a HW accelerator?

1. **Accelerating the Filter horizontal**
   1. Does `Filter_horizontal` offer any opportunitiy for data reuse? 
      What is the smallest buffer that we can use? (3 lines)
   1. What is the optimal order for traversing the input data (column-wise or row-wise)? 
      Assume that the input and output are stored in a BRAM. Motivate your
      answer. (3 lines)
   1. Create a function `Filter_horizontal_HW` that is a version of `Filter_horizontal_SW`
      that you modified based on the insights from the previous two questions. You
      don’t have to use the streams at this point. Include the code in your report.
   1. Pipeline the loop body of `Filter_horizontal_HW`. Write a testbench to verify 
      `Filter_horizontal_HW`.
      What is the latency(in cycles) that Vitis HLS predicts? (1 line)
      <!-- You can
      ignore whether Vitis HLS meets the clock period or not for now. (1 line) -->
         ```{note}
         Make sure you've selected the correct top function for the synthesis.
         Also check that you are not forcing another function as the top function in
         your constraints file like `directives.tcl`.
         You can create multiple Solutions in Vitis HLS for convenience.
         ```
         ```{note}
         Remember that `malloc()` is not synthesizable.
         You can have user-defined macro to seperate simulation code and synthesis code as shown in
         [HLS user guide](https://docs.xilinx.com/r/2020.2-English/ug1399-vitis-hls/Dynamic-Memory-Usage).               
         ```
         ```{hint}
         Try to achieve latency of <130000 cycles for `Filter_horizontal_HW`.
         ```

1. **Accelerating the Filter vertical**
   1. Does `Filter_vertical_HW` offer any opportunity for data reuse?
      What is the smallest buffer that we can use? (3 lines)
      <!-- Let’s continue with accelerating `Filter_vertical_HW`. 
      We could store pixels that
      are used multiple times in a buffer that is mapped to a local memory. Assuming
      we still produce the output pixels in the same order, 
      what is the smallest buffer that we can use? Motivate your answer. (3 lines) -->
   1. What is the optimal order for traversing the input data (column-wise or row-wise)
      with respect to FPGA on-chip memory usage? Assume that the input and output
      data are stored in a BRAM. Motivate your answer. (3 lines)
         ```{hint}
         We are not worrying about streaming, yet – just think about on-chip BRAM
         usage and minimization.
         ```
   1. Create a function `Filter_vertical_HW` that is a version of `Filter_vertical_SW`
      that you modified based on the insights from the previous two questions. You
      don’t have to use the streams yet. Include the code in your report.
         <!-- Include the code and your testbench's output in your report. -->
         <!-- ```{hint}
         Remember (from HW 1) what can go wrong when you write outside
         of the bounds of an array. Take care to make sure your array references are all in
         bounds.
         ``` -->
   1. Pipeline the loop body of `Filter_vertical_HW`. Write a testbench to verify 
      `Filter_vertical_HW`.
      What is the latency(in cycles) that Vitis HLS predicts? (1 line)
      <!-- You can
      ignore whether Vitis HLS meets the clock period or not for now. (1 line) -->
         ```{hint}
         Try to achieve latency of <130000 cycles for `Filter_vertical_HW`.
         ```

1. **hls::stream and on HW**
   1. Write a verification function for `Filter_HW`, similar to the one in question 1a.
      Verify that your test function works. Include the test function in your report.
   1. Create a function `Filter_HW` that connects both parts of the filter together. Store
      the intermediate results in a local array. Include `Filter_HW` in your report. Use
      the default data movers. Also include the testbench's output in your report.
      What is the expected latency(in cycles) of `Filter_HW`?
   1. We could replace the local array in `Filter_HW` with a stream. Assume that the
      stream requires no resources for buffering. What impact do you expect that will
      have on the resource consumption? Quantify your answer. (3 lines)
   1. Replace the local array with an `hls::stream` object and insert a dataflow
      pragma into `Filter_HW`. The `hls::stream` class is declared in `hls_stream.h`.
      Modify the remaining functions as necessary. 
         <!-- Note that you don’t have to inline
         Filter_horizontal_HW and Filter_vertical_HW explicitly. The tool typically
         inlines them automatically, or you can use the inline pragma to obtain the same
         result.  -->
      Include `Filter_HW` and any other significant changes in your report.
         ```{hint}
         We are concerned with streaming now, and that could merit a 
         reconsideration of how we travese the data.
         ```
   1. What is the latency of `Filter_HW` that Vitis HLS predicts? Make sure you verify your
      code. (1 line)
   1. For the last step, export your `Filter_HW` as `.xo` file and build `.xclbin` file as we
      did in HW5 and HW6. Create a host code and include test function as we did in HW5's host code.
      Include the kernel execution time from Vitis Analyzer and 
      your host code in the report.

## Deliverables
In summary, upload the following in their respective links in canvas:
  - writeup in pdf.
