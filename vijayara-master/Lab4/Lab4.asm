#####################################################################################################################
# Created by:  Jayaraman, Vidya
#              vijayara
#              15 November 2018
# Assignment:  Lab 4b: ASCII Decimal to 2SC
#              CMPE 012, Computer Systems and Assembly Language
# Description: This program takes two program arguments and outputs the integer value, the sum as an integer value 
#              and the 2SC binary value.  
# 
# Notes:       I used register values $t0-t9 and $s3-4. And stored program arguments and sum in $s0, $s1 and $s2.
#              I had trouble trying to figure out how to convert the integer into 2SC binary, so I looked online for 
#              information. After trying out several methods, such as using shift left logical, I decided that using 
#              rotate left was the most efficient way. I had the help of these websites: 
#              http://www.cs.ccsu.edu/~markov/ccsu_courses/254Syllabus.html and stackoverflow.com
#####################################################################################################################

# Pseudocode:
# load the two signed integer decimals: 
#   - load word of first integer from the address $a1 into $t1 
#   - load byte unsigned from the pointer, $t1, and store this into $t2 (first digit of first integer)
#   - increment the pointer, $t1,  and store this in $t3 (second digit of first integer)
#   - access the next integer from $a1, using the same method for the first integer, and store this value 
#   - increment the pointer of $a1 and store this value
#   create loops for the conditions of: one digit, two digits, or negative value: 
#        - use the null terminator (value of 0 in ASCII table) for the condition of one or two digits
#        - use the ASCII value of 45 for the condition of the negative, and then multiply the integer by -1
#   convert the ASCII values to integers 
#        - subtract 48 to each value, and multiply the second digit in the integer(if applicable) by 10
#        - output each character in the integervalue using syscall 11
# output the sum: 
#   - get the reminder after dividing it by 10 to get the first character
#   - add 48 to this and divide the entire number by 10 and use this number to get the next digits (if applicable) 
#   - create a loop for each condition and output each character backwards using syscall 11
#
# convert the numbers to binary: 
#    - convert the sum of the two integers to binary using the rotate left method and store in $s0
#   - use rol (rotate left) to rotate each bit to the left as you loop through 32 times for each bit for 32 bits 
#   - add 48 to the bits and add 1 to the incrementer until it reaches 32  
#   - store the binary value of the first integer in $s1 and the second integer in $s2
# Morse code: 
#   - the number is in binary representation, so need to convert it back to ASCII values by doing the same method
#     of outputting the sum
#   - now that the numbers are back in ASCII, create a loop that sets each character to a certain string in Morse Code
#   - for negative numbers, convert it to a positive number and put the Morse code string for each digit. Then, put the 
#     string for the negative sign in Morse code in front 

# REGISTER USAGE:
# $t0: incrementer in the loop for the Morse code 
# $t1: pointer, which increments, to access each character in the program argument
#      in the Morse code portion when storing the value of the 1st character       
# $t2:  irst character from the first  program argument 
# $t3: second character from the second program argument 
# $t4: third character from the third program argument 
# $t5: the integer value of the second program argument,
#      used in masking the bits in the Morse code portion when storing the value of the 2nd character  
# $t6: used mainly in the integer to ASCII and Morse code portion when storing the value for the 3rd character, 
#      used to store the first digit from $t2 
# $t7: the sum of $t2 and $t3, which is the integer value of the first program argument,
#      used in masking the bits, 
#      used for the division result of the third character 
# $t8: the sum of $t7 and $t3 as an integer value
# $t9: incrementer for the sum in binary 
# $s0: the sum of the two program argument (stored as a binary value)   
# $s1: the value (stored as a binary value) of the first program argument 
# $s2: the value (stored as a binary value) of the second program argument
# $s3: holds the value meant for $s2 (value is moved to $s2)
# $s4: holds the value meant for $s1 (value is moved to $s1)


.data

space:       .asciiz " "
line:        .asciiz "\n"
enter:       .asciiz "You entered the decimal numbers:\n"
sum:         .asciiz "The sum in decimal is:\n"
two:         .asciiz "\nThe sum in two's complement binary is:\n"
onestring:   .asciiz ".----"
twostring:   .asciiz "..---"
thrstring:   .asciiz "...--"
fourstring:  .asciiz "...._"
fivestring:  .asciiz "....."
sixstring:   .asciiz "-...."
sevstring:   .asciiz "--..."
eightstring: .asciiz "---.."
ninestring:  .asciiz "----."
zerostring:  .asciiz "-----"
morseneg:    .asciiz "-....-"
morse_line:  .asciiz "\nThe sum in Morse code is:\n"



.align 2
.text 
main:
li   $v0 4               # register for string           
la   $a0 enter           # load address of string
syscall                  # print out string
lw   $t1 ($a1)           # load word (4 bytes) of data into address into pointer, $t1 
lbu  $t2 ($t1)           # load byte unsigned of data from the pointer, $t1    
addi $t1  $t1 1          # increment the pointer
lbu  $t3 ($t1)           # load the byte unsigned from pointer 1
beqz $t3  null           # if $t3, or the first digit, is 0, then go to to null 
addi $t1  $t1 1          # increment $t1, the pointer by 1
lbu  $t4 ($t1)           # load byte unsigned of data from pointer, $t1
beq  $t2  45  negative   # if $t2, or the second digit, is negative, then go to negative
li   $v0  11             # use syscall 11 to print out the character
la   $a0 ($t2)           # load address of $t2 into $a0, so it can be printed out
syscall                  # print out value that  loaded into $a0 from $t2
li   $v0  11             # use syscall 11 to print out the character  
la   $a0 ($t3)           # load address of $t3 into $a0, so it can be printed out
syscall                  # print out value that gets loaded into $a0 from $t3
add  $t2  $t2 -48        # add -48 to $t2 to convert from ASCII to integer
add  $t3  $t3 -48        # add -48 to $t3 to convert from ASCII to integer
mul  $t2  $t2 10         # multiply 10 to $t2 to convert from ASCII to integer
add  $t7  $t2 $t3        # add $t2 and $t3 to $t7, to get the integer value of the first argument 
j    second              # jump to second for the second argument 

null:                    
    li   $v0  11         # use syscall 11 to print out character
    la   $a0 ($t2)       # load address of $t2 into $a0, so it can be printed out
    syscall              # print out value that  loaded into $a0 from $t2
    add  $t2  $t2 -48    # add -48 to $t2 
    move $t7  $t2        # move $t2 to $t7, which will be used when converting to binary 
    j second             # move $t2 to $t7, which will be used when converting to binary 

negative:
    beqz $t4 short       # if $t4 is equal to 0, then go to short 
    li   $v0  11         # use syscall 11 to print out the character
    la   $a0 ($t2)       # load address of $t2 to $a0, so it can be printed out
    syscall              # print out value that gets  loaded into $a0 from $t2
    li   $v0  11         # use syscall 11 to print out the character
    la   $a0 ($t3)       # load address of $t2 to $a0, so it can be printed out     
    syscall              # print out value that  loaded into $a0 from $t3
    li   $v0  11         # use syscall 11 to print out the character
    la   $a0 ($t4)       # load address of $t4 to $a0, so it can be printed out  
    syscall              # print out value that gets loaded into $a0 from $t4
    add  $t3  $t3 -48    # add -48 to $t3 to convert from ASCII to decimal
    add  $t4  $t4 -48    # add -48 to $t4 to convert from ASCII to decimal
    mul  $t3  $t3 10     # multiply 10 to $t3 to convert from ASCII to decimal
    add  $t3  $t4 $t3    # add $t4 and $t3 to $t3, so $t3 gets the integer value of the decimal
    mul  $t7  $t3 -1     # since it is a negative number, multiply $t3 by -1 and store this in $t7 
    j second             # jump to second for the second argument 

short:   
    li   $v0  11         # use syscall 11 to print out the character    
    la   $a0 ($t2)       # load address of $t2 to $a0, so it can be printed out
    syscall              # print out value that gets loaded into $a0 from $t2
    move $t2  $t5        # move the value of $t2 into $t5. $t5 will be used to convert to binary 
    li   $v0  11         # use syscall 11 to print out the character
    la   $a0 ($t3)       # load address of $t3 to $a0, so it can be printed out
    syscall              # print out value that  loaded into $a0 from $t3
    add  $t3  $t3 -48    # add -48 to $t3 
    mul  $t7  $t3 -1     # since it is negative, multiply $t3 by -1 and store into $t7. $t7 will be used for binary 
    j second             # jump to second for the second argument

second: 
    li   $v0  4          # syscall 4 to print out a string
    la   $a0  space      # print out space between the two integers 
    syscall              # print out string 
    lw   $t1  4($a1)     # load word (4 bytes) of data into address into pointer, $t1, which is shifted by 4 
    lbu  $t2  ($t1)      # load byte unsigned of data from the pointer, $t1 
    addi $t1   $t1 1     # increment the pointer, $t1
    lbu  $t3  ($t1)      # load byte unsigned of data into $t3 from the pointer, $t1
    beqz $t3       stop  # go to stop, if $t3 equals 0 
    addi $t1   $t1 1     # increment the pointer, $t1
    lbu  $t4  ($t1)      # load byte unsigned of data into $t4 from the pointer, $t1
    beq  $t2  45   negate# if $t2 equals 45, then go to negate
    li   $v0    11       # syscall 11 to print out a character        
    la   $a0  ($t2)      # load address of $t2 into $a0
    syscall              # print out value that gets loaded into $a0 from $t2      
    li   $v0  11         # syscall 11 to print out character
    la   $a0 ($t3)       # load address of $t3 into $a0
    syscall              # print out value that  loaded into $a0 from $t3  
    add  $t2  $t2  -48   # add -48 to $t2 to convert from ASCII to Integer  
    add  $t3  $t3  -48   # add -48 to $t3
    mul  $t2  $t2  10    # multiply 10 to $t2
    add  $t5  $t2  $t3   # add $t3 and $t2 to get $t5, which will be used for the binary conversion  
    li   $v0  4          # syscall 4 to print out a string
    la   $a0  line       # print out new line 
    syscall              # print out string
    li   $v0  4          # syscall 4 to print out a string
    la   $a0  line       # print out new line 
    syscall              # print out string
    j move               # jump to move

stop:
    li   $v0  11         # syscall 4 to print out a character
    la   $a0 ($t2)       # load address of $t2 to $a0, so it can be printed out
    syscall              # print out value that gets loaded into $a0 from $t2
    add  $t2  $t2  -48   # add -48 to $t2 to convert from ASCII to integer
    move $t5  $t2        # move $t2 into $t5. $t5 will be used for converting to binary     
    li   $v0  4          # syscall 4 to print out a character
    la   $a0 line        # print out new line 
    syscall              # print out string 
    li   $v0  4          # syscall 4 to print out string
    la   $a0 line        # print out new line 
    syscall              # print out string     
    j move               # jump to move

negate:
    beqz $t4 shorten     # if $t4 equals 0, then go to shorten 
    li   $v0  11         # use syscall 11 to print out the character 
    la   $a0 ($t2)       # load address of $t2 into $a0, so it can be printed out
    syscall              # print out value that gets loaded into $a0 from $t2
    move $t2  $t6        # move $t2 into $t6
    li   $v0  11         # use syscall 11 to print out the character  
    la   $a0 ($t3)       # load address of $t3 into $a0, so it can be printed out
    syscall              # print out value that gets loaded into $a0 from $t3
    li   $v0  11         # use syscall 11 to print out the character
    la   $a0 ($t4)       # load address of $t4 into $a0, so it can be printed out
    syscall              # print out value that gets loaded into $a0 from $t4
    add  $t3  $t3  -48   # add -48 to $t3 to convert from ascii to integer
    add  $t4  $t4  -48   # add -48 to $t4 to convert from ascii to integer 
    mul  $t3  $t3  10    # multiply $t3 by 10  to convert to integer 
    add  $t5  $t3  $t4   # add $t3 and $t4 and put value into $t5
    mul  $t5  $t5  -1    # multiply $t5 by -1. $t5 is used for converting to binary
    li   $v0  4          # sycall 4 to print out string
    la   $a0  line       # load address of string into $a0
    syscall              # print out new line 
    li   $v0 4           # sycall 4 to print out string
    la   $a0 line        # load address of string into $a0
    syscall              # print out new line 
    j move               # jump to move 

shorten: 
    li   $v0  11         # use syscall 11 to print out the character
    la   $a0 ($t2)       # load address of $t2 into $a0, so it can be printed out
    syscall              # print out character 
    move $t2  $t6        # move $t2 into $t6
    li   $v0  11         # syscall 11 to print out character
    la   $a0 ($t3)       # load address of $t3 into $a0 to print out 
    syscall              # print out value that gets loaded into $a0 from $t3 
    add  $t3  $t3  -48   # add -48 to $t3
    move $t5  $t3        # move $t3 into $t5
    mul  $t5  $t5  -1    # multiply $t5 by -1
    li   $v0  4          # syscall 4 to print out string 
    la   $a0 line        # load address of string into $a0
    syscall              # print out new line
    li   $v0  4          # syscall 4 to print out string 
    la   $a0 line        # load address of string into $a0
    syscall              # print out new line
    j move               # jump to move 

move:    
    li   $t1  0          # set $t1 to 0 to create incrementer

Binary:                  # this Binary loop only converts the first integer to 2SC. the sum in 2SC is calculated later
    rol  $t7 $t7 1       # rotate bits to the left, 1 bit at a time
    andi $s1 $t7 1       # mask the bits in $t7 and 1, using bitwise operator, AND. and set this value in $s1
    add  $s1 $s1 48      # add 48 to $s1 to convert it, since the  ASCII value of 0 is equal to 48
    add  $t1 $t1 1       # increment $t1 
    bne  $t1 32  Binary  # if $t1 does not equal 32, then loop back to Binary
    li   $t2 0           # set $t2 to 0 to convert the next digit to binary 

Second:                  # this Second loop only converts the second integer to 2SC. the sum in 2SC is calculated later
    rol  $t5 $t5 1       # rotate bits to the left, 1 bit at a time   
    andi $s2 $t5 1       # mask the bits in $t5 and 1, using bitwise operator, AND. and set this value in $s2
    add  $s2 $s2 48      # add 48 to $s1 to convert it, since the  ASCII value of 0 is equal to 48
    add  $t2 $t2 1       # increment $t2
    bne  $t2 32  Second  # if $t1 does not equal 32, then loop back to Binary
    
add: 
    li   $v0 4           # sycall 4 to print out a string 
    la   $a0 sum         # load the address of the string into $a0
    syscall              # print out the string
    add  $t8 $t5 $t7     # add the values in $t5 and $t7 to $t8 
    move $s3 $t5         # move the value from $t5 to $s3, since $t5 needs to be used for another loop
    move $s4 $t7         # move the value from $t7 to $s4, since $t7 needs to be used for another loop             
    li   $t9 0           # set $t9 to 0
    blt  $t8 0   minus   # if $t8 is less than 0, then go to minus

loop:  
    rem  $t1 $t8 10      # perform this operation : $t8 % 10 = $t1
    li   $t2 48          # set $t2 to 48 to add to ASCII   
    li   $t0 1           # set $t0 to 1
    add  $t1 $t2 $t1     # add $t2 and $t1 and store this value in $t1 
    div  $t3 $t8 10      # divide $t8 by 10 and store this value in $t3
    beqz $t3 one         # if $t3 equals 0, then go to one
    rem  $t5 $t3 10      # perform this operation : $t3 % 10 = $t5
    add  $t0 $t0 1       # increment $t0
    add  $t5 $t2 $t5     # add $t2 and $t5 and store this value in $t5
    div  $t4 $t3 10      # divide $t3 by 10 and store this value $t4
    beqz $t4 twice       # if $t4 is equal to 0, then go to twice 
    rem  $t6 $t4 10      # perform this operation : $t4 % 10 = $t6
    add  $t0 $t0 1       # increment $t0 
    add  $t6 $t2 $t6     # add $t6 and $t2 and store this value in $t6 
    div  $t7 $t4 10      # divide $t4 by 10 and store this value in $t7 
    beqz $t7 three       # if $t7 is equal to 0, then go to three

one:                      
    li   $v0  11         # use syscall 11 to print out character 
    la   $a0 ($t1)       # load address of $t1 into $a0 to print it out 
    syscall              # print out character
    li   $t0  0          # set $t0 for incrementer
    j    set_sum         # jump to set_sum 

twice:        
    li   $v0  11         # syscall 11
    la   $a0 ($t5)       # load address 
    syscall              # print out character         
    li   $v0  11         # move $t1 into $a0
    la   $a0 ($t1)       # load address into from $t1 to $a0      
    syscall              # print out character
    li   $t0  1          # set $t0 to 1 for incrementer 
    j    set_sum         # jump to set_sum
 
 three:         
    li   $v0  11         # syscall 11
    la   $a0 ($t6)       # load address from $t6 to $a0
    syscall              # print out character   
    li   $v0  11         # syscall 11
    la   $a0 ($t5)       # load address from $t5
    syscall              # print out character         
    li   $v0  11         # syscall 11
    la   $a0 ($t1)       # load address from $t1     
    syscall              # print out character
    li   $t0  3          # set $t0 to 3 for incrementor 
    j    set_sum         # jump to set_sum 
    
minus:
    mul  $t8  $t8 -1     # multiply by -1 to make positive
    li   $t9  45         # set $t9 to 45 for negative sign 
    li   $v0  11         # syscall 11
    la   $a0 ($t9)       # load address of $t9              
    syscall              # print out character
    li   $t9  0          # set $t9 to 0, since $t9 needs to be used later
    rem  $t1  $t8 10     # perform this operation : $t1 % 10 = $t1
    li   $t2  48         # set $t2 to 48 to add to ASCII values
    li   $t0  1          # set $t0 to 1 for incrementor 
    add  $t1  $t2 $t1    # add $t2 and $t2 and store value in $t1
    div  $t3  $t8 10     # divide $t8 by 10 and store in $t3
    beqz $t3 single      # if $t3 is 0, then go to single 
    rem  $t5  $t3 10     # perform this operation : $t3 % 10 = $t5
    add  $t0  $t0 1      # increment $t0 
    add  $t5  $t2 $t5    # add $t2 and $t5 and store in $t5
    div  $t4  $t3 10     # divide $t3 by 10 and store in $t4
    beqz $t4 double      # if $t4 equals 0, then go to double 
    rem  $t6  $t4 10     # perform this operation : $t4 % 10 = $t6
    add  $t0  $t0 1      # increment $t0
    add  $t6  $t2 $t6    # add $t6 and $t2 and store in $t6
    div  $t7  $t4 10     # divide $t4 by 10 and store in $t7 
    beqz $t7 triple      # if $t7 equals 0, then go to triple 
 
single:
    li   $v0  11         # syscall 11 
    la   $a0 ($t1)       # load address of $t1
    syscall              # print out character
    li   $t0  0          # set $t0 to 0 for incrementer
    j    set_sum         # jump to set_sum 

double:
    li   $v0  11         # syscall 11
    la   $a0 ($t5)       # load address of $t5
    syscall              # print out character
    li   $v0  11         # syscall 11
    la   $a0 ($t1)       # load address of $t1
    syscall              # print out character
    li   $t0  1          # set $t0 to 1
    j    set_sum         # jump to set_sum
 
triple:  
    li   $v0  11         # syscall 11
    la   $a0 ($t6)       # load address of $t6
    syscall              # print out character
    li   $v0  11         # syscall 11
    la   $a0 ($t5)       # load address of $t5
    syscall              # print out character           
    li   $v0  11         # syscall 11
    la   $a0 ($t1)       # load address of $t1   
    syscall              # print character
    li   $t0  3          # set $t0 to 3  
    j    set_sum         # jump to set_sum

set_sum:
    li   $v0  4          # syscall 4
    la   $a0  line       # load address of string into $a0
    syscall              # print out character
    add  $t8  $s3 $s4    # add $s3 and $s4 to $t8
    li   $t9  0          # set $t9 to 0
    li   $v0  4          # syscall 4
    la   $a0  two        # load address of string into $a0
    syscall              # print string

third:
    rol  $t8  $t8 1      # rotate the bits to the left, 1 bit at at time  
    andi $s0  $t8 1      # mask the bits in $t8 and 1, using bitwise operator, AND. and set this value in $s0
    add  $s0  $s0 48     # add 48 to $s0 to convert it, since the ASCII value 0f 0 is 48 
    move $a0  $s0        # move $s0 to $a0 to print it out
    li   $v0  11         # syscall 11
    la   $a0 ($s0)       # load address of $s0 into $a0 to print out each bit 
    syscall              # print out each bit
    addi $t9  $t9 1      # increment $t9
    bne  $t9  32  third  # if $t9 does not equal 32, then loop back to third 
    li   $v0  4          # syscall 4
    la   $a0 line        # load address of string to print it out
    syscall              # print out string
    move $s2  $s3        # move $s4 to $s2, so $s2 has the value of the second program argument as an integer
    move $s1  $s4        # move $s3 to $s1, so $s1 has the value of the first program argument as an integer 
    move $s0  $t8        # move $t8 to $s0, so $s0 has the value of the sum as an integer
    j loop_again         # jump to loop_again
   
loop_again:
    li   $v0  4          # syscall 4
    la   $a0 morse_line  # load address of string into $a0 to print it out
    syscall              # print string
    blt  $t8  0 minus_t  # if $t8 is less than 0, then go to minus_t
    rem  $t1  $t8 10     # perform this operation : $t8 % 10 = $t1
    li   $t2  48         # set $t2 to 48 for ASCII conversion
    li   $t0  1          # set $t0 to 1
    add  $t1  $t2 $t1    # add $t2 and $t1 and put value in $t1
    div  $t3  $t8 10     # divide $t8 by 10 and put value in $t3
    beqz $t3 one_again   # if $t3 equals 0, then go to one_again
    rem  $t5  $t3 10     # perform this operation : $t3 % 10 = $t5
    add  $t0  $t0 1      # increment $t0 
    add  $t5  $t2 $t5    # add $t2 and $t5 and put it in $t5 
    div  $t4  $t3 10     # divide $t3 by 10 and put value in $t4
    beqz $t4 twice_again # if $t4 equals 0, then go to twice_again
    rem  $t6  $t4 10     # perform this operation : $t4 % 10 = $t6
    add  $t0  $t0 1      # increment $t0
    add  $t6  $t2 $t6    # add $t6 and $t2 and put value in $t2
    div  $t7  $t4 10     # divide $t4 by 10 and put value in $t7
    beqz $t7 three_again # if $t7 is equal to 0, then go to three_again
 
one_again:
    li   $t0 0           # set $t0 to 0
    j    morse           # jump to morse

twice_again:
    li   $t0 1           # set $t0 to 1
    j    morsetwo        # jump to morsetwo
 
three_again:  
    li   $t0 3           # set $t0 to 3
    j    morsethree      # jump to morsethree

minus_t:
    mul  $t8 $t8 -1      # multiply $t8 by -1
    li   $t9 45          # set $t9 to 45
    rem  $t1 $t8 10      # perform this operation : $t8 % 10 = $t1
    li   $t2 48          # set $t2 to 48
    li   $t0 1           # set $t0 to 1
    add  $t1 $t2 $t1     # add $t2 and $t1 and set this value to $t1
    div  $t3 $t8 10      # divide $t8 by 10 and set this value to $t3
    beqz $t3 single_t    # if $t3 is 0, then go to single_t
    rem  $t5 $t3 10      # perform this operation : $t3 % 10 = $t5
    add  $t0 $t0 1       # increment $t0
    add  $t5 $t2 $t5     # add $t2 and $t5 and set this value to $t5
    div  $t4 $t3 10      # divide $t3 by 10 and put this value in $t4
    beqz $t4 double_t    # if $t4 is 0, then go to double_t
    rem  $t6 $t4 10      # perform this operation : $4 % 10 = $t6
    add  $t0 $t0 1       # increment $t0
    add  $t6 $t2 $t6     # add $t2 and $t6 and put this value in $t6
    div  $t7 $t4 10      # divide $t4 by 10 and put this value in $t7
    beqz $t7 triple_t    # if $t7 is equal to 0, then go to triple_t
 
single_t:
    li   $t0 0           # set $t0 to 0
    j    morse_negate    # jump to morse_negate

double_t:
    li   $t0 1           # set $t0 to 1
    j    morsetwo_neg    # jump to morsetwo_neg
 
 triple_t:  
    li   $t0 3           # set $t0 to 3
    j    morsethree_neg  # jump to morsethree_neg
     
morse_negate:
    li   $v0 4           # syscall 4
    la   $a0 morseneg    # load address of string into $a0 to print out
    syscall              # print string
    li   $v0 4           # syscall 4
    la   $a0 space       # load address of string into $a0 to print out
    syscall              # print space

morse: 
    addi $t0 $t0 1       # increment $t0
    beq  $t1 48 zero     # if $t1 is 48 (0 in ASCII), then go to zero
    beq  $t1 49 first    # if $t1 is 49 (1 in ASCII), then go to one
    beq  $t1 50 sec      # if $t1 is 50 (2 in ASCII), then go to sec
    beq  $t1 51 thr      # if $t1 is 51 (3 in ASCII), then go to thr
    beq  $t1 52 four     # if $t1 is 52 (4 in ASCII), then go to four
    beq  $t1 53 five     # if $t1 is 53 (5 in ASCII), then go to five
    beq  $t1 54 six      # if $t1 is 54 (6 in ASCII), then go to six
    beq  $t1 55 sev      # if $t1 is 55 (7 in ASCII), then go to sev
    beq  $t1 56 eight    # if $t1 is 48 (8 in ASCII), then go to eight
    beq  $t1 57 nine     # if $t1 is 48 (9 in ASCII), then go to nine
 
morsetwo_neg:
    li   $v0 4           # syscall 4
    la   $a0 morseneg    # load address of string into $a0
    syscall              # print out string
    li   $v0 4           # syscall 4
    la   $a0 space       # load address of string into $a0
    syscall              # print string
    
morsetwo:
    addi $t0 $t0 1       # increment $t0
    beq  $t5 48 zero     # if $t5 is 48 (0 in ASCII), then go to zero
    beq  $t5 49 first    # if $t5 is 49 (1 in ASCII), then go to first 
    beq  $t5 50 sec      # if $t5 is 50 (2 in ASCII), then go to sec
    beq  $t5 51 thr      # if $t5 is 51 (3 in ASCII), then go to thr
    beq  $t5 52 four     # if $t5 is 52 (4 in ASCII), then go to four
    beq  $t5 53 five     # if $t5 is 53 (5 in ASCII), then go to five
    beq  $t5 54 six      # if $t5 is 54 (6 in ASCII), then go to six
    beq  $t5 55 sev      # if $t5 is 55 (7 in ASCII), then go to sev
    beq  $t5 56 eight    # if $t5 is 56 (8 in ASCII), then go to eight
    beq  $t5 57 nine     # if $t5 is 57 (9 in ASCII), then go to nine
    
morsethree_neg:
    li   $v0 4           # syscall 4
    la   $a0 morsethree_neg 
    syscall              # print out value that gets loaded into $a0 from morsethree_neg
    li   $v0 4           # syscall 4
    la   $a0 space       # load address of string
    syscall              # print space
      
morsethree:
    addi $t0 $t0 1       # increment $t0
    beq  $t6 48 zero     # if $t6 is 48 (0 in ASCII), then go to zero
    beq  $t6 49 first    # if $t6 is 49 (1 in ASCII), then go to first 
    beq  $t6 50 sec      # if $t6 is 50 (2 in ASCII), then go to sec
    beq  $t6 51 thr      # if $t6 is 51 (3 in ASCII), then go to thr
    beq  $t6 52 four     # if $t6 is 52 (4 in ASCII), then go to four
    beq  $t6 53 five     # if $t6 is 53 (5 in ASCII), then go to five
    beq  $t6 54 six      # if $t6 is 54 (6 in ASCII), then go to six
    beq  $t6 55 sev      # if $t6 is 55 (7 in ASCII), then go to sev
    beq  $t6 56 eight    # if $t6 is 56 (8 in ASCII), then go to eight
    beq  $t6  57 nine    # if $t5 is 57 (9 in ASCII), then go to nine
  
first: 
    li   $v0 4           # syscall 4
    la   $a0 onestring   # load address of onestring
    syscall              # print out string
    j condition          # jump to condition
sec: 
    li   $v0 4           # syscall 4
    la   $a0 twostring   # load address of twostring
    syscall              # print out string
    j condition          # jump to condition
thr: 
    li   $v0 4           # syscall 4
    la   $a0 thrstring   # load address of thrstring
    syscall              # print string
    j condition          # jump to condition
four: 
    li   $v0 4           # syscall 4
    la   $a0 fourstring  # load address of fourstring
    syscall              # print string
    j condition          # jump to condition
five: 
    li   $v0 4           # syscall 4
    la   $a0 fivestring  # load address of fivestring
    syscall              # print string
    j condition          # jumpt to condition
six: 
    li   $v0 4           # syscall 4
    la   $a0 sixstring   # load address of sixstring
    syscall              # print string
    j condition          # jump to condition
sev: 
    li   $v0 4           # syscall 4
    la   $a0 sevstring   # load address of sevstring
    syscall              # print string
    j condition          # jumpt to condition
eight: 
    li   $v0 4           # syscall 4
    la   $a0 eightstring # load address of eightstring
    syscall              # print string
    j condition          # jump to condition
nine: 
    li   $v0 4           # syscall 4
    la   $a0 ninestring  # load address of ninestring
    syscall              # print string
    j condition          # jump to condition
zero: 
    li   $v0 4           # syscall 4
    la   $a0 zerostring  # load address of zerostring
    syscall              # print string
    j condition          # jump to condition             
        
condition:
    beq  $t0 1 exit      # if $t0 is 1, then go to exit
    beq  $t0 2 spacing   # if $t0 is 2, then go to spacing
    beq  $t0 3 exit      # if $t0 is 3, then go to exit
    beq  $t0 4 spaces    # if $t0 is 4, then go to spaces
    beq  $t0 5 spacing   # if $t0 is 5, then go to spacing
    beq  $t0 6 exit      # if $t0 is 6, then go to exit

spacing: 
    li   $v0 4           # syscall 4
    la   $a0 space       # load address of string 
    syscall              # print string
    j morse              # jump to morse
    
spaces: 
    li   $v0 4           # syscall 4
    la   $a0 space       # load address of string
    syscall              # print string  
    j morsetwo           # jump to morsetwo
exit:
    li   $v0 4           # syscall 4
    la   $a0 line        # load address of string in line
    syscall              # print new line
    li   $v0 10          #system call to exit
    syscall

