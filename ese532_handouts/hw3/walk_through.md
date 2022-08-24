# Setup and Walk-through
## Obtaining and Running the Code
In the previous homework, we dealt with a streaming application that
compressed only one picture. For this homework, we will use the same
application, except that it will take a video stream instead of a
single picture. You can run [Walk-through](walk_through) on the host computer.
**But note that you need to run the code for [homework submission](homework_submission) on the Ultra96.**

<!-- We will use machines in Biglab/Detkin/Ketterer. Biglab nodes are
shared by multiple users---meaning your processes are not the only
ones running on a core. Hence, you might not see full performance scaling
as you use more cores. Detkin machines should give you dedicated access
to the cores. -->

- Clone the `ese532_code`
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
        assignment/
            Makefile
            Walkthrough.cpp
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
            cdc_parallel/
                ...
        data/
            Input.bin
            Golden.bin
    ```
- There are four parts to the homework. You can build all of them by executing `make all`
    in the `hw3/assignment` directory. You can build separately by:
    - `make base` and run `./base` to run the baseline project.
    - `make coarse` and run `./coarse` to run the coarse-grain project.
    - `make pipeline2` and run `./pipeline2` to run the pipeline project on 2 cores.
    - `make cdc` and run `./cdc` to run the data-parallel CDC you will implement on 4 cores.
- The `data` folder contains the input data, `Input.bin`, which has 100 frames of
    size $960$ by $540$ pixels, where each pixel is a byte. `Golden.bin` contains the
    expected output. `base`, `coarse` and `pipeline2` uses this file to see if there is a mismatch between
    your program's output and the expected output. `cdc` uses `prince.txt`
    from the `data` folder as an input. `golden.txt` has the expected output
    cdc will produce.
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

By default,
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

    // Assign our thread to core 1.
    pin_thread_to_cpu(th, 2);  // threads 0 and 1 on most machines (2 hyperthreads per core) are the same core

    // wait for the thread to finish.
    th.join();
}
```
````{note}
- The `pin_thread_to_cpu` APIs we have given you, only
works on Linux. For MacOS and Windows, we let the scheduler
choose the core. So if you are prototyping on your local
machine, keep it in mind.
- Also note how in {numref}`topo` there are 2 hyper-threads
per core. The `cpu_num` argument in `pin_thread_to_cpu` refers to
the index number of the hyper-thread. Hence, for instance, if
you want to run a thread on core 0 and one on core 1,
you should pin the threads to either 0 and 2, or 1 and 3.
This will ensure that each thread is run on a separate core.
Otherwise, multiple threads on the same core will share resources
and may affect performance.
To see the CPU topology in your PC,
do `lstopo`.
````
<!-- 
To see the CPU topology in Biglab,
use the following commands:
  ```
  export PATH=/home1/e/ese532/software/usr/bin/:$PATH
  lstopo
  ```
-->
```{figure} images/topo_pc.png
---
name: topo
---
An 8-core machine with 2 hyper-threads
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

    // Assign our thread to core 1.
    pin_thread_to_cpu(th, 2); 

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
complete this homework. You can run the full walk-through by
`make walkthrough` and `./walkthrough`.

### Coarse-grain
The coarse-grain part of the homework shows you how you can process
a data parallel function with threads. We show how you change the
`Scale` function to process it with two threads:
```CPP
void Scale_coarse(const unsigned char *Input, unsigned char *Output, int Y_Start_Idx, int Y_End_Idx)
{
  for (int Y = Y_Start_Idx; Y < Y_End_Idx; Y += 2)
  {
    for (int X = 0; X < INPUT_WIDTH_SCALE; X += 2)
    {
      Output[(Y / 2) * INPUT_WIDTH_SCALE / 2 + (X / 2)] = Input[Y * INPUT_WIDTH_SCALE + X];
    }
  }
}
```
From the code, you can see that we added two additional arguments at the function
signature, which is then used in the for loop. This helps us realize
the data parallel behavior of the function and let multiple
threads work on it:
```CPP
...
for (int Frame = 0; Frame < FRAMES; Frame++)
  {
    std::vector<std::thread> ths;
    ths.push_back(std::thread(&Scale_coarse, Input_data + Frame * FRAME_SIZE, Temp_data[0], 0, INPUT_HEIGHT_SCALE / 2));
    ths.push_back(std::thread(&Scale_coarse, Input_data + Frame * FRAME_SIZE, Temp_data[0], INPUT_HEIGHT_SCALE / 2, INPUT_HEIGHT_SCALE));

    pin_thread_to_cpu(ths[0], 0);
    pin_thread_to_cpu(ths[1], 2);

    for (auto &th : ths)
    {
      th.join();
    }
    ...
```
As we can see from the code above, two threads are launched in parallel. One
processes indices `[0, 270)` and the other processes `[270, 540)`.
If you wanted to use three threads, you can split the indices as `[0,180)`,
`[180, 360)` and `[360, 540)` and invoke another thread and pin it to cpu 3.

### Pipeline
The pipeline part of the homework shows you how you can orchestrate
the launching of threads and achieve pipeline parallelism. Start reading
from the main function, where we launch a process on cpu 0:
```CPP
for (int Frame = 0; Frame < FRAMES + 2; Frame++)
  {
    core_0_process(std::ref(Size), Frame, Input_data, Temp_data, Output_data);
  }
```
Following a top-down approach, look into `core_0_process` function:
```CPP
void core_0_process(int &Size,
                    int Frame,
                    unsigned char *Input_data,
                    unsigned char **Temp_data,
                    unsigned char *Output_data)
{
  static unsigned char temp_core_0[FRAME_SIZE];
  static unsigned char *Input_data_core_0 = temp_core_0;
  std::thread core_1_thread;
  if (Frame < FRAMES + 1)
  {
    // current core (core 0) spins up process on core 1
    core_1_thread = std::thread(&core_1_process,
                                Frame,
                                Input_data,
                                Temp_data);
    pin_thread_to_cpu(core_1_thread, 2);
  }

  // core 0 does its job
  if (Frame > 1)
  {
    Filter_vertical(Input_data_core_0, Temp_data[2]);
    Differentiate(Temp_data[2], Temp_data[3]);
    Size = Compress(Temp_data[3], Output_data);
  }
  // waits for core 1 to finish
  if (Frame < FRAMES + 1)
  {
    core_1_thread.join();
  }

  unsigned char *Temp = Temp_data[1];
  Temp_data[1] = Input_data_core_0;
  Input_data_core_0 = Temp;
}
```
Pay special attention to the guards---`if (Frame < FRAMES + 1)` and
`if (Frame > 1)`, and figure out if a code executes or not or
is waiting on another core to finish. Keep following the code
like this and you will realize how we mapped the functions
for the pipelining on 2 cores part of the
homework. In summary:
- for pipelining on 2 cores, we map `Scale` and parts of
    `Filter` on core 1 and then the rest of `Filter`, `Differentiate`
    and `Compress` on core 0.
- if you wanted to map on 3 cores, you could map `Scale` on core 2, `Filter_horizontal`
    on core 1, and `Filter_vertical`, `Differentiate` and `Compress`
    on core 0.

You will also realize how the data flows and how the pipeline
fills and drains. Lastly, pay special attention to the `static` in
`static unsigned char ` of the processes in the pipeline code.
Remember that `static` keyword in a block scope changes the
***storage class*** of a variable, i.e. the lifetime of the variable
is until the program stops executing. This is especially important
since being able to use old data while new data is being produced
is key to achieving the pipeline parallelism.

### Monitoring Processes using `htop`
`htop` tool in Linux lets you monitor the processes running on your system.
If you type `htop` in the terminal, you'll
see a screen like {numref}`htop-init`:
<!-- Since there can be multiple users in Biglab at a given time, you would
want to monitor `htop` and see if the CPUs are looking idle; in which case
you should do some profiling of you program and get some clean results.
You can also use `htop` to see where your threads are pinned to.

Once logged into Biglab, type `htop` in the terminal, and you'll
see a screen like {numref}`htop-init`: -->
```{figure} images/htop-init.png
---
name: htop-init
---
Initial `htop` window
```
This gives you an idea if the CPU are being utilized and if the machine
is being used heavily.

Let's configure some of the view items. Press **F2** (**Fn+F2** in laptops) to enter the **Setup** screen. From the setup screen, select **Display Options** and check **Tree view**. This will let us see the threads we spawn. Also uncheck **Count CPUs from 1 instead of 0**, so that
we are referring to the same indexing in this walk-through. Now from the
same setup screen, select **Columns** and select **PROCESSOR** from the
**Available Columns**. This is will let us see the CPU ID of the thread.'
Press **Esc** to get back to the main `htop` window.

While keeping `htop` open in one terminal, open a different terminal
to your Biglab node and compile the following code by pasting it your `Walkthrough.cpp`
and do `make walkthrough && ./walkthrough`.
```CPP
#include <iostream>
#include <thread>
#include "Utilities.h"
#include <unistd.h>
#include <array>

void my_function(int a, int b) {
    int c = a + b;
    std::cout << "From thread id:"
            << std::this_thread::get_id()
            << " a+b=" << c << std::endl;
    sleep(60);
}

int main() {
    // pin main thread to cpu 0
    pin_main_thread_to_cpu0();

    int a = 2;
    int b = 3;
    

    // create an array of threads
    std::array<std::thread, 4> threads;
    
    // spawn some threads and pin them to specific cpus
    for(int i = 0; i < 4; i++) {
      threads[i] = std::thread(&my_function, a, b);
      pin_thread_to_cpu(threads[i], 2*i+1); 
    }

    // wait for threads to finish
    for(std::thread& th : threads) {
      th.join();
    }
}
```
The program waits for a minute. During this time, go back to
the terminal with `htop`. Press **F4** (**Fn+F4** in laptops)
and type `walkthrough` to filter our process. You'll see the
following:
```{figure} images/htop-threads.png
---
name: htop-threads
---
`htop` showing threads and cpu assignment
```
You can see that we are able to see our threads and how they
are mapped to different CPU IDs---1, 3, 5, 7---indicating that
we want to use separate cores instead of hyper-threads in the
same core.

````{note}
When you run the code on the Ultra96, you cannot use the fancy user interface of `htop`.
You can you the built-in `top` instead. You can also monitor the core usage in `top` by
pressing `1`.

  ```{figure} images/top.png
  ---
  name: top
  ---
  `top` on Ultra96 showing core usage
  ```


````

