.ifndef GENERAL_MOTORS
    GENERAL_MOTORS:
    .Text
    # Left Motor JD Top
    # Right Motor JD Bottom
    # writes to motors individually
    # a0 - duty cylce of right motor
    # a1 - duty cycle of left motor
    .ent write_to_motors
	write_to_motors:
	# pops on stack
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)

	# takes duty cycle as input for each motor
	move $s0, $a0	# left duty cycle
	move $s1, $a1	# right duty cycle

	# writes to motors
	sw $s0, OC2RS
	sw $s1, OC3RS

	# pops off stack
	lw $ra, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 12

	jr $ra
    .end write_to_motors
	
    .ent motor_timer
	motor_timer:
	# Setup timer 2 as the clock source for the output compare
	# 1) Turn off Global interrupts
	# 2) Turn mulit vector mode
	# 3) Turn off timer 2
	# 4) Set as a 16-bit timer
	# 5) Select the prescalar value of the peripheral clock
	# 6) Set the timer 2 register to zero
	# 7) Set the period register of timer 2

	EI
	# Setup multi vector mode (enabling interrupt vector table)
	# INTCON<12> = 1 for multi vector mode
	LI $t0, 1 << 12
	SW $t0, INTCONSET

	# Turn off timer 2
	LI $t0, 1 << 15
	SW $t0, T2CONCLR

	# Setting up timer 2 as a 16 bit 
	# T2CON<3> = 0, 16-bit Timer Mode Select Bit
	LI $t0, 1 << 3
	SW $t0, T2CONCLR

	# Selecting the parent clock for the timer 
	# T2CON<1> = 0, Internal peripheral clock
	LI $t0, 1 << 1
	SW $t0, T2CONCLR

	# Setting the prescalar value for the peripheral clock
	# T2CON<6:4> = 0b001, 2 prescalar value
	LI $t0, 7 << 4
	SW $t0, T2CONCLR
	LI $t0, 1 << 4
	SW $t0, T2CONSET

	# Setting the counter timer count register to 0
	SW $zero, TMR2

	# Set the period register value
	# CLK = 40Mhz, prescalar = 2, TimerCLK = (40Mhz/2)
	LI $t0, 999
	SW $t0, PR2

	# Turn on timer 2
	LI $t0, 1 << 15
	SW $t0, T2CONSET 
	EI
	JR $ra
    .end motor_timer
	
    .ent left_motor
	left_motor:
	# Setup output compare 2 
	# 1) Set the corresponding TRIS pins as outputs
	# 2) Turn off the output compare module
	# 3) Set the OC2R register for the desired duty cycle
	# 4) Set the OCR2S buffer register for the desired duty cycle
	# 5) Select the output compare mode 
	# 6) Select timer 2 as clock source
	# 7) Select 16-bit compare mode
	# 8) Turn on output compare 2 module 
	# 9) Set the priority for output compare 2 interrupt
	# 10) Enable output compare interrupt
	# 11) Enable global interrupts

	DI # Turning off all external interrupts 

	# **************************************************************************
	# Setting up output capture 2 
	# Set TRISD pins 7 an 1 as output, pin 7 direction, pin 1 enable 
	SW $zero, LATD
	LI $t0, 1 << 1
	SW $t0, TRISDCLR

	LI $t0, 1 << 7
	SW $t0, TRISDCLR

	# Turn off output compare module 2
	# OC2CON<15> = 0
	LI $t0, 1 << 15
	SW $t0, OC2CONCLR

	# Setting the duty cycle of the motor
	# Set register OC2R to 0
	LI $t0, 0
	SW $t0, OC2R

	# Setting the duty cycle of the motor
	# Set butter register OC2RS to 0
	LI $t0, 0
	SW $t0, OC2RS

	# Selecting timer 2 as the clock source
	# OC2CON<3> = 0
	LI $t0, 1 << 3
	SW $t0, OC2CONCLR

	# Selecting the operation mode or
	# OC2CON<2:0> = 0b110
	LI $t0, 7
	SW $t0, OC2CONCLR

	LI $t0, 6
	SW $t0, OC2CONSET

	# Selecting compare mode for the output compare module
	# OC2CON<5> = 0
	LI $t0, 1
	SW $t0, OC2CONCLR

	# Turn on output compare module 2
	# OC2CON<15> = 1
	LI $t0, 1 << 15
	SW $t0, OC2CONSET

	# Set the priority for the output compare interrupt 
	# IPC2<20:18> = 0b110
	LI $t0, 7 << 18
	SW $t0, IPC2CLR

	LI $t0, 6 << 18
	SW $t0, IPC2SET

	# Enable the output compare interrupt
	# IEC0<10> = 1
	LI $t0, 1 << 10
	SW $t0, IEC0SET

	EI
	JR $ra
    .end left_motor

    .ent right_motor
	right_motor:
	# Setup output compare 3 
	# 1) Set the corresponding TRIS pins as outputs
	# 2) Turn off the output compare module
	# 3) Set the OCR3 register for the desired duty cycle
	# 4) Set the OCR3S buffer register for the desired duty cycle
	# 5) Select the output compare mode 
	# 6) Select timer 3 as clock source
	# 7) Select 16-bit compare mode
	# 8) Turn on output compare 3 module 
	# 9) Set the priority for output compare 3 interrupt
	# 10) Enable output compare interrupt
	# 11) Enable global interrupts

	DI # Turning off all external interrupts 

	# Setup multi vector mode (enabling interrupt vector table)
	# INTCON<12> = 1 for multi vector mode
	LI $t0, 1 << 12
	SW $t0, INTCONSET

	# **************************************************************************
	# Setting up output capture 3 
	# Set TRISD pins 6 and 2 as output, pin 6 direction, pin 2 enable 
	SW $zero, LATD
	LI $t0, 1 << 2
	SW $t0, TRISDCLR

	LI $t0, 1 << 6
	SW $t0, TRISDCLR

	# Turn off output compare module 3
	# OC3CON<15> = 0
	LI $t0, 1 << 15
	SW $t0, OC3CONCLR

	# Setting the duty cycle of the motor
	# Set register OC3R to 0
	LI $t0, 0
	SW $t0, OC3R

	# Setting the duty cycle of the motor
	# Set butter register OC2RS to 0
	LI $t0, 0
	SW $t0, OC3RS

	# Selecting timer 2 as the clock source
	# OC3CON<3> = 0
	LI $t0, 1 << 3
	SW $t0, OC3CONCLR

	# Selecting the operation mode or
	# OC3CON<2:0> = 0b110
	LI $t0, 7
	SW $t0, OC3CONCLR

	LI $t0, 6
	SW $t0, OC3CONSET

	# Selecting compare mode for the output compare module
	# OC3CON<5> = 0
	LI $t0, 1
	SW $t0, OC3CONCLR

	# Turn on output compare module 2
	# OC3CON<15> = 1
	LI $t0, 1 << 15
	SW $t0, OC3CONSET

	# Set the priority for the output compare interrupt 
	# IPC3<20:18> = 0b110
	LI $t0, 7 << 18
	SW $t0, IPC3CLR

	LI $t0, 6 << 18
	SW $t0, IPC3SET

	# Enable the output compare interrupt
	# IEC0<14> = 1
	LI $t0, 1 << 14
	SW $t0, IEC0SET

	EI
	JR $ra
    .end right_motor
.endif
    
    



