# Questions

1. Below is a simple example of a linked list and a test program.
This function
should add the new element into the linked list in ascending order.
For example, when given the values 20, 5, 10 our list
should end up sorted as “5, 10, 20“.
In this case the `head` of the list is 5 and the "tail" is 20.
Copy the code below in `linked_list.c` and 
complete `insert_in_order` function. 

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

2. Please complete the main function to use other helper functions
to read `len` numbers from `filename`.
It should then compute the prefix array results and print them out.
Include declaration and creation of all variables and data structures needed.
Copy the code below in `arraysum.c`. 

    ```C
    #include <stdio.h>
    #include <stdlib.h>

    void prefix(int *in, int *out, int len) {
        int sum=0;
        for (int i=0;i<len;i++) {
            sum+=in[i];
            out[i]=sum;
        }
    }

    void read_ins(int *in, int len, FILE *fp) {
        char * line = NULL;
        ssize_t read;
        size_t line_len =0;
        int i=0;

        if (fp == NULL)   return;

        while (((read = getline(&line, &line_len, fp)) != -1) && (i<len)) {
            in[i]=atoi(line);
            i++;
        }

        fclose(fp);
        if (line) free(line);
    }

    void write_outs(int *out, int len) {
        for (int i=0;i<len;i++)
            printf("%d\n",out[i]);
    }

    int main(int argc, char **argv) {
        if (argc<2) {
            fprintf(stderr,"Usage: arraysum len filename\n");
            exit(1);
        }
        
        // YOUR CODE HERE

        return(0);
    }
    ```
    When you have `test.txt` as below,
    ```
    1
    2
    3
    4
    5
    6
    7
    8
    9
    10
    ```
    the output of `./a.out 5 test.txt` should be
    ```
    (base) $./a.out 5 test.txt 
    1
    3
    6
    10
    15
    ```