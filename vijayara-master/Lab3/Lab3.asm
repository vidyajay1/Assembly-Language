#####################################################################################################
# Created by:  Jayaraman, Vidya
#              vijayara
#              8 November 2018
#
# Assignment:  Lab 3: Looping in MIPS
#              CMPE012, Computer Systems and Assembly Language
#              UC Santa Cruz, Fall 2018
#
# Description: This program will prompt the user for a number, iterate through a set of integers,
#              and print on of the four outputs: Flux, Bunny, Flux Bunny, or an integer, $t1
#
# Notes:       This program is intended to be run from the MARS IDE. For my sources, I used textbook  
#	       about MIPs that was part of the required readings, as well as this website, 
#              http://logos.cs.uic.edu/366/notes/mips%20quick%20tutorial.htm, which is why some of my 
#              comments are similar.
#####################################################################################################   
# REGISTER USAGE:
# $t0: user input
# $t1: loop counter
# $t2: $t2 = $t1 % 7 
# $t3: $t3 = $t1 % 5 
# $v0: stores function argument of a string or integer 
# $a0: loads address of the string or integer
# $zero: holds the constant, 0
	
.data 
prompt: .asciiz "Please input a positive integer: "
Flux: .asciiz "Flux "
String: .asciiz "Bunny"
space: .asciiz "\n"

.text
main:			
li   $v0 4     	        # load appropriate system call into register $v0 for a string
la   $a0 prompt	        # prompt for the user to enter integer
syscall                 # ouput this prompt to screen 
addi $v0 $zero 5        # add user input immediately  
syscall                 # call operating system to perform this operation
move $t0 $v0            # move integer to be printed into $t0 : $t0 = $v0, $t0 is the user input
li   $t1 0              # initialize $t1 to 0, $t1 is the incrementer 
	
mod_five:                                                                
      rem  $t3 $t1 5          # perform this operation : $t1 % 5 = $t3
      bnez $t3 mod_seven      # if $t3 != 0, branch to Loop_Seven 
      li   $v0 4              # load appropriate system call into register $v0 for a string
      la   $a0 Flux           # address of the string to print
      syscall                 # print the string Flux
	
mod_seven:                                                 
      rem  $t2 $t1 7          # perform this operation : $t1 % 7 = $t2
      beqz $t2 bunny          # if $t2 != 0, branch to bunny
      bnez $t3 print_i        # if $t3 != 0, branch to print_i
      j    else               # otherwise, jump to else
	
bunny:                                            
      li   $v0 4              # load appropriate system call into register $v0 for a string
      la   $a0 String         # address of string to print  
      syscall                 # print the string in String
		
else:                                            
      la   $a0 space          # address of new line to print
      li   $v0 4              # load appropriate system call into register $v0 for a string
      syscall                 # print out the new line 
      beq  $t1 $t0 end        # if $t1 = $t0, then branch to End                 
      addi $t1 $t1 1          # increment $t1
      ble  $t1 $t0 mod_five   # if $t1 is less than $t0, then go back to the top of the loop
		
print_i:                      # else block to print i ($t1)   
      move $a0 $t1            # move integer to be printed into $a0 : $a0 = $t1
      li   $v0 1              # load appropriate system call into register $v0 for integer        
      syscall                 # print the integer 
      la   $a0 space          # adddress of new line to print 
      li   $v0 4              # load appropriate system call into register $v0 for a new line (string)
      syscall                 # print the new line
      beq  $t1 $t0 end        # if $t1 = $t0, then branch to end 
      addi $t1 $t1 1          # increment $t1
      ble  $t1 $t0 mod_five   # if $t1 is less than $t0, then go back to beginning of loop (mod_five) 
		
end:                      
      li $v0 10               # system call code for exit = 10
      syscall                 # call operating sys and end program 
	



