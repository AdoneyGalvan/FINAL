.ifndef ROBOMAL_BRAKE_TIMER
    ROBOMAL_BRAKE_TIMER:
	.ent brake_timer_setup
	brake_timer_setup:
	DI # Turning off all external interrupts 

	# Setup multi vector mode (enabling interrupt vector table)
	# INTCON<12> = 1 for multi vector mode
	LI $t0, 1 << 12
	SW $t0, INTCONSET

	# Turn off timer 4 and 5
	LI $t0, 1 << 15
	SW $t0, T4CONCLR
	SW $t0, T5CONCLR

	# Setting timer as a 32bit timer with timer 3
	# T4CON<3> = 1, 32-bit Timer Mode Select Bit
	LI $t0, 1 << 3
	SW $t0, T4CONSET

	# **************************************************************
	# Timer 2 configuration registers will be used to configure the timer
	# **************************************************************
	# Selecting the parent clock for the timer 
	# T4CON<1> = 0, Internal peripheral clock
	LI $t0, 1 << 1
	SW $t0, T4CONCLR

	# Setting the prescalar value for the peripheral clock
	# T4CON<6:4> = 0b110, 64 prescalar value
	LI $t0, 7 << 4
	SW $t0, T4CONCLR
	LI $t0, 6 << 4
	SW $t0, T4CONSET

	# Setting the counter timer count register to 0
	SW $zero, TMR4


	# ***********************************************************************
	# Timer 5 interrupt control registers will be used to configure the timer 
	# ***********************************************************************
	# Turn off timer 5 interrupt while setup configuration
	# IEC0<20> = 0, turn off 
	LI $t0, 1 << 20
	SW $t0, IEC0CLR 

	# Set interrupt priority to 6
	# IPC5<4:2> = 0b110
	LI $t0, 7 << 2
	SW $t0, IPC5CLR
	LI $t0, 6 << 2
	SW $t0, IPC5SET

	# Turn on the timer interrupt
	# IEC0<20> = 1, turn on
	LI $t0, 1 << 20
	SW $t0, IEC0SET

	EI
	JR $ra
     .end brake_timer_setup    

     # .section definedin final_main
    .Text
    .ent timer_4_5_handler
	timer_4_5_handler:
	DI # Turn off all interrupts

	ADDI $sp, $sp, -8
	SW $ra, 0($sp)
	SW $t0, 4($sp)
	

	# Clear interrupt flag
	# IFS0<20> = 0, Cleared interrupt flag
	LI $t0, 1 << 20
	SW $t0, IFS0CLR

	# Set duty cycle to zero 
	LI $t0, 0
	SW $t0, OC2RS
	SW $t0, OC3RS
	
	# Escapes the while loop
	LI $t1, 0
	
	LW $ra, 0($sp)
	LW $t0, 4($sp)
	ADDI $sp, $sp, 8

	EI
	ERET  
    .end timer_4_5_handler
.endif 



