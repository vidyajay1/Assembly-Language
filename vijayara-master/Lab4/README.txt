------------------------
Lab 4: ASCII Decimal to 2SC
CMPE 012 Fall 2018
Jayaraman, Vidya 
vijayara
-------------------------
What was your approach to converting each decimal number to two’s complement
form?
I first converted it to integer. In order to do this, I added 48 to each digit 
in the integer. And if there was more than one digit, I multiplied the first digit 
by 10. With a negative number, I did the same method, but multiplied the entire 
number by -1 at the end. To convert it to binary, I rotated each bit to the left 
32 times. I used a bit mask with the bitwise operator, AND. This allowed me to 
manipulate the bits so that it outputted the correct number in binary. 

What did you learn in this lab?
I learned how to access program arguments in MIPs, how to convert from ASCII to 
decimal in MIPS, manipulate the bits in binary numbers in different ways, and 
how to convert an integer value back to ASCII in MIPS by using modulo and division
of 10. 

Did you encounter any issues? Were there parts of this lab you found enjoyable?
I encountered issues with converting the integer back to ASCII, since I had the 
integer in my register value. But I couldn't use syscall 1. This made it difficult 
for me to print out the ASCII string. But in the end, I managed to do it. I also had 
trouble understanding how to manipulate the bits in MIPS. I found it enjoyable when I 
was able to understand how to store and convert the program arguments to integers. 

How would you redesign this lab to make it better?
I would make the instructions more clear by saying that the integer values of the
user input are stored in $s1 and $s2. And the sum of these values are stored as an 
integer value in $s0. I didn't realize that the integer values were stored as binary 
values. I first stored these values into $0, $s1 and $s2 as the bits that got outputted. 
I would also provide some instruction on how to manipulate the bit values in MIPS and how it 
got stored. I was really confused about this and I had to research some of this. 
