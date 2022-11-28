.data
		gameBoard: .space 42 # init the gameBoard with the size of 6x7 = 42 bits
		msg_welcome: .asciiz "Welcome to Four-in-a-row"
		msg_player1_first: .asciiz "\nPlayer 1 will go first. Please choose X (type 1) or O (type 0): "
		msg_player2_first: .asciiz "\nPlayer 2 will go first. Please choose X (type 1) or O (type 0): "
		msg_player1_token_X: .asciiz "\nPlayer 1 chose X. Player 2 will go with O."
		msg_player2_token_X: .asciiz "\nPlayer 2 chose X. Player 1 will go with O."
		msg_player1_token_O: .asciiz "\nPlayer 1 chose O. Player 2 will go with X."
		msg_player2_token_O: .asciiz "\nPlayer 2 chose O. Player 1 will go with X."
		invalid_token: .asciiz "\nInvalid token. Please choose X (type 1) or O (type 0):"
		msg_empty_board: .asciiz "\nCannot undo since the board is empty."
		msg_already_undo: .asciiz "\nCannot undo since the player already undid in this round."
		
		msg_player1_turn: .asciiz "\nPlayer 1 turn. If player 2 wants to undo your previous move, please type 8, else please choose the column you want to drop token into (1-7): "
		msg_player2_turn: .asciiz "\nPlayer 2 turn. If player 1 wants to undo your previous move, please type 8, else please choose the column you want to drop token into (1-7): "
		msg_player1_choice: .asciiz "\nPlayer 1 chose column "
		msg_player2_choice: .asciiz "\nPlayer 2 chose column "
		msg_player1_violate: .asciiz "\nPlayer 1 violated the rule. Violation count remain: "
		msg_player2_violate: .asciiz "\nPlayer 2 violated the rule. Violation count remain: "
		msg_player1_eliminate: .asciiz "\nPlayer 1 violated the rule 3 times. Therefore, player 1 lost the game."
		msg_player2_eliminate: .asciiz "\nPlayer 2 violated the rule 3 times. Therefore, player 2 lost the game."
		msg_player1_undo: .asciiz "\nPlayer 1 undoed. The remaining undo count is: "
		msg_player2_undo: .asciiz "\nPlayer 2 undoed. The remaining undo count is: "
		msg_player1_undo_failed: .asciiz "\nPlayer 1 is out of undo chance."
		msg_player2_undo_failed: .asciiz "\nPlayer 2 is out of undo chance."
		msg_winner: .asciiz "\nThe winner is player "
		msg_draw: .asciiz "\nDraw"
		dot: .asciiz "."
		X_token: .asciiz "X"
		O_token: .asciiz "O"
		endLine: .asciiz "\n"
		gap: .asciiz " "

.text 
# during coding, $t0 and $t1 will ALWAYS be used as iterator for loops
# during coding, $t2 will ALWAYS be used as binary value of slt, slti
# $s1 will store token of player 1 (0 for O, 1 for X)
# $s2 will store token of player 2 (0 for O, 1 for X)
# $s3 will notify which player is currently in turn (1 for player 1, 2 for player 2)
# in the gameBoard, there are three differents sign: . (empty), O, X

main:
		jal 	welcome # jump to welcome
		jal 	coin_toss # choose which player goes first
		jal 	init # initialize a few variables
		jal 	gameFunc # the game function, including loops until there is a player or the board is full
		jal 	winNoti # notify the winner
		j 	exit

##############################################################################

welcome: # Print welcome message
		la	$a0, msg_welcome
		li 	$v0, 4
		syscall
		jr 	$ra

##############################################################################

coin_toss: # Choose which player will go first. If the output is 1, choose player 1, else choose player 2.
		li 	$a1, 2
		li 	$v0, 42
		syscall # generate random [0,1], store in $a0
		
		move 	$t2, $a0
		beq 	$t2, 1, player1_first

player2_first:	# if player 2 goes first
		li	$s3, 2
		la 	$a0, msg_player2_first # print message to inform
		li	$v0, 4
		syscall 
		
player2_token_choice:	
		li	$v0, 5 # read token choice
		syscall
		move 	$s2, $v0
		beq 	$s2, 1, player2_X 
		beq	$s2, 0, player2_O
		
		# if token is invalid
		la 	$a0, invalid_token
		li 	$v0, 4
		syscall
		j 	player2_token_choice
		
player2_O:
		la	$a0, msg_player2_token_O # print msg that player 2 chose O 
		li	$v0, 4
		syscall
		
		la 	$s1, X_token # player 1 choose X token
		la 	$s2, O_token # player 2 choose O token
		lb	$s1, 0($s1)
		lb	$s2, 0($s2)
		jr 	$ra # go back to main 
		
player2_X:
		la	$a0, msg_player2_token_X # print msg that player 2 chose X 
		li	$v0, 4
		syscall
		
		la 	$s1, O_token # player 1 choose O token
		la 	$s2, X_token # player 2 choose X token
		lb	$s1, 0($s1)
		lb	$s2, 0($s2)
		jr 	$ra # go back to main 

player1_first:	# if player 1 goes first
		li	$s3, 1
		la 	$a0, msg_player1_first # print message to inform
		li	$v0, 4
		syscall 
		
player1_token_choice:	
		li	$v0, 5 # read token choice
		syscall
		move 	$s1, $v0
		beq 	$s1, 1, player1_X 
		beq	$s1, 0, player1_O
		
		# if token is invalid
		la 	$a0, invalid_token
		li 	$v0, 4
		syscall
		j 	player1_token_choice
		
player1_O:
		la	$a0, msg_player1_token_O # print msg that player 2 chose O 
		li	$v0, 4
		syscall
		
		la 	$s1, O_token # player 1 choose O token
		la 	$s2, X_token # player 2 choose X token
		lb	$s1, 0($s1)
		lb	$s2, 0($s2)
		jr 	$ra # go back to main 
		
player1_X:
		la	$a0, msg_player1_token_X # print msg that player 2 chose X 
		li	$v0, 4
		syscall
		
		la 	$s1, X_token # player 1 choose X token
		la 	$s2, O_token # player 2 choose O token
		lb	$s1, 0($s1)
		lb	$s2, 0($s2)
		jr 	$ra # go back to main 
		
##############################################################################

init:	
		li 	$t0, 0	# setup counter
		la	$t1, gameBoard # t1 as the pointer to the start of gameBoard
		
		la	$t3, dot 
		lb 	$t3, 0($t3) # store the character "." in $t3
		
loopInit:	
		sb	$t3, 0($t1)
		addi	$t0, $t0, 1 # increase counter
		addi 	$t1, $t1, 1 # move to the next element 
		slti	$t2, $t0, 42 # check if t0 < 42
		beq 	$t2, 1, loopInit 
		
		# we push the following info to the stack: the previously added token's column index, undoCount of player 1, 
		# undoCount of player 2, violation chance left of player 1, violation chance left of player 2. 
		# The order must be maintained (with "violation chance left of player 2" on top of the stack at the end of procedure). 	
		addi 	$sp, $sp, -20
		li	$t3, -1 # the init value of the first one is -1
		sw	$t3, 0($sp)
		li	$t3, 3	# the four last of them have initial value of 3
		sw	$t3, 4($sp)
		sw 	$t3, 8($sp)
		sw 	$t3, 12($sp)
		sw 	$t3, 16($sp)

		jr	$ra # go back to main 

##############################################################################

print:	
		la	$a0, endLine # print End Line
		li	$v0, 4
		syscall	

		li 	$t0, 0	# setup overall counter
		la	$t1, gameBoard # t1 as the pointer to the start of gameBoard
		li 	$t3, 0	# setup counter for the number of element in a row
loopPrint:	
		lb 	$a0, 0($t1) # load a[i][j] to a0 for printing
		li 	$v0, 11
		syscall
		
		la 	$a0, gap # print space
		li 	$v0, 4
		syscall
		
		addi	$t1, $t1, 1 # move to the next element
		addi 	$t0, $t0, 1 # increase overall counter
		addi 	$t3, $t3, 1 # increase element counter
		
		slti	$t2, $t3, 7  # check if the number of elements on a row is 7
		beq 	$t2, 1, checkCount # if no, move to checkCount 
		li	$t3, 0 # if yes, reset to 0, print endLine
		la	$a0, endLine # print End Line
		li	$v0, 4
		syscall	
		
checkCount:	
		slti	$t2, $t0, 42 # check if traversed over all the gameBoard yet
		beq 	$t2, 1, loopPrint 

		jr	$ra # go back to caller	 
		
##############################################################################

inputToken:
		beq	$s3, 1, player1_turn_msg # if it's player 1's turn, jump to player1_turn_msg
		
player2_turn_msg:	
		la	$a0, msg_player2_turn # notify it's player 2 turn
		li	$v0, 4
		syscall
		j inputTokenProcess
		
player1_turn_msg:	
		la	$a0, msg_player1_turn # notify it's player 1 turn
		li	$v0, 4
		syscall
		j inputTokenProcess
		
inputTokenProcess:	
		li	$v0, 5 # read player input column
		syscall
		move	$a2, $v0 # store the input of player to a2
		
		slti	$t2, $a2, 1 # check if a2 is smaller than 1
		beq 	$t2, 1, illegalChoice
		
		slti	$t2, $a2, 9 # check if a2 is greater than 9
		beq 	$t2, 0, illegalChoice
		
		beq 	$a2, 8, Undo # if the input is 8, undo 
		
		j 	addToken # jump to addToken
	
Undo: 	
		addi	$s4, $s4, -1 # subtract the round count by one
		j 	undoProcess # jump to the undo process, then return 
		
						
addToken:	# AddToken function, add the token of current player to the chosen column (in $a2)
		li	$s6, 1	# since there is a new token added to the board, it means we can undo now
		addi 	$a2, $a2, -1	# since the input is in range [1-7], but the column indexes are [0,6] so we have to reduce it by 1
		
		addi	$t0, $a2, 1 # use t0 as the count of element. Initially, set t0 = a2 (before subtraction)
		la	$t1, gameBoard # use t1 as the pointer to the start of gameBoard
		la	$t3, dot 
		lb 	$t3, 0($t3) # store the character "." in $t3
		
		add 	$t1, $t1, $a2 # move the pointer to the first element in that column 
		lb 	$t4, 0($t1) #load the character at t1 pointer to t4
		bne	$t3, $t4, illegalChoice # if the first element in the chosen column is not a dot means that column is full => illegal 
		
loopAdd:	# loop to find the lowest element in the chosen column that is not equal to dot
		addi 	$t0, $t0, 7 # move to the next row
		addi	$t1, $t1, 7 # move to the next row
		lb 	$t4, 0($t1) #load the character at t1 pointer to t4
		slti	$t2, $t0, 43 # check if the count is smaller than or equal to 42
		beq	$t2, 0, gotElement # if the count exceed 42, move to got element
		beq	$t3, $t4, loopAdd # if it's still equal to dot, move to the next row 
		
gotElement:	
		addi	$t1, $t1, -7 # subtract by 7 because in the last loop, t1 adds 7
		addi 	$sp, $sp, -4
		sw	$ra, 0($sp) 
		jal 	pushToken # push the have-just-added current token to the stack 	
		lw	$ra, 0($sp) 
		addi 	$sp, $sp, 4 

		beq	$s3, 1, player1_add # if it's player one turn, add player 1's token

player2_add:	
		sb	$s2, 0($t1)
		jr	$ra 	

player1_add:	
		sb	$s1, 0($t1)
		jr	$ra 	

##############################################################################

pushToken: 	# push the previously added token to the stack
		lw	$t6, 0($sp) # store the return address of previous func to t5
		lw	$t7, 4($sp) # store the added Token's column index of the previous round 
		addi 	$sp, $sp, 8	
		
addNewToken: 
		move	$t7, $a2 # set the added Token's column index to the have-just-added token 

pushBackPush:
		addi 	$sp, $sp, -8
		sw	$t6, 0($sp) # save the return address of previous func 
		sw	$t7, 4($sp) # save the added Token's column index
		jr 	$ra 	

##############################################################################

undoProcess:	# the undo process
		la	$t1, gameBoard # load the address of the gameBoard to t1
		li	$t0, 0 # iterator (element counter)
		la	$t3, dot 
		lb 	$t3, 0($t3) # store the character "." in $t3
		
		lw	$t5, 0($sp) # store the added Token's column index
		lw	$t6, 4($sp) # store the "violation chance left of player 2"
		lw 	$t7, 8($sp) # store the "violation chance left of player 1"
		lw	$t8, 12($sp) # store the undoCount of player 2
		lw	$t9, 16($sp) # store the undoCount of player 1
		addi 	$sp, $sp, 20
		
		bne	$s6, 1, undoFailed # if s6 is not equal to 1, it means that we cannot undo
		
		add	$t1, $t1, $t5 # move to the first element in that column
		
		# start the undo process
		# check the current's turn 
		beq	$s3, 2,	player1_undo # if the current's turn is player 2's, it means that player 1 want to undo
player2_undo:
		beq 	$t8, 0, player2_undo_failed # if the undo count is 0, failed to undo 
		
		la	$a0, msg_player2_undo # else print the undo success msg
		addi	$t8, $t8, -1 # reduce the undo chance 
		li 	$v0, 4
		syscall
		
		move	$a0, $t8 # print the undo chance left
		li 	$v0, 1
		syscall
		
		j undoGameBoard
		
player2_undo_failed:
		la	$a0, msg_player2_undo_failed # print the failed undo msg
		li 	$v0, 4
		syscall
		j	swapping 
		
player1_undo:
		beq 	$t9, 0, player1_undo_failed # if the undo count is 0, failed to undo 
		
		la	$a0, msg_player1_undo # else print the undo success msg
		li 	$v0, 4
		syscall
		
		addi	$t9, $t9, -1 # reduce the undo chance 
		move	$a0, $t9 # print the undo chance left
		li 	$v0, 1
		syscall
		
		j undoGameBoard
		
player1_undo_failed:
		la	$a0, msg_player1_undo_failed # print the failed undo msg
		li 	$v0, 4
		syscall
		j	swapping 
		
		
undoFailed:	
		beq	$s6, -1, boardEmpty
		beq	$s6, 0, alreadyUndo	
boardEmpty:	# print msg that the board is empty, so we cannot undo
		la	$a0, msg_empty_board
		li	$v0, 4
		syscall
		j	swapping
alreadyUndo:	# print msg that we already undid in this round
		la	$a0, msg_already_undo
		li	$v0, 4
		syscall
		
		# swap player's turn, so that in the gameFunc, the they will be swapped again (result in no changes)
swapping:	beq 	$s3, 1, swapToTwo # if currently it is player one turn, set to player 2's turn
swapToOne:	li 	$s3, 1 # else set to player 1's turn
		j 	EndSwap
swapToTwo:	li	$s3, 2
EndSwap:	# the end of swap condition
		j	pushBack
			
undoGameBoard:
undoLoop:
		lb	$t4, 0($t1) # load the character at t1 poitner
		bne	$t4, $t3, resetToken # if that token is not dot, then reset it
		addi	$t1, $t1, 7 # else move to the next row
		j	undoLoop # loop again
		
resetToken:
		li	$s6, 0 # load 0 to s6, means that we already undo in this round
		addi	$s4, $s4, -1 # subtract the round count by one
		sb	$t3, 0($t1) # reset the element at pointer t1 to dot
		li	$t5, -1 # since we reset the token on top of input column, we will reset the added Token's column index to 0
		
pushBack: 	# push information back to stack
		addi 	$sp, $sp, -20
		sw 	$t5, 0($sp) # save the added Token's column index
		sw	$t6, 4($sp) # saveore the "violation chance left of player 2"
		sw 	$t7, 8($sp) # save the "violation chance left of player 1"
		sw	$t8, 12($sp) # save the undoCount of player 2
		sw	$t9, 16($sp) # save the undoCount of player 1
		jr	$ra

##############################################################################

gameFunc: # the game function
		# preset
		li 	$s4, 0  # count the number of rounds, if it reaches 42 means the board is full => draw
		li 	$a1, 0 	# if a1 turns to 1, then player 1 wins, else player 2 wins
		li	$s6, -1	# initially the gameBoard is empty, so s6 is set to -1. If s6 is 1, means that we can undo, if s6 is 0 means we already undo in this turn. 
		addi	$sp, $sp, -4 
		sw 	$ra, 0($sp) # push $ra to stack
		jal 	print # print the empty gameBoard
		lw	$ra, 0($sp) # return value of ra
		addi 	$sp, $sp, 4 # return mem to stack
		
gameLoop:
		move 	$s5, $ra # use s5 to store the return address
		jal 	inputToken # input a token 
		jal 	print # print the gameBoard
		jal 	CheckWinCondition # check if any player wins. If there is a winner, the program will automatically declare the winner 
		move	$ra, $s5 # return the return address		
		bne 	$a1, 0, endGameFunc # if there is a winner or a draw, jump to winNoti 
		beq 	$s3, 1, setToTwo # if currently it is player one turn, set to player 2's turn
setToOne:	li 	$s3, 1 # else set to player 1's turn
		j 	EndSet
setToTwo:	li	$s3, 2
EndSet:		# the end of set condition
		addi  	$s4, $s4, 1 # increase round counter
		move 	$a0, $s4
		li	$v0, 1
		syscall
		slti	$t2, $s4, 42 # if the number of round is smaller than 42
		beq	$t2, 1, gameLoop # loop again
		
		# if the number of rounds exceed 42
		li	$a1, 3 # load draw state
		j	endGameFunc
endGameFunc:	jr	$ra # return to main

##############################################################################

illegalChoice:	
		addi  	$s4, $s4, -1 # decrease round counter
		beq	$s3, 1, player1_violate # if it's player 1's turn, jump to player1_violate
		
		
player2_violate:
		lw	$t3, 4($sp) # load violation count of player 2
		addi	$t3, $t3, -1 # reduce by one
		sw	$t3, 4($sp) # save it back to stack
		beq	$t3, 0, player2_eliminate # player 1 is the winner since player 2 violated more than 3 times
		
		la 	$a0, msg_player2_violate # if violation count is not 0 yet, print it to the screen
		li 	$v0, 4
		syscall
		
		move 	$a0, $t3
		li 	$v0, 1
		syscall
		
		beq 	$s3, 1, swapToTwo1 # if currently it is player one turn, set to player 2's turn
swapToOne1:	li 	$s3, 1 # else set to player 1's turn
		j 	EndSwap1
swapToTwo1:	li	$s3, 2
EndSwap1:	# the end of swap condition
		jr	$ra
		
player2_eliminate:
		la 	$a0, msg_player2_eliminate
		li	$v0, 4
		syscall
		li 	$a1, 1 # player 1 is the winner 
		jal	winNoti
		j 	exit # end the game 
		
player1_violate:
		lw	$t3, 8($sp) # load violation count of player 1
		addi	$t3, $t3, -1 # reduce by one
		sw	$t3, 8($sp) # save it back to stack
		beq	$t3, 0, player1_eliminate # if player 1 violated more than 3 times
		
		la 	$a0, msg_player1_violate # if violation count is not 0 yet, print it to the screen
		li 	$v0, 4
		syscall
		
		move 	$a0, $t3 # print violation count
		li 	$v0, 1
		syscall
		
		beq 	$s3, 1, swapToTwo2 # if currently it is player one turn, set to player 2's turn
swapToOne2:	li 	$s3, 1 # else set to player 1's turn
		j 	EndSwap2
swapToTwo2:	li	$s3, 2
EndSwap2:	# the end of swap condition
		jr	$ra
		
player1_eliminate:
		la 	$a0, msg_player1_eliminate
		li	$v0, 4
		syscall
		li 	$a1, 2 # player 2 is the winner 
		jal	winNoti
		j 	exit # end the game 	
 		
##############################################################################

CheckWinCondition: # check for winning condition. We must check 3 cases: horizontal, vertical, diagonal.
		# In each case, we map an area in which the first token of a winning sequence will line in, 
		# then check all of possible case in that area.
		# For vertical case: the first three rows
		# For horizontal case: the first four columns
		# For diagonal case (Left to Right): the first four columns of the first three rows
		# For diagonal case (Right to Left): the last four columns of the first three rows
		
		# preset
		la	$t1, gameBoard # t1 as the pointer to the start of gameBoard
		li 	$t0, 0	# setup counter for the number of rows 
		li 	$t3, 0	# setup counter for the number of columns (elements on a row)
		li 	$a1, 0 	# if a1 turns to 1, then player 1 wins, else player 2 wins

verticalCase:	 
		# check winning
		# t4 will temporary store the address of pointer
		move 	$t4, $t1
		li 	$t8, 1 # count the number of element checked, initially set to one 
		lb 	$t5, 0($t1) #load the character at t1 pointer to t5. This element is the root of sequence
		la	$t6, dot 
		lb 	$t6, 0($t6) # store the character "." in $t6
		beq 	$t5, $t6, nextItemVerti # if the current root is a dot, move to next item
		
checkVerti:
		beq 	$t8, 4, winDetected # if t8 reaches 4 means there is a winner 
		addi	$t4, $t4, 7 # move to the second character in the sequence
		lb 	$t6, 0($t4) # store the temporary element
		addi 	$t8, $t8, 1 # increase sequence count
		beq 	$t5, $t6, checkVerti # check the next character if this character is equal to the root 
		# if it's not equal, it will automatically move to the next root element
		
nextItemVerti:  # check the next element
		addi 	$t1, $t1, 1 # move pointer to the next element
		addi 	$t3, $t3, 1 # increase column counter
		slti	$t2, $t3, 7  # check if the number of elements on a row smaller 7
		beq 	$t2, 1, verticalCase # if yes, loop again
		li	$t3, 0 # if no, reset to 0, increase row count, check row count 
		addi 	$t0, $t0, 1
		slti	$t2, $t0, 3  # check if the row count smaller than 3
		beq 	$t2, 1, verticalCase # if yes, loop again
		
#/*******************************************************************************************\#
		
		# reset	board pointer, row counter, column counter	
		la	$t1, gameBoard # t1 as the pointer to the start of gameBoard
		li 	$t0, 0	# setup counter for the number of rows 
		li 	$t3, 0	# setup counter for the number of columns (elements on a row)
horizontalCase: 		
		# check winning
		# t4 will temporary store the address of pointer
		move 	$t4, $t1
		li 	$t8, 1 # count the number of element checked, initially set to one 
		lb 	$t5, 0($t1) #load the character at t1 pointer to t5. This element is the root of sequence
		la	$t6, dot 
		lb 	$t6, 0($t6) # store the character "." in $t6
		beq 	$t5, $t6, nextItemHori # if the current root is a dot, move to next item
		
checkHori:
		beq 	$t8, 4, winDetected # if t8 reaches 4 means there is a winner 
		addi	$t4, $t4, 1 # move to the second character in the sequence
		lb 	$t6, 0($t4) # store the temporary element
		addi 	$t8, $t8, 1 # increase sequence count
		beq 	$t5, $t6, checkHori # check the next character if this character is equal to the root 
		# if it's not equal, it will automatically move to the next root element
		
nextItemHori:  # check the next element
		addi 	$t1, $t1, 1 # move pointer to the next element
		addi 	$t3, $t3, 1 # increase column counter
		slti	$t2, $t3, 4  # check if the number of elements on a row smaller 4
		beq 	$t2, 1, horizontalCase # if yes, loop again
		li	$t3, 0 # if no, reset to 0, move to the next line
		addi 	$t1, $t1, 3 # move to the start of next line
		addi 	$t0, $t0, 1 # increase the row count by 1
		slti	$t2, $t0, 7  # check if the row count smaller than 7
		beq 	$t2, 1, horizontalCase # if yes, loop again

#/*******************************************************************************************\#

		# reset	board pointer, row counter, column counter	
		la	$t1, gameBoard # t1 as the pointer to the start of gameBoard
		li 	$t0, 0	# setup counter for the number of rows 
		li 	$t3, 0	# setup counter for the number of columns (elements on a row)
DiagonalLRCase: 		
		# check winning
		# t4 will temporary store the address of pointer
		move 	$t4, $t1
		li 	$t8, 1 # count the number of element checked, initially set to one 
		lb 	$t5, 0($t1) #load the character at t1 pointer to t5. This element is the root of sequence
		la	$t6, dot 
		lb 	$t6, 0($t6) # store the character "." in $t6
		beq 	$t5, $t6, nextItemDiagLR # if the current root is a dot, move to next item
		
checkDiagLR:
		beq 	$t8, 4, winDetected # if t8 reaches 4 means there is a winner 
		addi	$t4, $t4, 8 # move to the next character in the sequence
		lb 	$t6, 0($t4) # store the temporary element
		addi 	$t8, $t8, 1 # increase sequence count
		beq 	$t5, $t6, checkDiagLR # check the next character if this character is equal to the root 
		# if it's not equal, it will automatically move to the next root element
		
nextItemDiagLR:  # check the next element
		addi 	$t1, $t1, 1 # move pointer to the next element
		addi 	$t3, $t3, 1 # increase column counter
		slti	$t2, $t3, 4  # check if the number of elements on a row (column count) is smaller 4
		beq 	$t2, 1, DiagonalLRCase # if yes, loop again
		li	$t3, 0 # if no, reset to 0, move to the next line
		addi 	$t1, $t1, 3 # move to the start of next line
		addi 	$t0, $t0, 1 # increase the row count by 1
		slti	$t2, $t0, 3  # check if the row count smaller than 3
		beq 	$t2, 1, DiagonalLRCase # if yes, loop again

#/*******************************************************************************************\#

		# reset	board pointer, row counter, column counter	
		la	$t1, gameBoard # t1 as the pointer to the start of gameBoard
		addi 	$t1, $t1, 3 # move to the fourth column
		li 	$t0, 0	# setup counter for the number of rows 
		li 	$t3, 0	# setup counter for the number of columns (elements on a row)
DiagonalRLCase: 		
		# check winning
		# t4 will temporary store the address of pointer
		move 	$t4, $t1
		li 	$t8, 1 # count the number of element checked, initially set to one 
		lb 	$t5, 0($t1) #load the character at t1 pointer to t5. This element is the root of sequence
		la	$t6, dot 
		lb 	$t6, 0($t6) # store the character "." in $t6
		beq 	$t5, $t6, nextItemDiagRL # if the current root is a dot, move to next item
		
checkDiagRL:
		beq 	$t8, 4, winDetected # if t8 reaches 4 means there is a winner 
		addi	$t4, $t4, 6 # move to the next character in the sequence
		lb 	$t6, 0($t4) # store the temporary element
		addi 	$t8, $t8, 1 # increase sequence count
		beq 	$t5, $t6, checkDiagRL # check the next character if this character is equal to the root 
		# if it's not equal, it will automatically move to the next root element
		
nextItemDiagRL:  # check the next element
		addi 	$t1, $t1, 1 # move pointer to the next element
		addi 	$t3, $t3, 1 # increase column counter
		slti	$t2, $t3, 4  # check if the number of elements on a row (column count) is smaller 4
		beq 	$t2, 1, DiagonalRLCase # if yes, loop again
		li	$t3, 0 # if no, reset to 0, move to the next line
		addi 	$t1, $t1, 3 # move to the fourth column of next line
		addi 	$t0, $t0, 1 # increase the row count by 1
		slti	$t2, $t0, 3  # check if the row count smaller than 3
		beq 	$t2, 1, DiagonalRLCase # if yes, loop again

		jr 	$ra # return to caller

winDetected:
		beq 	$t5, $s1, oneWin # if root equals to player 1 token => player 1 wins
twoWin:		
		li 	$a1, 2 # else player 2 wins
		jr 	$ra

oneWin:	
		li 	$a1, 1
		jr 	$ra

##############################################################################

winNoti:
		beq 	$a1, 3, draw # if a1 equals to 3 means draw 
win:
		la 	$a0, msg_winner # print congrats message
		li 	$v0, 4
		syscall
		beq 	$a1, 1, player1_win # if a1 equals to 1 means player 1 wins 
		beq 	$a1, 2, player2_win # if a1 equals to 2 means player 2 wins 

player1_win:			
		li 	$a0, 1 # print winner
		li 	$v0, 1
		syscall
		jr	$ra
		
player2_win:			
		li 	$a0, 2 # print winner
		li 	$v0, 1
		syscall
		jr	$ra
		
draw:		
		la 	$a0, msg_draw # print draw message
		li 	$v0, 4
		syscall
		jr 	$ra
		
exit:
