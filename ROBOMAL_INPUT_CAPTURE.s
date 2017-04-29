.ifndef ROBOMAL_INPUT_CAPTURE
    ROBOMAL_INPUT_CAPTURE:    
    .Data
    left_count: .word 0
    right_count: .word 0
    n_count: .word 0
    .Text
    .ent setup_input_capture_2
	setup_input_capture_2:
	DI

	# Turn off input capture 2 RD9
	# IC2CON<15> = 0
	LI $t0, 1 << 15
	SW $t0, IC2CONCLR

	# Select clock source timer 2
	# IC2CON<7> = 1
	LI $t0, 1 << 7
	SW $t0, IC2CONSET

       # 16-Bit resource capture
       # IC2CON<8> = 0
       LI $t0, 1 << 8
       SW $t0, IC2CONCLR

       # Interrupt on every event
       # IC2CON<6:5> = 0b00
       LI $t0,  3 << 5
       SW $t0, IC2CONCLR

       # Edge Detection Mode 
       # IC2CON<2:0> = 0b011
       LI $t0, 7 
       SW $t0, IC2CONCLR

       LI $t0, 1
       SW $t0, IC2CONSET

       # *************************************************8
       # Set interrupt priority 
       # Disable interrupt
       # IEC0<9> = 0
       LI $t0, 1 << 9
       SW $t0, IEC0CLR

       # Set interrupt priority
       # IPC2<12:10> = 0b110
       LI $t0, 7 << 10
       SW $t0, IPC2CLR

       LI $t0, 6 << 10
       SW $t0, IPC2SET

       # Set interrupt priority 
       # Disable interrupt
       # IEC0<9> = 0
       LI $t0, 1 << 9
       SW $t0, IEC0SET

       EI  
       JR $ra
    .end setup_input_capture_2

    # .section defined in final_main
    .Text
    .ent input_capture_handler_2  
	input_capture_handler_2:
	    DI

	    ADDI $sp, $sp, -8
	    SW $ra, 0($sp)
	    SW $t0, 4($sp)

	    # Clear interrupt flag
	    # IFS0<9> = 0, Cleared interrupt flag
	    LI $t0, 1 << 9
	    SW $t0, IFS0CLR
	    
	    LW $t0, left_count # Load count value 
	    ADDI $t0, $t0, 1 # Add one to the right_count 
	    SW $t0, left_count # Update right_count	    
	    
	    LW $ra, 0($sp)
	    LW $t0, 4($sp)
	    ADDI $sp, $sp, 8

	    EI
	    ERET 
    .end input_capture_handler_2

    .ent setup_input_capture_3
	setup_input_capture_3:
	DI

	# Turn off input capture 1 RD6
	# IC3CON<15> = 0
	LI $t0, 1 << 15
	SW $t0, IC3CONCLR

	# Select clock source timer 2
	# IC3CON<7> = 1
	LI $t0, 1 << 7
	SW $t0, IC3CONSET

       # 16-Bit resource capture
       # IC3CON<8> = 0
       LI $t0, 1 << 8
       SW $t0, IC3CONCLR

       # Interrupt on every event
       # IC3CON<6:5> = 0b00
       LI $t0,  3 << 5
       SW $t0, IC3CONCLR

       # Edge Detection Mode 
       # IC3CON<2:0> = 0b011
       LI $t0, 7 
       SW $t0, IC3CONCLR

       LI $t0, 1
       SW $t0, IC3CONSET

       # *************************************************8
       # Set interrupt priority 
       # Disable interrupt
       # IEC0<13> = 0
       LI $t0, 1 << 13
       SW $t0, IEC0CLR

       # Set interrupt priority
       # IPC3<12:10> = 0b110
       LI $t0, 7 << 10
       SW $t0, IPC3CLR

       LI $t0, 6 << 10
       SW $t0, IPC3SET

       # Set interrupt priority 
       # Disable interrupt
       # IEC0<13> = 0
       LI $t0, 1 << 13
       SW $t0, IEC0SET

       EI  
       JR $ra
    .end setup_input_capture_3


    # .section definedin final_main
    .Text
    .ent input_capture_handler_3  
	input_capture_handler_3:
	    DI

	    ADDI $sp, $sp, -8
	    SW $ra, 0($sp)
	    SW $t0, 4($sp)
	    
	    # Clear interrupt flag
	    # IFS0<13> = 0, Cleared interrupt flag
	    LI $t0, 1 << 13
	    SW $t0, IFS0CLR
	   
	    LW $t0, right_count # Load count value 
	    ADDI $t0, $t0, 1 # Add one to the right_count 
	    SW $t0, right_count # Update right_count	    
	    
	    LW $ra, 0($sp)
	    LW $t0, 4($sp)
	    ADDI $sp, $sp, 8

	    EI
	    ERET 
    .end input_capture_handler_3

    .ent setup_timer_1
	setup_timer_1:
	DI

	# Turn off timer 1
	# TICON<15> = 0
	LI $t0, 1 << 15
	SW $t0, T1CONCLR

	# Select parent clock
	# T1CON<1> = 0, internal peripheral clock
	LI $t0, 1 << 1
	SW $t0, T1CONCLR

	# Set prescalar value 
	# T1CON<5:4> = 0b10 1:64
	LI $t0, 3 << 4
	SW $t0, T1CONCLR

	LI $t0, 2 << 4
	SW $t0, T1CONSET

	# Set the TMR1 to zero
	SW $zero, TMR1

	# Set the period register 
	# Peripheral Clock is running at 40MHz, Prescalar 64, Timer Running at 625000Hz
	# 
	LI $t0, 8000
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
	JR $ra
    .end setup_timer_1

     
    # .section defined in final_main
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
 	
	LW $t0, left_count # Load the left counter time
	MUL $t0, $t0, 10
	LW $t1, right_count # Load the right counter time
	MUL $t1, $t1, 10
	SW $zero, right_count # Reset the left counter
	SW $zero, left_count # Reset the right counter
	
	LW $t2, n_count # Increment the trial number for right
	ADDI $t2, $t2, 1 
	SW $t2, n_count
	
	LW $t2, n_count # Check if count is greater than 50
	SLT $t3, $t2, 5
	BNEZ $t3, endadjust # If 0 preceed if 1 jump to endadjust
	
	BEQ $t0, $t1, endadjust # If both timer count equal do not adjust 
	SLT $t0, $t0, $t1  # Check if the right count is greater
	BEQZ $t0, decrement # If left is not greater than right decrement 
	J increment
	
	increment:
	LW $t0, OC2R
	BEQ $t0, $t1, endadjust
	ADDI $t0, $t0, 20
	SW $t0, OC2RS
	J endadjust
	
	decrement:
	LW $t0, OC2R
	BEQ $t0, $t1, endadjust
	ADDI $t0, $t0, -20
	SW $t0, OC2RS
	
 	endadjust:
    
 	LW $ra, 0($sp)
 	LW $t0, 4($sp)
 	LW $t1, 8($sp)
	ADDI $sp, $sp, 12
 
 	EI
 	ERET
     .end timer_1_handler 
     
     .ent turn_on_input_capture
	turn_on_input_capture:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LI $t0, 1 << 15
	SW $t0, T1CONSET 
	SW $t0, IC2CONSET
	SW $t0, IC3CONSET
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end turn_on_input_capture
    
    .ent turn_off_input_capture
	turn_off_input_capture:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LI $t0, 1 << 15
	SW $t0, T1CONCLR 
	SW $zero, n_count
	SW $zero, left_count
	SW $zero, right_count
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end turn_off_input_capture
.endif
    
    





