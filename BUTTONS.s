.ifndef BUTTONS
BUTTONS:
    .ent setup_button
	setup_button:
	LI $t0, 3 << 6 # Shift 0b11 to bits 6,7 
	SW $t0, TRISASET # Set the TRISA registers bits 6,7 to one to make the pins inputs
	
	JR $ra
    .end setup_button
    
    .ent read_button 
	read_button:
	LW $t0, PORTA # Read port A
	LI $t1, 3 << 6 # Shift 0b11 to bits 6,7
	AND $t0, $t0, $t1 # Mask off its 6,7
	SRL $t0, $t0, 6 # Shift bits 6,7 to bits 0,1
	MOVE $v0, $t0 # Store in $v0 to return to main
	
	JR $ra
    .end read_button
    
    # Used for interrupts to prevents mutiple button presses
    .ent get_button
	get_button:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	    get_buttons: # Check if the button was pressed
		JAL read_button
		BEQZ $v0, get_buttons
		MOVE $v1, $v0
	    get_depress: # Returns the button press only if the button is released
		JAL read_button
		LI $t0, 3 
		BEQ $t0, $v0, get_both_depress # If both button are pressed before released jump to get_both_depress
		BNEZ $v0, get_depress
		J end_button
	    get_both_depress:
		JAL read_button
		LI $t0, 3 
		BNEZ $v0, get_both_depress # Keep interating until the buttons are released
		MOVE $v1, $t0 # Sets output to 0b11    
	end_button:
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end get_button
.endif







