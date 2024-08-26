# Homework Submission

If your turn-in file names are different from what we specify here,
your turn-in will not be graded.

<style type="text/css">
    ol { list-style-type: decimal; }
    ol ol { list-style-type: lower-alpha; }
    ol ol ol { list-style-type: lower-roman; }
</style>

## Deliverables
1. **Linked List** -- The filename has to be `linked_list.c`, 
and it should contain the linked list code in [Questions](questions).
2. **Array Sum** -- The filename has to be `array_sum.c`, 
and it should contain the array_sum code in [Questions](questions).

Please upload a `YOUR_PENN_USERNAME.tgz` that contains 
`linked_list.c` and `array_sum.c` to the diagnostic assessment assignment in canvas. 
If your Penn ID is `ept`, then it should be `ept.tgz`.
For those who do are in the waitlist, please send `YOUR_PENN_USERNAME.tgz` to
iamanvi@seas.upenn.edu or runlong@seas.upenn.edu with the email titled with "ESE5320 Diagnostic". 
TAs will send the reply once the email is received.


## Testing code
We recommend testing code on [eniac.seas.upenn.edu](eniac.seas.upenn.edu) as we will test your code on that machine so if it works on your
local machine and not on eniac.seas.upenn.edu, it will be considered incorrect. Also `getline()` function might not work on every machine but will work on eniac machine as eniac has the function as part of it's standard libraries. 

You can refer to this [link](https://cets.seas.upenn.edu/answers/vnc.html) for learning about accessing and using eniac using VNC.
 

````{admonition} Quick linux commands for tar files
:class: dropdown, tip
```
# Compress
tar -cvzf <file_name.tgz> directory_to_compress/
# Decompress
tar -xvzf <file_name.tgz>
```
````