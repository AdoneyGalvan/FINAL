.ifndef KEYPAD
KEYPAD:
    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     *
    # * Course: EE 234 Microprocessor Systems                                                                                   *
    # * Project: Calculator                                                                                                     *
    # * File: KEYPAD.s                                                                                                          *
    # * Subroutine: setup_keypad                                                                                                *
    # * Description: This function setups the keypad peripheral. The columns of the keypad are set as outputs and the rows as   *
    # * input. The keypad is read by driving the column to zero then reading each row for a button press. The keypad is connect-*
    # * as shown by the table.                                                                                                  *                   
    # * ChipKitPro | MCU PORT/Bit | Switch                                                                                      *
    # *    JA-01   |     RE00     |   COL4                                                                                      *
    # *    JA-02   |     RE01     |   COL3                                                                                      *
    # *    JA-03   |     RE02     |   COL2                                                                                      *
    # *    JA-04   |     RE03     |   COL1                                                                                      *
    # *    JA-07   |     RE04     |   ROW4                                                                                      *
    # *    JA-08   |     RD05     |   ROW3                                                                                      *
    # *    JA-09   |     RE06     |   ROW2                                                                                      *
    # *    JA-10   |     RE07     |   ROW1                                                                                      *                                                                     
    # * Inputs: None                                                                                                            *
    # * Outputs: None                                                                                                           *
    # * Computations:                                                                                                           *
    # *                                                                                                                         *
    # * Revision History: 2/13/2017                                                                                             *
    # ***************************************************************************************************************************
    .ent setup_keypad
	setup_keypad:
	    LI $t0, 0xF # Loads the immediate value 0xF0
	    SW $t0, TRISECLR # Stores the immediate value 0xF0 to clear the bit values in bits 7,6,5,4 to set as outputs
	    LI $t0, 0xF0 # Loads the immediate value 0xF
	    SW $t0, TRISESET # Stores the immediate value 0xF to set the bits values in bits 0,1,2,3 to set as inputs
	    JR $ra
    .end setup_keypad

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     *
    # * Course: EE 234 Microprocessor Systems                                                                                   *
    # * Project: Calculator                                                                                                     *
    # * File: KEYPAD.s                                                                                                          *
    # * Subroutine: read_keypad                                                                                                 *
    # * Description: This function reads the state of the keypad by driving the corresponding column to zero and the other three*
    # * one. Then reading the row for the for each button. The function returns the register which holds 1 in the numeric place.*
    # * If button nine is pressed the function will return a register with a 1 in bit 8 indicating button was pressed. The      *
    # * function also returns the binary representation of the button pressed. If two buttons are pressed the larger of to value*
    # * will be used.                                                                                                           *                                                                                                      *                                                                     
    # * Inputs: None                                                                                                            *
    # * Outputs: $t1 - Returns a one in the bit corresponding to the button that was pressed                                    8
    # *          $t2 - Returns the binary representation of the button press                                                    *
    # * Computations:                                                                                                           *
    # *                                                                                                                         *
    # * Revision History: 2/13/2017                                                                                             *
    # ***************************************************************************************************************************
    .ent read_keypad
	read_keypad:
	    # Read One
	    LI $t0, 0x8 # Will drive column 1 to zero
	    SW $t0, LATECLR # Driving column 1 to zero
	    LI $t0, 0x7 # Will drive column 2,3,4 to one
	    SW $t0, LATESET # Driving column 2,3,4 to one
	    LW $t0, PORTE # Read PORTE 
	    NOT $t0, $t0 # Inverts the PORTE 
	    AND $t0, $t0, 0x80 # Mask off bit 7 for row 1
	    SRL $t0, $t0, 6 # Right shift 6 to move it to bit 1
	    MOVE $t1, $t0 

	    # Read Four
	    LI $t0, 0x8 # Will drive column 1 to zero
	    SW $t0, LATECLR # Driving column 1 to zero
	    LI $t0, 0x7 # Will drive column 2,3,4 to one
	    SW $t0, LATESET # Driving column 2,3,4 to one
	    LW $t0, PORTE # Read PORTE 
	    NOT $t0, $t0 # Inverts the PORTE 
	    AND $t0, $t0, 0x40 # Mask off bit 6 for row 2
	    SRL $t0, $t0, 2 # Right shift 2 to move it to bit 4
	    ADD $t1, $t0, $t1

	    # Read Seven 
	    LI $t0, 0x8 # Will drive column 1 to zero
	    SW $t0, LATECLR # Driving column 1 to zero
	    LI $t0, 0x7 # Will drive column 2,3,4 to one
	    SW $t0, LATESET # Driving column 2,3,4 to one
	    LW $t0, PORTE # Read PORTE 
	    NOT $t0, $t0 # Inverts the PORTE 
	    AND $t0, $t0, 0x20 # Mask off bit 5 for row 3
	    SLL $t0, $t0, 2 # Left shift 2 to move it to bit 7
	    ADD $t1, $t0, $t1

	    # Read Zero
	    LI $t0, 0x8 # Will drive column 1 to zero
	    SW $t0, LATECLR # Driving column 1 to zero
	    LI $t0, 0x7 # Will drive column 2,3,4 to one
	    SW $t0, LATESET # Driving column 2,3,4 to one
	    LW $t0, PORTE # Read PORTE 
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x10 # Mask off bit 4 for row 4 
	    SRL $t0, $t0, 4 # Right shift 4 to move it to bit 0
	    ADD $t1, $t0, $t1  

	    # Read Two
	    LI $t0, 0x4 # Will drive column 2 to zero
	    SW $t0, LATECLR # Driving column 2 to zero
	    LI $t0, 0xB # Will drive column 1,3,4 to one
	    SW $t0, LATESET # Driving column 1,3,4 to one
	    LW $t0, PORTE # Read PORTE 
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x80 # Mask off bit 7 for row 1
	    SRL $t0, $t0, 5 # Right shift 5 to move it to bit 2
	    ADD $t1, $t0, $t1

	    # Read Five 
	    LI $t0, 0x4 # Will drive column 2 to zero
	    SW $t0, LATECLR # Driving column 2 to zero
	    LI $t0, 0xB # Will drive column 1,3,4 to one
	    SW $t0, LATESET # Driving column 1,3,4 to one
	    LW $t0, PORTE # Read PORTE 
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x40 # Mask off bit 6 for row 2
	    SRL $t0, $t0, 1 # Right shift 1 to move it to bit 5
	    ADD $t1, $t0, $t1

	    # Read Eight
	    LI $t0, 0x4 # Will drive column 2 to zero
	    SW $t0, LATECLR # Driving column 2 to zero
	    LI $t0, 0xB # Will drive column 1,3,4 to one
	    SW $t0, LATESET # Driving column 1,3,4 to one
	    LW $t0, PORTE # Read PORTE 
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x20 # Mask off bit 5 for row 3
	    SLL $t0, $t0, 3 # Left shift 3 to move it to bit 8
	    ADD $t1, $t0, $t1

	    # Read F 
	    LI $t0, 0x4 # Will drive column 2 to zero
	    SW $t0, LATECLR # Driving column 2 to zero
	    LI $t0, 0xB # Will drive column 1,3,4 to one
	    SW $t0, LATESET # Driving column 1,3,4 to one
	    LW $t0, PORTE # Read PORTE 
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x10 # Mask off bit 4 for row 4 
	    SLL $t0, $t0, 11 # Left shift 11 to move it to bit 16
	    ADD $t1, $t0, $t1  

	    # Read Three 
	    LI $t0, 0x2 # Will drive column 3 to zero
	    SW $t0, LATECLR # Driving column 3 to zero
	    LI $t0, 0xD # Will drive column 1,2,4 to one
	    SW $t0, LATESET # Driving column 1,2,4 to one
	    LW $t0, PORTE # Read PORTE
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x80 # Mask off bit 7 for row 1
	    SRL $t0, $t0, 4 # Right shift 4 to move it to bit 3
	    ADD $t1, $t0, $t1

	    # Read Six
	    LI $t0, 0x2 # Will drive column 3 to zero
	    SW $t0, LATECLR # Driving column 3 to zero
	    LI $t0, 0xD # Will drive column 1,2,4 to one
	    SW $t0, LATESET # Driving column 1,2,4 to one
	    LW $t0, PORTE # Read PORTE
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x40 # Mask off bit 6 for row 2
	    ADD $t1, $t0, $t1

	    # Read Nine 
	    LI $t0, 0x2 # Will drive column 3 to zero
	    SW $t0, LATECLR # Driving column 3 to zero
	    LI $t0, 0xD # Will drive column 1,2,4 to one
	    SW $t0, LATESET # Driving column 1,2,4 to one
	    LW $t0, PORTE # Read PORTE
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x20 # Mask off bit 5 for row 3
	    SLL $t0, $t0, 4 # Right shift 4 to move it to bit 9
	    ADD $t1, $t0, $t1

	    # Read E
	    LI $t0, 0x2 # Will drive column 3 to zero
	    SW $t0, LATECLR # Driving column 3 to zero
	    LI $t0, 0xD # Will drive column 1,2,4 to one
	    SW $t0, LATESET # Driving column 1,2,4 to one
	    LW $t0, PORTE # Read PORTE
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x10 # Mask off bit 4 for row 4 
	    SLL $t0, $t0, 10 # Left shift 10 to move it to bit 15
	    ADD $t1, $t0, $t1  

	    # Read A
	    LI $t0, 0x1 # Will drive column 3 to zero
	    SW $t0, LATECLR # Driving column 3 to zero
	    LI $t0, 0xE # Will drive column 1,2,4 to one
	    SW $t0, LATESET # Driving column 1,2,4 to one
	    LW $t0, PORTE # Read PORTE
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x80 # Mask off bit 7 for row 1
	    SLL $t0, $t0, 3 # Left shift 3 to move it to bit 10
	    ADD $t1, $t0, $t1

	    # Read B
	    LI $t0, 0x1 # Will drive column 3 to zero
	    SW $t0, LATECLR # Driving column 3 to zero
	    LI $t0, 0xE # Will drive column 1,2,4 to one
	    SW $t0, LATESET # Driving column 1,2,4 to one
	    LW $t0, PORTE # Read PORTE
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x40 # Mask off bit 6 for row 2
	    SLL $t0, $t0, 5 # Leftt shift 5 to move it to bit 11
	    ADD $t1, $t0, $t1

	    # Read C
	    LI $t0, 0x1 # Will drive column 3 to zero
	    SW $t0, LATECLR # Driving column 3 to zero
	    LI $t0, 0xE # Will drive column 1,2,4 to one
	    SW $t0, LATESET # Driving column 1,2,4 to one
	    LW $t0, PORTE # Read PORTE
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x20 # Mask off bit 5 for row 3
	    SLL $t0, $t0, 7 # Left shift 7 to move it to bit 12
	    ADD $t1, $t0, $t1

	    # Read D 
	    LI $t0, 0x1 # Will drive column 3 to zero
	    SW $t0, LATECLR # Driving column 3 to zero
	    LI $t0, 0xE # Will drive column 1,2,4 to one
	    SW $t0, LATESET # Driving column 1,2,4 to one
	    LW $t0, PORTE # Read PORTE
	    NOT $t0, $t0 # Inverts the PORTE
	    AND $t0, $t0, 0x10 # Mask off bit 4 for row 4 
	    SLL $t0, $t0, 9 # Left shift 9 to move it to bit 13
	    ADD $t1, $t0, $t1  



	    # Checks if button zero was pressed and stores the binary representation in $t2
	    BNE $t1, 0x1, end_zero
	    LI $t2, 0
	    end_zero:

	    # Checks if button one was pressed and stores the binary representation in $t2
	    BNE $t1, 0x2, end_one
	    LI $t2, 1
	    end_one:

	    # Checks if button two was pressed and stores the binary representation in $t2
	    BNE $t1, 0x4, end_two
	    LI $t2, 2
	    end_two:

	    # Checks if button three was pressed and stores the binary representation in $t2
	    BNE $t1, 0x8, end_three
	    LI $t2, 3
	    end_three:

	    # Checks if button four was pressed and stores the binary representation in $t2
	    BNE $t1, 0x10, end_four
	    LI $t2, 4
	    end_four:

	    # Checks if button five was pressed and stores the binary representation in $t2
	    BNE $t1, 0x20, end_five
	    LI $t2, 5
	    end_five:

	    # Checks if button six was pressed and stores the binary representation in $t2
	    BNE $t1, 0x40, end_six
	    LI $t2, 6
	    end_six:


	    # Checks if button seven was pressed and stores the binary representation in $t2
	    BNE $t1, 0x80, end_seven
	    LI $t2, 7
	    end_seven:

	    # Checks if button eight was pressed and stores the binary representation in $t2
	    BNE $t1, 0x100, end_eight
	    LI $t2, 8
	    end_eight:

	    # Checks if button nine was pressed and stores the binary representation in $t2
	    BNE $t1, 0x200, end_nine
	    LI $t2, 9
	    end_nine:


	    # Checks if button A was pressed and stores the binary representation in $t2
	    BNE $t1, 0x400, end_A
	    LI $t2, 0xA
	    end_A:

	    # Checks if button B was pressed and stores the binary representation in $t2
	    BNE $t1, 0x800, end_B
	    LI $t2, 0xB
	    end_B:


	    # Checks if button C was pressed and stores the binary representation in $t2
	    BNE $t1, 0x1000, end_C
	    LI $t2, 0xC
	    end_C:

	    # Checks if button D was pressed and stores the binary representation in $t2
	    BNE $t1, 0x2000, end_D
	    LI $t2, 0xD
	    end_D:

	    # Checks if button E was pressed and stores the binary representation in $t2
	    BNE $t1, 0x4000, end_E
	    LI $t2, 0xE
	    end_E:

	    # Checks if button F was pressed and stores the binary representation in $t2
	    BNE $t1, 0x8000, end_F
	    LI $t2, 0xF
	    end_F:

	    MOVE $v0, $t1 # Returns a one in the bit corresponding to the button that was pressed
	    MOVE $v1, $t2 # Returns the binary representation of the button press

	    JR $ra
    .end read_keypad
.endif 




