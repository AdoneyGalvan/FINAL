.ifndef GENERAL_LED
    GENERAL_LED:
	# ***************************************************************************************************************************
	# * Author: Aron Galvan                                                                                                     *
	# * Course: EE 234 Microprocessor Systems                                                                                   *
	# * Project: Calculator                                                                                                     *
	# * File: LED.s                                                                                                             *
	# * Subroutine: setup_led                                                                                                   *
	# * Description: This function setups the onboard digilent LEDs as output. The function sets the the TRISBCLR register      *
	# * to 0 on pins 13,12,11,10, then writes to LATBCLR to intialize the LEDsif off state                                      *
	# * ChipKitPro | MCU PORT/Bit | Switch                                                                                      *
	# *    JK-01   |     RB10     |   LD1                                                                                       *
	# *    JK-02   |     RB11     |   LD2                                                                                       *
	# *    JK-03   |     RB12     |   LD3                                                                                       *
	# *    JK-04   |     RB13     |   LD4                                                                                       *                                                                                                                   *
	# * Inputs: None                                                                                                            *
	# * Outputs: None                                                                                                           *
	# * Computations:                                                                                                           *
	# *                                                                                                                         *
	# * Revision History: 2/13/2017                                                                                             *
	# ***************************************************************************************************************************
	.ent setup_led
	    setup_led:
		LI $t0, 0x3C00 # Loads the immediate value 0x3C00
		SW $t0, TRISBCLR # Stores the immediate value 0x3C00 to clear the bit values in bits 13,12,11,10 in PORTB as outputs
		SW $t0, LATBCLR # Starts the LED's in the off state 
		JR $ra
	.end setup_led

	# ***************************************************************************************************************************
	# * Author: Aron Galvan                                                                                                     *
	# * Course: EE 234 Microprocessor Systems                                                                                   *
	# * Project: Calculator                                                                                                     *
	# * File: LED.s                                                                                                             *
	# * Subroutine: write_to_led                                                                                                *                                                                                                           *
	# * Description: This function write to the onboard leds on PORTB, pins 10,11,12,13. The function mask of the first four    *
	# * of the input register $a0 and then shift the bits by ten to align with the LED, PORTB pins.                             *
	# *                                                                                                                         *
	# * Inputs: $a0 - Register containing the four bit to be written to the LEDs                                                *                                                                    *
	# * Outputs: None                                                                                                           *
	# * Computations:                                                                                                           *
	# *                                                                                                                         *
	# * Revision History: 2/13/2017                                                                                             *
	# ***************************************************************************************************************************
	.ent write_to_led
	    write_to_led:
		MOVE $t0, $a0
		AND $t0, $t0, 0xF # Mask off all the bits except first four
		SLL $t0, $t0, 10  # Shift the first for bits over 10 and align with led outpu bits
		SW $t0, LATB # Write the shited value to the LATB
		JR $ra
	.end write_to_led

	# ***************************************************************************************************************************
	# * Author: Aron Galvan                                                                                                     *
	# * Course: EE 234 Microprocessor Systems                                                                                   *
	# * Project: Calculator                                                                                                     *
	# * File: CAL.s                                                                                                             *
	# * Subroutine: delay                                                                                                       *                                                                                                           *
	# * Description: This function delays the execution of an instruction. The function delays the execution of an instruction  *
	# * by decrementing a given value until the zero is reached.                                                                *
	# *                                                                                                                         *
	# * Inputs: $a0 - The delay time or sum                                                                                     *
	# * Outputs: None                                                                                                           *
	# * Computations: Subtraction, used to decrement the counter                                                                *
	# *                                                                                                                         *
	# * Revision History: 2/13/2017                                                                                             *
	# ***************************************************************************************************************************
	.ent delay
	    delay:
	    MOVE $t0, $a0
	    delay_loop:
		BEQZ $t0, end_delay # Checks if $t0 is equal to zero
		ADDI $t0, $t0, -1 # Decrements the counter
		J delay_loop # Jumps back to the loop
	    end_delay:
	    JR $ra
	.end delay
.endif 
