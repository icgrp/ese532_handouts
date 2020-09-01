# Profiling Tutorial
Profiling is the first step in making your programs faster.
In this tutorial, we will learn how to measure latency and
find the bottleneck in your program.

## Get the Source Code
1. Login to your A1 instance and download the {download}`source files <code/hw2_profiling_tutorial.tar.gz>` and extract it.
On your A1 instance, you can use `wget <source files link>` to download the file.
You can get the link by right-clicking on {download}`source files <code/hw2_profiling_tutorial.tar.gz>`
and "Copy Link Address".

    ````{admonition} Quick linux commands for tar files
    :class: dropdown, tip
    ```
    # Compress
    tar -cvzf <file_name.tar.gz> directory_to_compress/
    # Decompress
    tar -xvzf <file_name.tar.gz>
    ```
    ````
2. `cd` into the extracted directory. Build and run using:
    ```
    make all
    ./rendering_sw
    ```

## Measuring Latency
You can measure latency in many different ways---instrumenting the code vs sampling-based profiling,
using system timer vs using hardware timer etc. (review these
[slides](https://www.cs.fsu.edu/~engelen/courses/HPC/Performance.pdf) and learn about clock sources [here](http://btorpey.github.io/blog/2014/02/18/clock-sources-in-linux/)). However, the
end goal is the same; which is to answer where is the bottleneck?

We will show you how you can use the system timer to
measure latency in seconds. We'll then demonstrate how you
can use sampling-based profiling tools to measure latency
without modifying your source code.

(profiling/instrumentation)=
### Instrumentation-based Profiling with Timers
In linux, you can use `gettimeofday()` from `<sys/time.h>`.
For example:
```C
struct timeval start_time, end_time;
gettimeofday(&start_time, 0);
// code to measure
gettimeofday(&end_time, 0);
long long elapsed = (end_time.tv_sec - start_time.tv_sec) * 1000000LL + end_time.tv_usec - start_time.tv_usec;   
printf("elapsed time: %lld us\n", elapsed);
```
Combining with a little bit of C++ syntax, we can create a class called
`stopwatch` as follows:
```CPP
#include <sys/time.h>

class stopwatch
{
  public:
    uint64_t total_time, calls;
    struct timeval start_time, end_time;
    stopwatch() : total_time(0), calls(0) {};

    inline void reset() {
      total_time = 0;
      calls = 0;
    }

    inline void start() {
      gettimeofday(&start_time, 0);
      calls++;
    };

    inline void stop() {
      gettimeofday(&end_time, 0);
      long long elapsed = (end_time.tv_sec - start_time.tv_sec) * 1000000LL + end_time.tv_usec - start_time.tv_usec;
      total_time += elapsed;
    };

    // return latency in us
    inline double avg_latency() {
      return ((double)total_time / (double)calls);
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

std::cout << "Average latency of projection is: " << time_projection.avg_latency() << "us." << std::endl;
std::cout << "Average latency of rasterization1 is: " << time_rasterization1.avg_latency() << "us." << std::endl;
std::cout << "Average latency of rasterization2 is: " << time_rasterization2.avg_latency() << "us." << std::endl;
std::cout << "Average latency of zculling is: " << time_zculling.avg_latency() << "us." << std::endl;
std::cout << "Average latency of coloringFB is: " << time_coloringFB.avg_latency() << "us." << std::endl;
std::cout << "Average latency of the loop is: " << total_time.avg_latency() << "us." << std::endl;
```
Recompile the program `make all` and run. You should see results similar to the following:
```
3D Rendering Application
Average latency of projection is: 0.0485589us.
Average latency of rasterization1 is: 0.0488722us.
Average latency of rasterization2 is: 0.544486us.
Average latency of zculling is: 0.115288us.
Average latency of coloringFB is: 0.0802005us.
Average latency of the loop is: 1.10589us.
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
### Sampling-based Profiling with Perf
We can use sampling-based profiling using `perf` and figure out bottlenecks
in our program. `perf` samples events in a program at a given frequency
and then reports the percentage of time a section takes (read these [slides](https://s3.amazonaws.com/connect.linaro.org/yvr18/presentations/yvr18-416.pdf) to learn the basics of perf).

To run perf on your program, compile your program with the `-g` and `-pg`
flags (`make profile` in the supplied `Makefile`).
Then, run perf as follows (`make perf` in the supplied `Makefile`):
```
sudo perf record -g -F 10099 -o perf.data ./rendering_sw
```
You can then view the report using `sudo perf report` (`make perf_report` in the supplied `Makefile`) as shown below and press enter on
a hierarchy to view the percentages (you can go as deep as assembly code and
view percentages for assembly as well!).
```{image} images/perf.png
```

From the report, we can see that it is consistent with our 
results from {ref}`profiling/instrumentation`.

```{caution}
When profiling your applications with perf,
compile **without** optimizations. With optimizations, the original call
graph of application is modified and hence doesn't show up
in the perf samples.
```
```{tip}
You can measure latency as number of cycles.
Instead of `-e task-clock` in `perf`, use `-e 'cycles'`.
This uses the Performance Monitor Unit (PMU) cycle
counter of the ARM. However, on Amazon it only
works on `a1.metal`/`a1.4xlarge` instances (because of
the way cpus are virtualized).
```

---
Now that we have shown you two approaches for measuring latency,
a natural question is when is one better than the other?
`perf` is good for finding the function that has the highest latency.
However, since it is sampling based, it may not show you a function that took
very little time. With instrumentation, you are able to get
latencies for all the functions.

