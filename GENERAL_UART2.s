.ifndef UART2
    UART2:
    .ent setup_UART2
	setup_UART2:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	# UART 2 on PORT JH, RF12, RF5, RF4, RF13, Top
	# Setting the buad rate generator to 9600 baud
	# U2BRG = 259
	LI $t0, 259
	SW $t0, U2BRG
	
	# Setting up the UART frame
	# Frame 8 data bits, 1 stop bit, no parity bit
	
	# Disable URAT2 while configuring
	# U2MODE<15> = 0
	LI $t0, 1 << 15
	SW $t0, U2MODECLR
	
	# Parity and Data Seelection, 8 bits no parity
	# U2MODE<2:1> = 00
	LI $t0, 3 << 1
	SW $t0, U2MODECLR

	# Select number of stop bits, 1 stop bit
	# U2MODE<0> = 0
	LI $t0, 1
	SW $t0, U2MODECLR
	
	# Enable UART Transmit
	LI $t0, 1 << 10
	SW $t0, U2STASET
	
	# Enable UART Transmit
	LI $t0, 1 << 12
	SW $t0, U2STASET
	
 	# Enable URAT2
	# U2MODE<15> = 1
	LI $t0, 1 << 15
	SW $t0, U2MODESET
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end setup_UART2
    
    .ent send_char_arr_to_UART2
	send_char_arr_to_UART2:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	MOVE $t0, $a0
	
	startsend:
	LB $t1, 0($t0)
	ADDI $t0, $t0, 1
	BEQZ $t1, endsend
	
	waittosend:
	LW $t2, U2STA
	ANDI $t2, $t2, 1 << 9
	SRL $t2, $t2, 9
	BEQZ $t2, endwaittosend
	J waittosend
	
	endwaittosend:
	SB $t1, U2TXREG
	J startsend
	
	endsend:
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end send_char_arr_to_UART2
    
    .ent send_byte_to_UART2
	send_byte_to_UART2:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	MOVE $t0, $a0
	
	waittosendbyte:
	LW $t2, U2STA
	ANDI $t2, $t2, 1 << 9
	SRL $t2, $t2, 9
	BEQZ $t2, endwaittosendbyte
	J waittosendbyte
	
	endwaittosendbyte:
	SB $t0, U2TXREG
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end send_byte_to_UART2
.endif




