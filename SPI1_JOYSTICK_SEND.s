.ifndef SPI1
    SPI1:
    .include "TIMER_JOYSTICK_TIMER.s"
    .data
    y_data_1: .word 0
    x_data_1: .word 0
    counter_1: .word 0
    joystick_1: .space 5
    .text
    .ent setup_SPI1
	setup_SPI1:
	DI
	
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	# Set the clock as output
	LI $t0, 1 << 10
	SW $t0, TRISDCLR
	
	# Set SDI as input
	LI $t0, 1 << 4
	SW $t0, TRISCSET
	
	# Set SDO as output
	LI $t0, 1 
	SW $t0, TRISDCLR
	
	# Set slave select line as output
	LI $t0, 1 << 9
	SW $t0, TRISDCLR
	
	LI $t0, 1 << 9
	SW $t0, LATDSET
	
	SW $zero, SPI1CON
	
	# Disable SPI peripheral 
	LI $t0, 1 << 15
	SW $t0, SPI1CONCLR
	
	SW $zero, SPI1BUF
	
	# Set the PIC32 as master mode
	# SPI2CON<5> = 1
	LI $t0, 1 << 5
	SW $t0, SPI1CONSET
	
	# Test 
	LI $t0, 1 << 6
	SW $t0, SPI1CONCLR
	
	LI $t0, 1 << 8
	SW $t0, SPI1CONSET
	
	# Set the baud rate generator to 1MHz 
	# Load 19 into baud rate register to get 1Mhz at a 40Mhz PBCLK
	LI $t0, 19
	SW $t0, SPI1BRG
	
	# Enable SPI peripheral
	LI $t0, 1 << 15
	SW $t0, SPI1CONSET
	
	EI
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end setup_SPI1
    
    .ent get_x_y_1
	get_x_y_1:
	ADDI $sp, $sp, -16
	SW $ra, 0($sp)
	SW $s0, 4($sp)
	SW $s1, 8($sp)
	SW $s2, 12($sp)
	
	LI $t0, 1 << 9 # Drive the slave select to low
	SW $t0, LATDCLR
	
	LI $a0, 30 # Gives 30 us
	JAL timer_1_delay
	
	startsend_spi_1:
	LI $t1, 0x00
	SB $t1, SPI1BUF # Store to buffer
	
	LB $t1, SPI1BUF  # Load the first byte of the returned data
	
	LW $t0, counter_1  # Load the value of the joy stick 
	LA $t2, joystick_1
	ADD $t0, $t2, $t0 # Add the offset to the base address
	SB $t1, 0($t0) # Store the recevied byte into joystick
	
	LW $t0, counter_1  # Load the value of the joy stic
	ADDI $t0, $t0, 1
	SW $t0, counter_1
	BEQ $t0, 5, endsend_spi_1 # If counter equals five jump to end 
	
	LI $s0, 1 << 15 # Turn on timer1
	SW $s0, T1CONSET
	
	LI $s0, 1  # Setting Flag 
	
	# Loop will continue until interrupt sets the $s0 = 0
	# 30 us 
	LI $a0, 30 # Gives 30 us
	JAL timer_1_delay
	J startsend_spi_1
	
	endsend_spi_1:
	LI $t0, 1 << 9 # Drive the slave select to low
	SW $t0, LATDSET
	
	SW $zero, counter_1
	
	# Store number X
	LA $t1, joystick_1
	ADDI $t0, $t1, 1 # Get the second byte
	LB $s0, 0($t0)
	ANDI $s0, $s0, 0xFF
	
	ADDI $t0, $t1, 2
	LB $s1, 0($t0) # Load the third byte
	
	ANDI $s1, $s1, 0x3
	SLL $s1, $s1, 8
	
	ADD $s2, $s1, $s0
	SW $s2, x_data_1
	
	# Store number Y
	ADDI $t0, $t1, 3 # Get the fourth byte
	LB $s0, 0($t0)
	ANDI $s0, $s0, 0xFF
	
	ADDI $t0, $t1, 4
	LB $s1, 0($t0) # Load the fifth byte
	

	ANDI $s1, $s1, 0x3
	SLL $s1, $s1, 8
	
	ADD $s2, $s1, $s0
	SW $s2, y_data_1
	
	LW $v0, x_data_1
	LW $v1, y_data_1
	
	
	LW $ra, 0($sp)
	LW $s0, 4($sp)
	LW $s1, 8($sp)
	LW $s2, 12($sp)
	ADDI $sp, $sp, 16
	JR $ra
    .end get_x_y_1
.endif 




