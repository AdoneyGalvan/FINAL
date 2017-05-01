.ifndef TIMER
    TIMER:
    
    .data
    timer_flag: .byte 0
    
    .text
    # Interupt handler is in main
    .ent setup_timer_1
	setup_timer_1:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	DI
	LI $t0, 1 << 12
	SW $t0, INTCONSET
	
	# Turn off timer 1
	# TICON<15> = 0
	LI $t0, 1 << 15
	SW $t0, T1CONCLR

	# Select parent clock
	# T1CON<1> = 0, internal peripheral clock
	LI $t0, 1 << 1
	SW $t0, T1CONCLR

	# Set prescalar value 
	# T1CON<5:4> = 0b01 1:256
	LI $t0, 3 << 4
	SW $t0, T1CONCLR

	LI $t0, 0b11 << 4
	SW $t0, T1CONSET

	# Set the TMR1 to zero
	SW $zero, TMR1

	# Set the period register 
	# Peripheral Clock is running at 40MHz, Prescalar 8, Timer Running at 5000000
	LI $t0, 40 # Pr value is set depending on the amount of time desired 
	SW $t0, PR1

	# Setup Timer 1 interrupt
	# Disable timer 1 interrupt
	# IEC0<4> = 0
	LI $t0, 1 << 4
	SW $t0, IEC0CLR

	# Set interrupt priority
	# IPC1<4:2> = 0b110
	LI $t0, 7 << 2
	SW $t0, IPC1CLR

	LI $t0, 6 << 2
	SW $t0, IPC1SET

	# Enable timer 1 interrupt
	# IEC0<4> = 0
	LI $t0, 1 << 4
	SW $t0, IEC0SET

	EI
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end setup_timer_1
    
     .ent timer_1_delay
	timer_1_delay:
	ADDI $sp, $sp, -12
	SW $ra, 0($sp)
	SW $t0, 4($sp)
	SW $s0, 8($sp) 
	
	SW $a0, PR1 # The length of the delay, clock at 5000000Hz 
	LI $s0, 1 # Set flag high
	sb $s0, timer_flag
	LI $t0, 1 << 15 # Turn on the timer
	SW $t0, T1CONSET
	
	delay_loop:
	lb $s0, timer_flag
	BEQZ $s0, end_delay
	NOP
	J delay_loop
	
	end_delay:
	LI $t0, 1 << 15 # Turn off the timer
	SW $t0, T1CONCLR 
	SW $zero, TMR1
	
	LW $s0, 8($sp)
	LW $t0, 4($sp)
	LW $ra, 0($sp)
	ADDI $sp, $sp, 12
	JR $ra
     .end timer_1_delay
     


.Text
 .ent timer_1_handler 
    timer_1_handler:
    DI

    ADDI $sp, $sp, -12
    SW $ra, 0($sp)
    SW $t0, 4($sp)
    SW $t1, 8($sp)

    # Clear interrupt flag
    # IFS0<4> = 0, Cleared interrupt flag
    LI $t0, 1 << 4
    SW $t0, IFS0CLR

    # Flag to exit loop
    LI $t0, 0
    sb $t0, timer_flag

    LW $ra, 0($sp)
    LW $t0, 4($sp)
    LW $t1, 8($sp)
    ADDI $sp, $sp, 12
    EI
    ERET
 .end timer_1_handler 
.endif





