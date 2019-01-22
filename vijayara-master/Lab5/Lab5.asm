############################################################################
# Created by:  Jayaraman, Vidya
#              vijayara
#              5 December 2018
#
# Assignment:  Lab 5: Subroutines
#              CMPE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Fall 2018
#
# Description: This program displays a strong and prompts the user to type to
#              the string in a given amount of time. If the user fails to type
#              it in within the time limit or incorrectly types it, then they 
#              fail the game. If the user prints all the strings correctly and 
#              in the time limit, then they win the game. 
#
# Notes:       This program is intended to be run from the MARS IDE. In order to store
#              the values in $a0, $v0 and $a1, I put these into temporary registers. 
#              I also used temporary values to loop through the string and the char
#              values. In order to figure out the logic for looping through each character 
#              in the string, I used the help of this pdf online, 
#              http://met.guc.edu.eg/Download.ashx?id=15577&file=Lab4_Sol_15577.pdf
############################################################################ 
main:
.text 

#--------------------------------------------------------------------
# give_type_prompt
# 
# REGISTER USAGE: 
# $a0: address of type prompt to be printed to user
# $v0: lower 32 bit of time prompt was given in milliseconds
# $t7: contains the value of $a0
#--------------------------------------------------------------------
give_type_prompt:
    addi $sp $sp  -4           # push the register values to the stack
    sw   $ra ($sp)             # store return address
    move $t7 $a0               # move address of type prompt to $t7
    la   $a0 Prompt            # print out string for "Type prompt: " 
    li   $v0 4
    syscall
    move $a0 $t7               # move $t7 to $a0 (string of type prompt)
    li   $v0 4                 # print out type prompt using syscall 4
    syscall
    move $t7 $a0               # move $a0 back to $t7, since the value of $a0 will change again
    li   $v0 30                # store time using syscall 30
    syscall
    move $v0 $a0               # move the lower 32 bits into $v0 
    move $a0 $t7
    lw   $ra ($sp)             # pop the register values from the stack
    addi $sp $sp  4
    jr   $ra                   # jump to statement whose address is in $ra

#--------------------------------------------------------------------
# check_user_input_string
# 
# REGISTER USAGE: 
# $a0: address of type prompt printed to user
# $a1: time type prompt was given to user (moved to $t4),
#      contains the user input
# $t4: stores the value of $a1
# $a2: contains amount of time allowed for response
# $v0: success or loss value (1 or 0)
# $t7: contains the type prompt printed to user (moved to $a0)
# $t8: contains the user input (moved to $a1)
# $t8: contains the user input
# $t9: contains the second time after the user input
# $t1: contains the value of $t9-$t4 (how long user took to type prompt)
#--------------------------------------------------------------------
check_user_input_string:
    addi $sp $sp  -4           # push the register values to the stack
    sw   $ra ($sp)             
    move $t4 $a1               # move $a1 (time type prompt) to $t4, since $a1 will change 
    li   $a1 100               # set $a1 to 100 for user input
    la   $a0 bits              # set $a0 to .space 100 to create space for user input 
    li   $v0 8                 # syscall 8 for user input 
    syscall
    move $t8 $a0               # move $a0 (type prompt address) to $t8, since $a0 will change
    li   $v0 30                # syscall 30 to calculate time 
    syscall
    move $t9 $a0               # move $a0, which stores lower 32 bits of time, to $t9
    sub  $t1 $t9 $t4           # subtract $t4 by $t9 to get $t1, which is time it took user to print string
    bgt  $t1 $a2 fail          # if $t1 is greater than $a2, go to fail
    ble  $t1 $a2 success       # if $t1 is less than or equal to $a2, go to success

    fail: 
         li   $v0 0            # user failed, so $v0 is set to 0
         lw   $ra ($sp)        # pop the register values from the stack
         addi $sp $sp  4
         jr   $ra              # jump to statement whose address is in $ra

    success: 
         li   $v0 1            # $v0 is set to 1 
         move $a1 $t8          # move $t8 back to $a1 for next branch
         move $a0 $t7          # move $t7 back to $a0 for next branch
         jal compare_strings   # jump and link to compare_strings
         
#--------------------------------------------------------------------
# compare_strings
#
# REGISTER USAGE: 
# $a0: address of first string to compare
# $a1: address of second string to compare
# $v0: comparison result (1 == strings the same, 0 == strings not the same)
# $t1: incremeter for string (for user input) to loop through each character
# $t2: incrementer for string (for prompt) to loop through each character
#--------------------------------------------------------------------
compare_strings:
    addi $sp $sp -4        # push the register values to the stack
    sw   $ra ($sp)
    li   $t1 0             # set $t1 to 0 for incrementor 
    li   $t2 0             # set $t2 to 0 for incrementer
    add  $t1 $zero $a0     # add 0 and $a0 to $t1 
    add  $t2 $zero $a1     # add 0 and $a1 to $t2
    
    compare:
         lbu $a0 0($t2)
         lbu $a1 0($t1)      
         
         jal compare_chars     # jump and link to compare_chars
         beqz $v0 failed       # if $v0 is 0, then go to failed
         beq  $v0 1 winner     # if $v0 is 1, then go to winner
         failed:
              li   $v0 0          # user failed, so $v0 is set to 0 
              lw   $ra ($sp)      # pop the register values from the stack
              addi $sp $sp  4
              jr   $ra            # jump to statement whose address is in $ra
     
         winner:
              li   $v0 1          # $v0 is set to 1
              lw   $ra ($sp)      # pop the register values from the stack
              addi $sp $sp  4
              jr   $ra            # jump to statement whose address is in $ra 
#--------------------------------------------------------------------
# compare_chars
#
# REGISTER USAGE: 
# $a0: first char to compare (contained in the least significant byte)
# $a1: second char to compare (contained in the least significant byte)
# $v0: comparison result (1 == chars the same, 0 == chars not the same)
# $t1: incremeter for string (for user input) to loop through each character
# $t2: incrementer for string (for prompt) to loop through each character
# $t5: compares each character from each string and stores 1 (equal) or 0 (not equal) 
#--------------------------------------------------------------------
    compare_chars:
         sw   $ra ($sp)        # store return address 
         seq  $t5 $a0 $a1      # if $a0 is equal to $a1, then $t5 is 1. else, $t5 is 0
         beqz $t5 failure      # if $t5 is 0, then the strings were not equal. $t5 goes to failure
         add  $t1 $t1 1        # increment $t1
         add  $t2 $t2 1        # increment $t2
         beqz $a0 win          # if $a0 is 0 (for null terminator), then go to win 
         beqz $a1 win          # if $a1 is 0 (for null terminator), then go to win 
         j compare

	failure:
              li   $v0 0          # user failed, so $v0 is set to 0 
              lw   $ra ($sp)      # pop the register values from the stack
              addi $sp $sp  4
              jr   $ra            # jump to statement whose address is in $ra

         win: 
              li   $v0 1          # user failed, so $v0 is set to 0 
              lw   $ra ($sp)      # pop the register values from the stack
              addi $sp $sp  4
              jr   $ra            # jump to back to jal compare_chars
             
.data
 Prompt: .asciiz "Type Prompt: "
 bits: .space 100
 

