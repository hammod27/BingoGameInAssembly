# =================================
# Description: This is a bingo game. Diagonal not implemented.
# =================================
# Your annotated registers
# ========== Data segment
.data
   welcome: .asciiz   "Welcome to bingo.\n\n\n"
   display: .asciiz   "Enter your choice (Q to quit): "
   marked:  .asciiz   "\nPosition marked.\n\n"
   invalid: .asciiz   "\nInvalid position.\n\n"
   already: .asciiz   "\nPosition already marked.\n\n"
   win:     .asciiz   "\n !! BINGO !! \n"
   lose:    .asciiz   "\n  No Bingo  "
   board:   .byte     ' ', ' ', 'B', ' ', 'I', ' ', 'N', ' ', 'G', ' ', 'O', '\n'
            .byte     '1', ' ', '_', ' ', '_', ' ', '_', ' ', '_', ' ', '_', '\n'
            .byte     '2', ' ', '_', ' ', '_', ' ', '_', ' ', '_', ' ', '_', '\n'
            .byte     '3', ' ', '_', ' ', '_', ' ', '_', ' ', '_', ' ', '_', '\n'
            .byte     '4', ' ', '_', ' ', '_', ' ', '_', ' ', '_', ' ', '_', '\n'
            .byte     '5', ' ', '_', ' ', '_', ' ', '_', ' ', '_', ' ', '_', '\n'

# ========== Code segment
.text
.globl main
main:
   la $a0, welcome
   li $v0, 4
   syscall			# welcome message

   jal displayBoard

   sw $t0, -4($sp)
   sw $t1, -8($sp)
   sw $t2, -12($sp)		#temp to stack

   jal readInput

   lw $t0, 4($sp)
   lw $t1, 8($sp)
   lw $t2, 12($sp)		#temp from stack
   
   move $t0, $a0		# input letter to $t0 (col)
   move $t1, $a1		# input number to $t1 (row)

   looptop:
      li $t2, 81		# Q
      beq $t0, $t2, loopexit	#looptop
   loopbody:
      move $a0, $t0
      move $a1, $t1
      la $a2, board
      
      sw $t0, -4($sp)
      sw $t1, -8($sp)
      sw $t2, -12($sp)		#store all temp to stack

      jal markPosition

      lw $t0, 4($sp)
      lw $t1, 8($sp)
      lw $t2, 12($sp)		#load all temp from stack

      jal displayBoard

      sw $t0, -4($sp)
      sw $t1, -8($sp)
      sw $t2, -12($sp)		#temp to stack

      jal readInput

      lw $t0, 4($sp)
      lw $t1, 8($sp)
      lw $t2, 12($sp)		#temp from stack

      move $t0, $a0
      move $t1, $a1

      j looptop

   loopexit:
      li $t4, 0			#count
      li $t8, 0			#count 2
      li $t9, 55		#count 3
      li $t5, 4			#loop end if
      li $t6, 70		#other loop end if
      la $a2, board
      move $t2, $a2		#$t2 = board
      li $t0, 'X'		#$t0 = x
      addi $t3, $t2, 14		#$t3 = board + 14 (0,0)
      lb $t1, 0($t3)		#$t1 = what's in $t2 
      beq $t1, $t0, rowCol

      looping:
         addi $t3, $t3, 12	#add 12 to board (move down)
         lb $t1, 0($t3)
         beq $t1, $t0, rowCol
         sub $t7, $t3, $t2
         bgt $t7, $t6, looping2	#this should branch when $t3 > 62
         j looping

      looping2:
         addi $t3, $t2, 14
      looping3:
         addi $t3, $t3, 2	#add 2 to board (move right)
         lb $t1, 0($t3)
         beq $t1, $t0, check2
         sub $t7, $t3, $t2
         bgt $t7, $t6, loser
         addi $t9, $9, 1
         #bgt, $t9, $t6, loser
         j looping3

      rowCol:
         addi $t4, $t4, 1
         addi $t3, $t3, 2	#add 2 to the location of board (move over)
         lb $t1, 0($t3)	
         bne $t1, $t0, check
         beq $t4, $t5, winner
         j rowCol

      check:
         sub $t3, $t3, 2	#subtract the 2 from rowCol
      check2:
         li $t9, 55		#reset count3
         addi $t4, $t4, 1	#count
         addi $t3, $t3, 12	#add 12 to location (move down)
         lb $t1, 0($t3)
         bne $t1, $t0, check3	#where to branch to?
         beq $t4, $t5, winner
         j check2
      check3:
         li $t4, 1
         addi $t8, $t8, 1
         beq $t8, $t5, looping3
         j looping

      winner:
         la $a0, win
         li $v0, 4
         syscall
         j EXIT
      loser:
         la $a0, lose
         li $v0, 4
         syscall
   

   j EXIT

displayBoard:
   la $a0, board
   li $v0, 4
   syscall			#display board

   la $a0, display
   li $v0, 4
   syscall			#display input message
   
   j $ra

readInput:
   li $v0, 12
   syscall			# read letter (ascii)

   move $a0, $v0		# move letter to $a0

   li $v0, 5
   syscall			# read number

   move $a1, $v0		# move number to $a1

   li $t0, 66			# B
   li $t1, 73			# I
   li $t2, 78			# N
   li $t3, 71			# G
   li $t4, 79			# O

   beq $a0, $t0, ifB
   beq $a0, $t1, ifI
   beq $a0, $t2, ifN
   beq $a0, $t3, ifG
   beq $a0, $t4, ifO
   j endIf
   ifB:
      la $a0, 0
      j endIf
   ifI:
      la $a0, 1
      j endIf
   ifN:
      la $a0, 2
      j endIf
   ifG:
      la $a0, 3
      j endIf
   ifO:
      la $a0, 4
   endIf:

   sub $a1, $a1, 1

   j $ra

markPosition:
   addi $sp, $sp, -4
   sw $ra, 0($sp)

   move $t0, $a0		#col
   move $t1, $a1		#row
   move $t2, $a2		#array
   li $t9, 'X'			#X for marking

   li $t3, 14			#numCol
   li $t4, 2			#constant for formula
   li $t5, 1			#constant for formula

   add $t1, $t1, $t5		#$t1 = row + 1
   mult $t3, $t1
   mflo $t6			#$t6 = 14(row + 1)
   mult $t1, $t4		
   mflo $t8			#$t8 = (row * 2)
   sub $t1, $t6, $t8		#$t1 = 14(row + 1) - (row * 2)
   mult $t0, $t4
   mflo $t7			#$t7 = col*2
   add $t1, $t1, $t7		#$t1 = (14(row + 1) - (row *2)+(col*2)

   addi $t1, $t1, 2  		#$t1 + 2

   add $t2, $t2, $t1		#moves $t2 to correct position

   lb $t4 0($t2)		#loads what's in the position to $t4

   beq $t4, $t9, ifAlready	#if $t2 == X
   li $t5, 2
   div $t1, $t5			#$t1 / 2
   mfhi $t6			#remainder
   bne $t6, 0, ifInvalid	# $t1 % 2 != 0
   blt $t1, 14, ifInvalid	#if $t1 < 14
   bgt $t1, 70, ifInvalid	#if $t1 > 70
   beq $t1, 24, ifInvalid	#if $t1 = 24
   beq $t1, 36, ifInvalid	#if $t1 = 36
   beq $t1, 48, ifInvalid	#if $t1 = 48
   beq $t1, 60, ifInvalid	#if $t1 = 60

   ifSuccess:
      li $t7, 0			#status = 0
      sb $t9, 0($t2)		#makes X in position
      j ifEnd
   ifAlready:
      li $t7, 1			#status = 1
      j ifEnd
   ifInvalid:
      li $t7, 2			#status = 2
   ifEnd:

   move $a0, $t7
   
   jal displayStatus

   lw $ra, 0($sp)
   addi $sp, $sp, 4

   j $ra
displayStatus:
   addi $sp, $sp, -4
   sw $ra, 0($sp)

   beq $a0, 0, ifSuc
   beq $a0, 1, ifAlr
   beq $a0, 2, ifInv

   ifSuc:
      la $a0, marked
      li $v0, 4
      syscall
      j ifExit
   ifAlr:
      la $a0, already
      li $v0, 4
      syscall
      j ifExit
   ifInv:
      la $a0, invalid
      li $v0, 4
      syscall
   ifExit:

   lw $ra, 0($sp)
   addi $sp, $sp, 4

   j $ra
EXIT:
   li $v0, 10
   syscall
.end main
#End of file









