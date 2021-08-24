# Getting Started

## Basic Model
**Hardware**: For this course, as a minimum, we need you to have a machine
that you can use for software development. A typical configuration
is Intel Core i5 + 256GB SSD + 8GB RAM. The compute resources available to you are Biglab nodes and Linux/Windows machines in Detkin/Ketterer, where
you can compile your code. After the add/drop period, we will provide
each of you with a Ultra96 board, which will be used in the subsequent assignments.

**OS**: You can use any OS---Mac/Linux/Windows, however, keep in mind that Xilinx only supports Linux and Windows (you can use [this video tutorial](https://www.youtube.com/watch?v=HaOWfmCAyCE) to run Linux on a virtualization software).
Our instructions are written for Linux and assumes you have basic proficiency in
Linux. Following are some resources if you need to brush up on Linux command line:
<!-- - [Linux Command Line Most Wanted]() -->

**Terminal**: For HW 1-4, we will use a command-line workflow. We will introduce some Xilinx
specific GUI workflow in HW 5-7. You will need to be comfortable with using
a terminal. We will be using a terminal to ssh into Biglab. Moreover, we will make use
of the terminals in Detkin/Ketterer labs
when in-person.

**Editor**: We assume that you have an editor of your choice (e.g. Vim/Emacs/VS-Code). To edit your remote source files, you can use vim or emacs directly in the remote terminal.
Or you can ssh from an editor in your local machine to edit files remotely.
For instance:
- [Remotely edit files using SSH from VS Code in Mac/Linux/Windows](https://medium.com/@christyjacob4/using-vscode-remotely-on-an-ec2-instance-7822c4032cff) 

## Logging into Biglab

You can use UPenn's Biglab as instructed [here](https://cets.seas.upenn.edu/answers/biglab.html). Note that biglab can
be busy. You can find out which machine is free by going to <https://www.seas.upenn.edu/checklab/?lab=biglab>

---
Try the [Makefile Tutorial](makefile_tutorial) in Biglab.
```{tip}
When working in the terminal, use `tmux`. Sometimes your ssh connection
to AWS may drop. When you work inside `tmux`, you can continue
back from your previous terminal session. Learn more from [here](https://linuxize.com/post/getting-started-with-tmux/).
```

---
## Transferring files between Biglab and local machine

We highly encourage you to work in git repositories when you are editing
source code. You can create a private repository in github with
the starter code we provide you, and then you can git clone your repository
in Biglab. Make sure to build a habit of frequently committing
your work.

You can upload/download your work to/from Biglab in several ways:
- You could just commit your updated code and outputs/logs into your
github repository and then access the github repository from anywhere.
- You could use `scp` as follows to transfer a single file or a folder
  between Biglab and your local machine:
    ```
    # execute from your local machine
    # to upload a file
    scp FILENAME <penn-username>@biglab.seas.upenn.edu:/home/<penn-username>/FILENAME
    
    # to upload a folder
    scp -r FOLDER <penn-username>@biglab.seas.upenn.edu:/home/<penn-username>/
    
    # to download a file
    scp <penn-username>@biglab.seas.upenn.edu:/home/<penn-username>/FILENAME FILENAME
    
    # to download a folder
    scp -r <penn-username>@biglab.seas.upenn.edu:/home/<penn-username>/FOLDER ./
    ```
- Alternatively you can use `sshfs` to mount your Biglab directory to a local folder: <https://www.digitalocean.com/community/tutorials/how-to-use-sshfs-to-mount-remote-file-systems-over-ssh>

---
You are now ready to do homeworks 1-4!