# Code Setup
## Obtaining and Running the Code
In the previous homework, we dealt with a streaming application that
compressed only one picture. For this homework, we will use the same
application, except that it will take a video stream instead of a
single picture. You can run the [walk-through](threads_walkthrough) on the host computer.
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
