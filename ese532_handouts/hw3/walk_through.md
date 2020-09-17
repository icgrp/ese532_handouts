# Setup and Walk-through

## Linux vs Bare-Metal
We will divide the work into threads that run on different processors.
We will be running these threads on the Linux OS and hence, all the
heavy lifting of sharing main memory global address is taken care of
by the OS. 

However, in a bare-metal system:
- we would have to map the main memory (DRAM) into the address spaces of each processors.
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
    value.  Fortunately, our ARM processors (and the Zynq we will later
    use) have a Snoop Control Unit, which bypasses data directly between processors
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

## Obtaining and Running the Code
In the previous homework, we dealt with a streaming application that
compressed only one picture. For this homework, we will use the same
application, except that it will take a video stream instead of a
single picture.

We will also use a `a1.metal` instance. Amazon AWS
instances are usually virtual machines---meaning the underlying
hardware might not necessarily reside on a single machine. The
`*.metal` instances guarantee that the user application has
full access to the hardware (all cpus and rams). Since
we want to see performance scaling as we use more cores, we have
to use the `a1.metal`. You could run the same code on other
instances, but you might not necessarily see the performance
scaling.

```{important}
The `a1.metal` instance costs $0.408 per hour. So be mindful
of that and your credit usage.
```

- Create an `a1.metal` instance following {doc}`../hw1/aws_tutorial`.
    The setup should be exactly the same, except for choosing
    `a1.metal` as your instance type.
- Login to your `a1.metal` instance and clone the `ese532_code`
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
    is in the `hw3` directory. The directory structure looks like this:
    ```
    hw3/
        Makefile
        Walkthrough.cpp
        assignment/
            common/
                App.h
                Constants.h
                Stopwatch.h
                Utilities.h
                Utilities.cpp
            baseline/
                App.cpp
                Compress.cpp
                Differentiate.cpp
                Filter.cpp
                Scale.cpp
            coarse_grain/
                ...
            pipeline_2_cores/
                ...
            pipeline_4_cores/
                ...
        data/
            Input.bin
            Golden.bin
    ```
- There are four parts to the homework. You can build all of them by executing `make all`
    in the `hw3` directory. You can build separately by:
    - `make base` and run `./base` to run the baseline project.
    - `make coarse` and run `./coarse` to run the coarse grain project.
    - `make pipeline2` and run `./pipeline2` to run the pipeline project on 2 cores.
    - `make pipeline4` and run `./pipeline4` to run the pipeline project on 4 cores.
- The `data` folder contains the input data, `Input.bin`, which has 100 frames of
    size $960$ by $540$ pixels, where each pixel is a byte. `Golden.bin` contains the
    expected output. Each program uses this file to see if there is a mismatch between
    your program's output and the expected output.
- The `assignment/common` folder has header files and helper functions used by the
    four parts.
- You will mostly be working with the code in the rest of the folders.

## Working with Threads

### Basics
Consider the following code:

```CPP
#include <iostream>
#include <thread>

void my_function(int a, int b, int&c) {
    c = a + b;
}

int main() {
    int a = 2;
    int b = 3;
    int c;
    my_function(2, 3, c);
    std::cout << "a+b=" << c << std::endl;
}
```

---
What thread do you think this code is running on?
Let's find out. Adding a little bit more to the code:
```CPP
#include <iostream>
#include <thread>

// gets the thread id of the main thread
std::thread::id main_thread_id = std::this_thread::get_id();

// checks if running on main thread using the id
void is_main_thread() {
  if ( main_thread_id == std::this_thread::get_id() )
    std::cout << "This is the main thread." << std::endl;
  else
    std::cout << "This is not the main thread." << std::endl;
}

void my_function(int a, int b, int&c) {
    c = a + b;
}

int main() {
    int a = 2;
    int b = 3;
    int c;
    my_function(2, 3, c);
    std::cout << "a+b=" << c << std::endl;
    is_main_thread();
}
```
The output is:
```TEXT
a+b=5
This is the main thread.
```

---
Can we be really sure? Let's add a little bit more:
```CPP
#include <iostream>
#include <thread>

// gets the thread id of the main thread
std::thread::id main_thread_id = std::this_thread::get_id();

// checks if running on main thread using the id
void is_main_thread() {
  if ( main_thread_id == std::this_thread::get_id() )
    std::cout << "This is the main thread." << std::endl;
  else
    std::cout << "This is not the main thread." << std::endl;
}

void my_function(int a, int b, int&c) {
    c = a + b;
}

int main() {
    int a = 2;
    int b = 3;
    int c;
    my_function(a, b, c);
    std::cout << "a+b=" << c << std::endl;
    is_main_thread();

    // create a new thread, note it's not running
    // anything yet.
    std::thread th;

    // construct the thread to run is_main_thread
    // note, as soon as you construct it, the thread
    // starts running.
    // You could create and run at the same time
    // by writing: std::thread th(is_main_thread);
    th = std::thread(is_main_thread);

    // wait for the thread to finish.
    th.join();
}
```
The output is:
```TEXT
a+b=5
This is the main thread.
This is not the main thread.
```

---
From the above, we learned:
- `#include <thread>` to use thread.
- don't construct a thread if you don't want to run
    it immediately, i.e. just declare it.
- thread starts running as soon as we construct it,
    i.e. give it a function to run.
- `th.join()` is a blocking call and waits for the
    thread to finish at the point of the program
    where it's called.
- we are running on the `main` thread by default.

We have 16 cores in `a1.metal` instance. By default,
the linux scheduler will schedule our threads into one of these
cores. What if we know what we are doing and want full
control over assigning a specific thread to run on a
specific core? Let's learn how to do that.

We have given you two functions:
```CPP
void pin_thread_to_cpu(std::thread &t, int cpu_num);
void pin_main_thread_to_cpu0();
```
They are declared and defined in `common/Utilities.h` and
`common/Utilities.cpp`. Adding to our previous example:
```CPP
#include <iostream>
#include <thread>
#include "Utilities.h"

// gets the thread id of the main thread
std::thread::id main_thread_id = std::this_thread::get_id();

// checks if running on main thread using the id
void is_main_thread() {
  if ( main_thread_id == std::this_thread::get_id() )
    std::cout << "This is the main thread." << std::endl;
  else
    std::cout << "This is not the main thread." << std::endl;
}

void my_function(int a, int b, int&c) {
    c = a + b;
}

int main() {
    // Assign main thread to cpu 0
    pin_main_thread_to_cpu0();

    int a = 2;
    int b = 3;
    int c;
    my_function(a, b, c);
    std::cout << "a+b=" << c << std::endl;
    is_main_thread();

    // create a new thread, note it's not running
    // anything yet.
    std::thread th;

    // construct the thread to run is_main_thread
    // note, as soon as you construct it, the thread
    // starts running.
    // You could create and run at the same time
    // by writing: std::thread th(is_main_thread);
    th = std::thread(is_main_thread);

    // Assign our thread to cpu 1.
    pin_thread_to_cpu(th, 1); 

    // wait for the thread to finish.
    th.join();
}
```
```{note}
The `pin_thread_to_cpu` APIs we have given you, only
works on Linux. For MacOS and Windows, we let the scheduler
choose the core. So if you are prototyping on your local
machine, keep it mind.
```

---
Last thing we need to know is how to pass function and their
arguments to threads? Modifying our example:
```CPP
#include <iostream>
#include <thread>
#include "Utilities.h"

// gets the thread id of the main thread
std::thread::id main_thread_id = std::this_thread::get_id();

// checks if running on main thread using the id
void is_main_thread() {
  if ( main_thread_id == std::this_thread::get_id() )
    std::cout << "This is the main thread." << std::endl;
  else
    std::cout << "This is not the main thread." << std::endl;
}

void my_function(int a, int b, int&c) {
    c = a + b;
    std::cout << "From thread id:"
            << std::this_thread::get_id()
            << " a+b=" << c << std::endl;
}

int main() {
    // Assign main thread to cpu 0
    pin_main_thread_to_cpu0();

    int a = 2;
    int b = 3;
    int c;
    my_function(a, b, c);
    is_main_thread();

    // create a new thread, note it's not running
    // anything yet.
    std::thread th;

    // construct the thread to run is_main_thread
    // note, as soon as you construct it, the thread
    // starts running.
    // You could create and run at the same time
    // by writing: std::thread th(is_main_thread);
    th = std::thread(is_main_thread);

    // Assign our thread to cpu 1.
    pin_thread_to_cpu(th, 1); 

    // wait for the thread to finish.
    th.join();

    std::thread th2(&my_function, a, b, std::ref(c));
    th2.join();
}
```
```TEXT
The output is:
From thread id:0x114275dc0 a+b=5
This is the main thread.
This is not the main thread.
From thread id:0x700001055000 a+b=5
```
From the above, we learned:
- the first argument to constructing a thread is a callback
    function. This callback can be a function object (as we see in `th`),
    a function pointer (as we see in `th2`) or a lambda function.
- the rest of the arguments are the inputs to the function.
    They are passed-by-value by default (i.e. `a` and `b` are copied).
    Hence, if you need to pass something by reference (as we see `int& c` in
    `my_function`), you have to wrap it in `std::ref`.

---
This concludes everything you need to know about `std::threads` to
complete this homework. You can run the full workthrough by
`make walkthrough` and `./walkthrough`.

### Coarse-grain

### Pipeline