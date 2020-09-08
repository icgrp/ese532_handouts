# Profiling Tutorial
Profiling is the first step in making your programs faster.
In this tutorial, we will learn how to measure latency and
find the bottleneck in your program.

## Get the Source Code
1. Clone the `ese532_code` repository as shown in {doc}`importing`.
2. Build and run using:
    ```
    cd ese532_code/hw2/tutorial
    make all
    ./rendering
    ```

## Measuring Latency
You can measure latency in many different ways---instrumenting the code vs sampling-based profiling,
using system timer vs using hardware timer etc. (review these
[slides](https://www.cs.fsu.edu/~engelen/courses/HPC/Performance.pdf) and learn about clock sources [here](http://btorpey.github.io/blog/2014/02/18/clock-sources-in-linux/)). However, the
end goal is the same; which is to answer where is the bottleneck?

In this tutorial, we will show you how you can use the system timer to
measure latency in seconds for parts of your program. We'll then demonstrate how you can use linux `perf` tool to get ***performance counter*** statistics of your program.

(profiling/instrumentation)=
### Instrumentation-based Profiling with Timers
In C++, you can use `std::chrono::high_resolution_clock::now()` from `<chrono>`.
For example:
```CPP
std::chrono::time_point<std::chrono::high_resolution_clock> start_time, end_time;
start_time = std::chrono::high_resolution_clock::now();
// code to measure
end_time = std::chrono::high_resolution_clock::now();
auto elapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(end_time-start_time).count();   
std::cout << "elapsed time: " << elapsed << " ns." << std::endl;
```
Note that we need nanoseconds resolution. Combining with a little bit of C++ syntax, we can create a class called
`stopwatch` as follows:
```CPP
#include <cstdint>
#include <chrono>

class stopwatch
{
  public:
    double total_time, calls;
    std::chrono::time_point<std::chrono::high_resolution_clock> start_time, end_time;
    stopwatch() : total_time(0), calls(0) {};

    inline void reset() {
      total_time = 0;
      calls = 0;
    }

    inline void start() {
      start_time = std::chrono::high_resolution_clock::now();
      calls++;
    };

    inline void stop() {
      end_time = std::chrono::high_resolution_clock::now();
      auto elapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(end_time-start_time).count();
      total_time += static_cast<double>(elapsed);
    };

    // return latency in ns
    inline double latency() {
      return total_time;
    };

    // return latency in ns
    inline double avg_latency() {
      return (total_time / calls);
    };
};
```
You can then use this class in `src/sw/rendering_sw.cpp` as follows:
```CPP
#include <iostream>

// processing NUM_3D_TRI 3D triangles
stopwatch time_projection;
stopwatch time_rasterization1;
stopwatch time_rasterization2;
stopwatch time_zculling;
stopwatch time_coloringFB;
stopwatch total_time;

// processing NUM_3D_TRI 3D triangles
TRIANGLES: for (int i = 0; i < NUM_3D_TRI; i ++ )
{
  total_time.start();

  // five stages for processing each 3D triangle
  time_projection.start();
  projection( triangle_3ds[i], &triangle_2ds, angle );
  time_projection.stop();

  time_rasterization1.start();
  bool flag = rasterization1(triangle_2ds, max_min, max_index);
  time_rasterization1.stop();

  time_rasterization2.start();
  int size_fragment = rasterization2( flag, max_min, max_index, triangle_2ds, fragment );
  time_rasterization2.stop();

  time_zculling.start();
  int size_pixels = zculling( i, fragment, size_fragment, pixels);
  time_zculling.stop();

  time_coloringFB.start();
  coloringFB ( i, size_pixels, pixels, output);
  time_coloringFB.stop();

  total_time.stop();
}
std::cout << "Total latency of projection is: " << time_projection.latency() << " ns." << std::endl;
std::cout << "Total latency of rasterization1 is: " << time_rasterization1.latency() << " ns." << std::endl;
std::cout << "Total latency of rasterization2 is: " << time_rasterization2.latency() << " ns." << std::endl;
std::cout << "Total latency of zculling is: " << time_zculling.latency() << " ns." << std::endl;
std::cout << "Total latency of coloringFB is: " << time_coloringFB.latency() << " ns." << std::endl;
std::cout << "Total time taken by the loop is: " << total_time.latency() << " ns." << std::endl;
std::cout << "---------------------------------------------------------------" << std::endl;
std::cout << "Average latency of projection per loop iteration is: " << time_projection.avg_latency() << " ns." << std::endl;
std::cout << "Average latency of rasterization1 per loop iteration is: " << time_rasterization1.avg_latency() << " ns." << std::endl;
std::cout << "Average latency of rasterization2 per loop iteration is: " << time_rasterization2.avg_latency() << " ns." << std::endl;
std::cout << "Average latency of zculling per loop iteration is: " << time_zculling.avg_latency() << " ns." << std::endl;
std::cout << "Average latency of coloringFB per loop iteration is: " << time_coloringFB.avg_latency() << " ns." << std::endl;
std::cout << "Average latency of each loop iteration is: " << total_time.avg_latency() << " ns." << std::endl;

```
Recompile the program using `make all` and run `./rendering`. You should see results similar to the following:
```
[ec2-user@ip-172-31-40-51 hw2_profiling_tutorial]$ ./rendering
3D Rendering Application
Total latency of projection is: 154140 ns.
Total latency of rasterization1 is: 191497 ns.
Total latency of rasterization2 is: 1.5305e+06 ns.
Total latency of zculling is: 364093 ns.
Total latency of coloringFB is: 263400 ns.
Total time taken by the loop is: 3.36578e+06 ns.
---------------------------------------------------------------
Average latency of projection per loop iteration is: 48.2895 ns.
Average latency of rasterization1 per loop iteration is: 59.9928 ns.
Average latency of rasterization2 per loop iteration is: 479.48 ns.
Average latency of zculling per loop iteration is: 114.064 ns.
Average latency of coloringFB per loop iteration is: 82.5188 ns.
Average latency of each loop iteration is: 1054.44 ns.
Writing output...
Check output.txt for a bunny!
```
From the results, we can see `rasterization2` has the
highest latency and is a good candidate for
optimization.

For our assignments, the `stopwatch` class we built
here should suffice. If you would like to try out
something fancier, check out <https://github.com/google/benchmark>!

(profiling/perf)=
### Performance Counter Statistics using Perf
ARM has a dedicated Performance Monitor Unit (PMU) that can give you the number of cycles
your program takes to run (read more about PMU [here](https://easyperf.net/blog/2018/06/01/PMU-counters-and-profiling-basics)).
We can use `perf` to get the performance counter statistics of your program (read these [slides](https://s3.amazonaws.com/connect.linaro.org/yvr18/presentations/yvr18-416.pdf) to learn more about of perf).

Run perf as follows (`make perf` in the supplied `Makefile`):
```
sudo perf stat ./rendering
```
You should see the following output:
```
[ec2-user@ip-172-31-40-51 hw2_profiling_tutorial]$ make perf
g++ -Wall -g -O3 -I/src/sw/ -I/src/host/ -o rendering ./src/host/3d_rendering_host.cpp ./src/host/utils.cpp ./src/host/check_result.cpp ./src/sw/rendering_sw.cpp
./src/sw/rendering_sw.cpp: In function ‘int rasterization2(bool, bit8*, int*, Triangle_2D, CandidatePixel*)’:
./src/sw/rendering_sw.cpp:216:3: warning: label ‘RAST2’ defined but not used [-Wunused-label]
   RAST2: for ( int k = 0; k < max_index[0]; k ++ )
   ^~~~~
./src/sw/rendering_sw.cpp: In function ‘int zculling(int, CandidatePixel*, int, Pixel*)’:
./src/sw/rendering_sw.cpp:242:5: warning: label ‘ZCULLING_INIT_ROW’ defined but not used [-Wunused-label]
     ZCULLING_INIT_ROW: for ( int i = 0; i < MAX_X; i ++ )
     ^~~~~~~~~~~~~~~~~
./src/sw/rendering_sw.cpp:244:7: warning: label ‘ZCULLING_INIT_COL’ defined but not used [-Wunused-label]
       ZCULLING_INIT_COL: for ( int j = 0; j < MAX_Y; j ++ )
       ^~~~~~~~~~~~~~~~~
./src/sw/rendering_sw.cpp:255:3: warning: label ‘ZCULLING’ defined but not used [-Wunused-label]
   ZCULLING: for ( int n = 0; n < size; n ++ )
   ^~~~~~~~
./src/sw/rendering_sw.cpp: In function ‘void coloringFB(int, int, Pixel*, bit8 (*)[256])’:
./src/sw/rendering_sw.cpp:277:5: warning: label ‘COLORING_FB_INIT_ROW’ defined but not used [-Wunused-label]
     COLORING_FB_INIT_ROW: for ( int i = 0; i < MAX_X; i ++ )
     ^~~~~~~~~~~~~~~~~~~~
./src/sw/rendering_sw.cpp:279:7: warning: label ‘COLORING_FB_INIT_COL’ defined but not used [-Wunused-label]
       COLORING_FB_INIT_COL: for ( int j = 0; j < MAX_Y; j ++ )
       ^~~~~~~~~~~~~~~~~~~~
./src/sw/rendering_sw.cpp:285:3: warning: label ‘COLORING_FB’ defined but not used [-Wunused-label]
   COLORING_FB: for ( int i = 0; i < size_pixels; i ++ )
   ^~~~~~~~~~~
./src/sw/rendering_sw.cpp: In function ‘void rendering_sw(Triangle_3D*, bit8 (*)[256])’:
./src/sw/rendering_sw.cpp:319:3: warning: label ‘TRIANGLES’ defined but not used [-Wunused-label]
   TRIANGLES: for (int i = 0; i < NUM_3D_TRI; i ++ )
   ^~~~~~~~~
Executable rendering compiled!
Running perf stat...
3D Rendering Application
Total latency of projection is: 158544 ns.
Total latency of rasterization1 is: 197736 ns.
Total latency of rasterization2 is: 1.52008e+06 ns.
Total latency of zculling is: 368150 ns.
Total latency of coloringFB is: 269160 ns.
Total time taken by the loop is: 3.38372e+06 ns.
---------------------------------------------------------------
Average latency of projection per loop iteration is: 49.6692 ns.
Average latency of rasterization1 per loop iteration is: 61.9474 ns.
Average latency of rasterization2 per loop iteration is: 476.216 ns.
Average latency of zculling per loop iteration is: 115.335 ns.
Average latency of coloringFB per loop iteration is: 84.3233 ns.
Average latency of each loop iteration is: 1060.06 ns.
Writing output...
Check output.txt for a bunny!

 Performance counter stats for './rendering':

          9.345612      task-clock (msec)         #    0.950 CPUs utilized
                 0      context-switches          #    0.000 K/sec
                 0      cpu-migrations            #    0.000 K/sec
               137      page-faults               #    0.015 M/sec
        21,298,909      cycles                    #    2.279 GHz
        28,153,358      instructions              #    1.32  insn per cycle
   <not supported>      branches
            66,468      branch-misses

       0.009834370 seconds time elapsed
```
From the above output, we can see that our program took $21,298,909$ cycles at $2.279$ GHz. We can use these numbers to find the 
run time of our program, which is $21298909/2.279$
$\approx$ $9.345$ milli seconds which agrees with the $9.345$ msec
reported by perf too. Note that perf used the "task-clock" (system timer)
to report the latency in seconds, and used the PMU counter to report
the latency in cycles. The PMU counter runs at the same frequency as
the cpu, which is $2.279$ GHz, whereas the system timer runs at a
much lower frequency (in the MHz range).
 
---
Now that we have shown you two approaches for measuring latency, a natural question is when do you use either of these methods?
- Use {ref}`profiling/instrumentation` when you want to find individual
latencies of your functions.
- Use {ref}`profiling/perf` when you just want to know the total latency (either
in seconds or cycles) of your program.

However, the above answer is too simple. The application we showed you
is slow enough for `std::chrono` to measure accurately. When the resolution of your system timer is not fine-grained
enough, or your function is too fast, you should measure the function for a longer period of time (see the spin loop section from [here](https://www.cs.fsu.edu/~engelen/courses/HPC/Performance.pdf)). Alternatively,
that's where the PMU offers more accuracy. Since the PMU runs at the same
frequency as the CPU, it can measure any function. However, you will
have to isolate your functions and create separate programs to use
the PMU through `perf`. There is not "stopwatch" like user API for the PMU
counter.

For our application above, we saw that the total runtime reported by task-clock and PMU counter doesn't differ. Hence, it doesn't matter which approach you use in this case. If you want to get the latencies
of individual function in ***cycles*** instead, you can just use your
measured time with the clock frequency to figure out the cycles.
Alternatively you could get the fraction of time spent by your function
and use the total number of cycles from `perf stat`.