.ifndef SWITCH
SWITCH:    
    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     *
    # * Course: EE 234 Microprocessor Systems                                                                                   *
    # * Project: Calculator                                                                                                     *
    # * File: SWITCHS.s                                                                                                         *
    # * Subroutine: setup_switch                                                                                                *
    # * Description: This function setups the switch peripheral as inputs to the board. The function sets the TRISESET register *
    # * to 1 for PORTE pin 8, PORTD pin 1,8,13.                                                                                 *
    # * ChipKitPro | MCU PORT/Bit | Switch                                                                                      *
    # *    JH-07   |     RE08     |   SW1                                                                                       *
    # *    JH-08   |     RD00     |   SW2                                                                                       *
    # *    JH-09   |     RD08     |   SW3                                                                                       *
    # *    JH-10   |     RD13     |   SW4                                                                                       *
    # * Inputs: None                                                                                                            *
    # * Outputs: None                                                                                                           *
    # * Computations:                                                                                                           *
    # *                                                                                                                         *
    # * Revision History: 2/13/2017                                                                                             *
    # ***************************************************************************************************************************
    .ent setup_switch
	setup_switch:
	    LI $t0, 0x100
	    SW $t0, TRISESET
	    LI $t0, 0x2101
	    SW $t0, TRISDSET
	    JR $ra
    .end setup_switch

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     *
    # * Course: EE 234 Microprocessor Systems                                                                                   *
    # * Project: Calculator                                                                                                     *
    # * File: SWITCHS.s                                                                                                         *
    # * Subroutine: setup_switch                                                                                                *
    # * Description: This function reads the switch state at each PORTE, PORTD, and there corresponding pins. The function then *
    # * compresses the switch states read into four bits, by shift the corresponding bit into it switch location.               *
    # *                                                                                                                         *
    # * Inputs: None                                                                                                            *
    # * Outputs: $v0 - Hold the four bit representation of the switch states                                                    *
    # * Computations:                                                                                                           *
    # *                                                                                                                         *
    # * Revision History: 2/13/2017                                                                                             *
    # ***************************************************************************************************************************
    .ent read_switch
       read_switch:
    # Switch One
	    LW $t0, PORTE  # Read port E
	    AND $t0, $t0, 0x100 # Mask off bit 8
	    SRL $t0, $t0, 8 # Right shift the bit to the bit 0
	    MOVE $t1, $t0   # Moves the current switch into $t1 which will keep a running switch state value
    # Switch Two   
	    LW $t0, PORTD
	    AND $t0, $t0, 0x1 # Mask off bit 0
	    SLL $t0, $t0, 1 # Left shift the bit to bit 1
	    ADD $t1, $t0, $t1 # Adds it to $t1
    # Switch Three	
	    LW $t0, PORTD
	    AND $t0, $t0, 0x0100 # Mask off bit 8
	    SRL $t0, $t0, 6 # Right shift the bit to bit 2
	    ADD $t1, $t0, $t1 # Adds it to $t1
    # Switch Four 
	    LW $t0, PORTD
	    AND $t0, $t0, 0x2000 # Mask off bit 13
	    SRL $t0, $t0, 10 # Right shift the bit to bit 3
	    ADD $t1, $t0, $t1 # Adds it to $t1

	    MOVE $v0, $t1
	    JR $ra
    .end read_switch
.endif 



