.data
		gameBoard: .space 42 # init the gameBoard with the size of 6x7 = 42 bits
		msg_welcome: .asciiz "Welcome to Four-in-a-row"
		msg_player1_first: .asciiz "\nPlayer one will go first. Please choose X (type 1) or O (type 0): "
		msg_player2_first: .asciiz "\nPlayer two will go first. Please choose X (type 1) or O (type 0): "
		msg_player1_token_X: .asciiz "\nPlayer one chose X. Player two will go with O."
		msg_player2_token_X: .asciiz "\nPlayer two chose X. Player one will go with O."
		msg_player1_token_O: .asciiz "\nPlayer one chose O. Player two will go with X."
		msg_player2_token_O: .asciiz "\nPlayer two chose O. Player two will go with X."
		invalid_token: .asciiz "\nInvalid token. Please choose X (type 1) or O (type 0):"
		
		msg_player1_turn: .asciiz "\nPlayer one turn. If player one wants to undo your previous move, please type 8, else please choose the column you want to drop token into (0-7): "
		msg_player2_turn: .asciiz "\nPlayer two turn. If player two wants to undo your previous move, please type 8, else please choose the column you want to drop token into (0-7): "
		msg_player1_choice: .asciiz "\nPlayer one chose column "
		msg_player2_choice: .asciiz "\nPlayer two chose column "
		msg_winner: .asciiz "\nFour in a row. The winner is player "
		msg_draw: .asciiz "\nDraw"
		dot: .asciiz "."
		X_token: .asciiz "X"
		O_token: .asciiz "O"
		endLine: .asciiz "\n"

.text 
# during coding, $t0 and $t1 will ALWAYS be used as iterator for loops
# during coding, $t2 will ALWAYS be used as binary value of slt, slti
# $s1 will store token of player 1 (0 for O, 1 for X)
# $s2 will store token of player 2 (0 for O, 1 for X)
# in the gameBoard, there are three differents sign: . (empty), O, X

main:
		jal 	welcome # jump to welcome
		jal 	coin_toss # choose which player goes first
		jal 	init # initialize a few important variable
		jal 	print # print the array
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
		
		li 	$s1, 1
Back_to_main:	jr 	$ra
		
player2_X:
		la	$a0, msg_player2_token_X # print msg that player 2 chose X 
		li	$v0, 4
		syscall
		
		li 	$s1, 0
Back_to_main:	jr 	$ra

player1_first:	# if player 1 goes first
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
		
		li 	$s2, 1
Back_to_main:	jr 	$ra
		
player1_X:
		la	$a0, msg_player1_token_X # print msg that player 2 chose X 
		li	$v0, 4
		syscall
		
		li 	$s2, 0
Back_to_main:	jr 	$ra
		
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
		
Back_to_main:	jr	$ra

##############################################################################

print:	
		li 	$t0, 0	# setup overall counter
		la	$t1, gameBoard # t1 as the pointer to the start of gameBoard
		li 	$t3, 0	# setup counter for the number of element in a row
		
loopPrint:	
		lb 	$a0, 0($t1) # load a[i][j] to a
		li 	$v0, 11
		syscall
		
		addi	$t1, $t1, 1 # move to the next element
		addi 	$t0, $t0, 1 # increase overall counter
		addi 	$t3, $t3, 1 # increase row counter
		
		slti	$t2, $t3, 7  # check if the number of elements on a row is 7
		beq 	$t2, 1, checkCount # if no, move to checkCount 
		li	$t3, $t3, 0 # if yes, reset to 0, print endLine
printEndLine:	la	$a0, endLine
		li	$v0, 4
		syscall	
		
checkCount:	slti	$t2, $t0, 42 # check if traversed through the gameBoard
		beq 	$t2, 1, loopPrint 
		
Back_to_main:	jr	$ra
		
##############################################################################

exit:
