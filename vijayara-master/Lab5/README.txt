------------------------
Lab 5: Subroutines
CMPE 012 Fall 2018

Jayaraman, Vidya
vijayara
-------------------------
What was your design approach?
I just started off trying to create all the subroutines with the logic that needed to be implemented. But then I realized that I needed the variables to match the Lab5Test.asm. I needed to match certain variables from my Lab5.asm to the Lab5Test.asm. 

What did you learn in this lab?
I learned how to implement stacks, since I had to push and pop values from the register for each branch, especially in the compare_strings branch. 

Did you encounter any issues? Were there parts of this lab you found enjoyable?
I encountered issues with making sure certain variables held the correct values. Memory addresses and return values, such as $a0, $a1, and $v0 were constantly changing. So I had to move the values in these into and out of register values. And sometimes I lost track of my register values or address values. I liked when my program suddenly worked when I had the correct values in the correct registers and memory addresses. 

How would you redesign this lab to make it better?
I would redesign the lab, so values would have to be stored in certain register values that were specified (for example,  user input had to be stored in $t1, rather than just $a0 or $a1). This would allow me to keep track of my values better and not get as mixed up with my register values. But the way the lab was structured with each subroutine and with values in address memories and return values did make sense. 