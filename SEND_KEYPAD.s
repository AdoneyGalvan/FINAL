.ifndef SEND_KEYPAD
SEND_KEYPAD:  
    .include "KEYPAD.s"
    .include "GENERAL_UART2.s"
    .include "GENERAL_UART1.s"
    .include "BUTTONS.s"
    .Data
     clear: .byte 0x1B, '[', 'j', 0x00
     keypad_mode: .asciiz "Keypad Mode :)"
    instruction: .asciiz "Instru:"
    counter_hex: .word 0
    .Text
    .ent MAIN_KEYPAD
	MAIN_KEYPAD:
	JAL setup_keypad
	JAL setup_UART1
	JAL setup_UART2
	JAL setup_button
	
	LA $a0, instruction
	JAL send_char_arr_to_UART1
	while_keypad:
	LW $t1, counter_hex
	ADDI $t1, $t1, 1
	SW $t1, counter_hex
	JAL get_button
	JAL read_keypad
	MOVE $a0, $v1
	JAL decimal_to_ascii
	MOVE $s1, $v0
	MOVE $a0, $s1
	JAL send_byte_to_UART1
	MOVE $a0, $s1
	JAL send_byte_to_UART2
	LI $t0, 6
	LW $t1, counter_hex
	BEQ $t0, $t1, clear_instruc
	JAL while_keypad
	
	clear_instruc:
	LA $a0, clear
	JAL send_char_arr_to_UART1
	LA $a0, instruction
	JAL send_char_arr_to_UART1
	MOVE $a0, $s1
	JAL send_byte_to_UART1
	SW $zero, counter_hex
	JAL while_keypad
	
    .end MAIN_KEYPAD
    
    .ent decimal_to_ascii
	decimal_to_ascii:
    ADDI $sp, $sp, -4
    SW $ra, 0($sp)

    MOVE $t0, $a0	# moves input to temp reg
    LI $t1, 48
    ADD $t0, $t0, $t1 # Ad 48 to get asciis

    LI $t1, 58 # if less than A, return to caller
    SLTU $t1, $t0, $t1 # If $t0 is greater than 57 add 7 more 
    bgtz $t1, return # skips if 0-9

    LI $t1, 7
    ADD $t0, $t0, $t1	# if greater than A, add 7 more

    return:
    # moves to output
    MOVE $v0, $t0
    
    LW $ra, 0($sp)
    ADDI $sp, $sp, 4
    jr $ra  
.end decimal_to_ascii
.endif

