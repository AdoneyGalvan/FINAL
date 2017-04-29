.ifndef GENERAL_UART1
    GENERAL_UART1:
    .ent setup_UART1
	setup_UART1:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	# UART 1 on PORT JE, RD14, RF8, RF2, RD15, Top
	# Setting the buad rate generator to 9600 baud
	# U1BRG = 259
	LI $t0, 259
	SW $t0, U1BRG
	
	# Setting up the UART frame
	# Frame 8 data bits, 1 stop bit, no parity bit
	
	# Disable URAT1 while configuring
	# U1MODE<15> = 0
	LI $t0, 1 << 15
	SW $t0, U1MODECLR
	
	# Parity and Data Seelection, 8 bits no parity
	# U1MODE<2:1> = 00
	LI $t0, 3 << 1
	SW $t0, U1MODECLR

	# Select number of stop bits, 1 stop bit
	# U1MODE<0> = 0
	LI $t0, 1
	SW $t0, U1MODECLR
	
	# Enable UART Transmission
	LI $t0, 1 << 10
	SW $t0, U1STASET
	
	# Enable UART Recieve
	LI $t0, 1 << 12
	SW $t0, U1STASET
	
 	# Enable URAT1 while configuring
	# U1MODE<15> = 1
	LI $t0, 1 << 15
	SW $t0, U1MODESET
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end setup_UART1
    
    .ent receive_byte_on_UART1
	receive_byte_on_UART1:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)

	waittoreceive:
	LW $t2, U1STA
	ANDI $t2, $t2, 1
	BEQZ $t2, waittoreceive
	J endreceive
	
	endreceive:
	LB $v0, U1RXREG
	LI $t0, 32
	BEQ $v0, $t0, waittoreceive # Ignore character 
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end receive_byte_on_UART1
    
    .ent send_char_arr_to_UART1
	send_char_arr_to_UART1:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	MOVE $t0, $a0
	
	startsend1:
	LB $t1, 0($t0)
	ADDI $t0, $t0, 1
	BEQZ $t1, endsend1
	
	waittosend1:
	LW $t2, U1STA
	ANDI $t2, $t2, 1 << 9
	SRL $t2, $t2, 9
	BEQZ $t2, endwaittosend1
	J waittosend1
	
	endwaittosend1:
	SB $t1, U1TXREG
	J startsend1
	
	endsend1:
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end send_char_arr_to_UART1
.endif





