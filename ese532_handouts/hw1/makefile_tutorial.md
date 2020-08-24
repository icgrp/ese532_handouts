# Makefile Tutorial
```{include} ../common/aws_caution.md
```

In this course, we are advocating that you use a command-line
workflow when you can. Of course, you can use your favorite
IDE to compile your programs, (in fact, we will be using Xilinx's IDE
later in the course). Nonetheless, learning how to work from the command
line is a great skill to have and can boost your productivity at times.

With that, following is a short tutorial on using `make` to compile your
C programs. If you know how to write a `Makefile` you can skip this section.

---
Download the {download}`source files <code/hw1_code.tar.gz>` and extract it.
On your A1 instance, you can use `wget` to download the file.

````{admonition} Quick linux commands for tar files
:class: dropdown, tip
```
# Compress
tar -cvzf <file_name.tar.gz> directory_to_compress/
# Decompress
tar -xvzf <file_name.tar.gz>
```
````

The program has the following characteristics:
- `main` function in `App.c`,
- function definitions in individual `.c` files
    and declarations in `App.h`,
- produces `Output.bin` output file.

These are typical characteristics of a C program,
and we will show how `Makefile` manages compilation and cleanup of this
program.

---
Let's start with getting the object file of `App.c`. Create a file called
`Makefile` in the extracted folder of the source code. Add the following
`rules` in the Makefile and execute the command `make` in your terminal.
```Make
App.o: App.c App.h
	gcc -c App.c -o App.o

clean:
	rm -f App.o
```
You should now see that there is a file called `App.o` in your source folder.
If you execute `make` again, it tells you ``make: `App.o' is up to date.``,
since there is nothing new to compile. You can now execute `make clean`
to remove the `App.o` file.

---
From the above example, we can learn the Makefile syntax:
```
targets : dependency1 dependency2 ...
   <tab> command
   <tab> command
   <tab> command
```
`App.o` is our target and `App.c` is the dependent file needed to produce the
object file. The gcc compile command goes after that preceded by a TAB. Whenever
there is change in the dependent files, make will recompile this `rule`.

```{caution}
The commands must start with a TAB character!
```

---
We don't have an actual binary that we can execute yet. You probably have
figured out---we need the object code of the other `.c` files and link
them together in the final binary. You could write multiple rules following
what we learned:
```Make
App.o: App.c App.h
	gcc -c App.c -o App.o

Compress.o: Compress.c App.h
	gcc -c Compress.c -o Compress.o

Differentiate.o: Differentiate.c App.h
	gcc -c Differentiate.c -o Differentiate.o

Filter.o: Filter.c App.h
	gcc -c Filter.c -o Filter.o

Scale.o: Scale.c App.h
	gcc -c Scale.c -o Scale.o

all: App.o Compress.o Differentiate.o Filter.o Scale.o
	gcc App.o Compress.o Differentiate.o Filter.o Scale.o -o App

clean:
	rm -f App.o Compress.o Differentiate.o Filter.o Scale.o App Output.bin
```
Here we are creating object files for each of the functions we have, and
then linking them together in a make target called `all`. In addition,
we updated the `clean` target to include the new `.o` files, the `App` executable and the output file. You can now execute `./App`.

---
This concludes a basic introduction to writing a Makefile. You can see the
Makefile we wrote is verbose. There are lots of tricks you can do to
"make" it concise, e.g. implicit rules, wildcards etc. We encourage you to
try those by yourselves. Following are some resources that are helpful:
- <https://makefiletutorial.com/>
- <https://www.tutorialspoint.com/makefile/index.htm>
- <https://www.gnu.org/software/make/manual/>

```{include} ../common/aws_caution.md
```
