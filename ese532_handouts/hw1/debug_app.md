# Debug an Application

1. Create a new source C file and paste the following code in it.
The code should print another message, but due to a bug, it doesn't.
    ```C
    #include <stdio.h>
    
    int len(char* s) {
      int l = 0;
      while (*s) s++;
      return l;
    }
    
    int rot13(int l) {
      if (l >= 'A' && l <= 'Z') l = (l - 'A' + 13) % 26 + 'A';
      if (l >= 'a' && l <= 'z') l = (l - 'a' + 13) % 26 + 'a';
      return l;
    }
    
    char* msg = "Jryy Qbar!!!\n";
    
    int main() {
      int i = 0;
      printf("The secret message is: ");
      while (i < len(msg)) printf("%c", rot13(msg[i++]));
    
      return 0;
    }
    ```
2. Create a Makefile and add the following targets:
      - `release`: Compiles the program normally, e.g. `gcc -Wall -o program program.c`.
      - `debug`: Compiles the program with `-g` option (which includes
        debug symbols in the binary).
    
    Build and run the program with:
      ```
      make debug
      ./program
      ```
3. You will notice that the output is not correct.  Use `gdb`
to locate the bug in the code. Specifically, we are asking you to
**not** simply perform `printf` debugging where you insert
code and recompile. Once you have the correct code, tar your sources
and Makefile and upload it to canvas.

4. In your report, describe how you found the bug, how you changed the code, and show the message that should have been displayed.

5. How does GDB know where functions and data are located in
the executable when you are debugging? (3 lines max.)

    Possibly useful:

    - run `objdump` on an executable you compiled.  Run `objdump -help` to see what options it offers. Experiment with the options to see what information
    you can get it to display.
    - {download}`gccintro <pdfs/gccintro.pdf>`

6. Below is a simple example of a linked list and a test program.
Your job is to complete `insert_in_order` function. This function
should add the new element into the linked list in ascending order.
For example, when given the values 20, 5, 10 our list
should end up sorted as “5, 10, 20“.
In this case the `head` of the list is 5 and the "tail" is 20.
In your report, put the implementation of `insert_in_order` function.
Write a Makefile to build the program. Tar your sources and Makefile
and upload it to canvas.

    ```{hint}
    The purpose of this problem is to help prepare you to write and debug C
    code with pointers. A traditional linked list contains some arbitrary data
    as well as a pointer to the next element in the list.

    What is the typical case behavior for `insert_in_order`?
    What special cases do you need to handle within `insert_in_order` function?
    ```
    ```C
    #include <stdio.h>
    #include <stdint.h>
    #include <stdlib.h>
    
    /*
    * definition of linked list node
    * the value is the element in the list
    * the pointer points to the next element in the list
    * if it exists
    */
    typedef struct node_struct {
      int8_t value;
      struct node_struct* next;
    } node_struct;
    
    // when the list is not empty, this variable will always contain
    // the element in the first position in the list (the “head” of the list)
    static node_struct* head;
    
    // This function will perform the insertion sort and maintain the linked list
    // you will need to maintain the links and properly place the new element
    void insert_in_order(node_struct* new_element) {
      // YOUR CODE HERE
    }
    
    // this function creates a new entry into the list to be inserted
    void add_element(int8_t value) {
      // create a new element in our list
      node_struct* new_element = (node_struct*)malloc(sizeof(node_struct));
      if (new_element == NULL) {
        printf("malloc failed \n");
        return;
      }
      // assign our values
      new_element->value = value;
      new_element->next = NULL;
    
      insert_in_order(new_element);
    }
    
    // prints the entirety of our list
    void print_list() {
      if (head == NULL) {
        printf("list is empty \n");
        return;
      }
    
      node_struct* element = head;
    
      while (element != NULL) {
        printf("value in list %d \n", element->value);
        element = element->next;
      }
    }
    
    int main() {
      int8_t a = 20;
      int8_t b = 5;
      int8_t c = 10;
      int8_t d = 21;
      int8_t e = 41;
      int8_t f = 2;
    
      head = NULL;
    
      add_element(a);
      add_element(b);
      add_element(c);
      add_element(d);
      add_element(e);
      add_element(f);
    
      print_list();
    
      return 0;
    }    
    ```
