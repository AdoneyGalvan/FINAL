.ifndef ROBOMAL
    ROBOMAL:
# ***************************************************************************************************************************
# * Author: Aron Galvan                                                                                                     
# * Course: EE 234 Microprocessor Systems                                                                                   
# * Project: ROBOMAL                                                                                                        
# * File: ROBOMAL.s                                                                                                                                                                                                                *
# * Description: This program simulates the general three stage process of a microprocessor, fetch, decode, and execute.                                       
# *              The instruction consist of four hex values, where the most signficant hex value is the, family operations  
# *              the instruction belongs to. The second most signficant hex value indicates, what operation to perform      
# *		 within the given family. Finally the last to hex values are resevered for data/operands depending on the   
# *		 operation. Some of the CPU registers are strictly defined to maintain consistency in the program.          
# *		  | Register |    Usage                                                                                     
# *                    $s0      Accumulator                                                                                 
# *                    $s1      Instruction Counter                                                                         
# *                    $s2      Instruction Register                                                                        
# *                    $s3      Operation Code                                                                              
# *                    $s4      Operand                                                                                     
# *                    $s5      Modulus of multiplication                                                                   
# *                    $s6      Address of program_counter                                                                                                                                    
# *                    $a0      Arguments between subroutines                                                               
# *                  $v0-$v1    Returned Parameters		                                                            								  
# *Revision History: 3/2/2017                                                                                               
# ***************************************************************************************************************************
    # ROBOMAL includes
    .include "ROBOMAL_DATAOPS.s"
    .include "ROBOMAL_BRANCHOPS.s"
    .include "ROBOMAL_CONTROLOPS.s"
    .include "ROBOMAL_MATHOPS.s"
    .include "ROBOMAL_BRAKE_TIMER.s"
    # General includes
    .include "GENERAL_LEDS.s" 
    .include "GENERAL_MOTORS.s"
    .include "GENERAL_UART1.s"
    .include "GENERAL_UART2.s"
    .include "GENERAL_SENSORS.s"
    
.Data
    # ***********************************************************************************************************************************************                                           																	    
    # *| HEX-VALUES |   FAMILY    |  OPERATION													    
    # *    110000       control_ops   ROBO_LEFT													    
    # *    120000       control_ops   ROBO_RIGHT													    
    # *    130000       control_ops   ROBO_FORWARD												    
    # *    140000       control_ops   ROBO_BACKWARD												    
    # *    150000       control_ops   ROBO_BRAKE													    
    # *    210000       branch_ops    ROBO_JUMP													    
    # *    220000       branch_ops    ROBO_BEQZ													    
    # *    230000       branch_ops    ROBO_BNEZ													    
    # *    240000       branch_ops    ROBO_HALT													    
    # * etc......																    
    # ***********************************************************************************************************************************************
    program_counter: .word 0
    instructions:.space 200
    
    control_ops: .word ROBO_LEFT, ROBO_RIGHT, ROBO_FORWARD, ROBO_BACKWARD, ROBO_BRAKE, READ_SENSOR
    branch_ops: .word ROBO_JUMP, ROBO_BEQZ, ROBO_BNEZ, ROBO_HALT
    data_ops: .word ROBO_READ, ROBO_WRITE, ROBO_LOAD, ROBO_STORE, ROBO_LOADI
    math_ops: .word ROBO_ADD, ROBO_SUB, ROBO_MUL
.Text
.ent ROBO_MAIN
    ROBO_MAIN:
	SW $zero, LATDSET
	
	# LEDs
	JAL setup_led
	
	# Motor Setup Functions
	JAL left_motor # Configures the left motor output compare 
	JAL right_motor # Configures the right motot output compare
	JAL motor_timer # Configures timer 2 which clocks the output compares
	JAL brake_timer_setup # Configures a 32 bit timer using timers 4 and 5
	JAL setup_input_capture_2 # Configures input capture for left motor 
	JAL setup_input_capture_3 # Configures input capture for right motor 
	JAL setup_timer_1 # Configures a 16-bit timer using timer 1, for adjust the motor duty cycles
	# Infrared 
	JAL setup_sensor # Sets up the infrared sensors 
	
	# UARTs 
	JAL setup_UART1 # Configures UART1 to receive data via bluetooth 
	JAL setup_UART2 # Configures UART2 to send data to LCD

	upload_instructions:
	LA $a3, upload_instructions
	# get switch states
	lw $t0, PORTA
	# mask bits
	andi $t1, $t0, 0xC000
	andi $t2, $t0, 0xC0
	# shift to position
	sra $t1, $t1, 14
	sra $t2, $t2, 4
	or $t0, $t1, $t2
	BEQ $t0, 1, continue_upload
	JR $s7 # Jump back to main program loop, final loop
	continue_upload:
	# a3 = address of upload 
	LA $a3, upload_instructions
	SW $zero, program_counter
	JAL place_instructions
	 # get switch states

	NOP
	
	
	while:
	JAL fetch 

	MOVE $a0, $v0 # Move fetched instruction into $a0 pass to decode
	JAL decode

	MOVE $a0, $v0 # Move the address of the operation into $a0 pass to execute
	MOVE $a1, $v1 # Move the data pass to execute
	JAL execute

	J while
.end ROBO_MAIN

# ***************************************************************************************************************************
# * Author: Aron Galvan                                                                                                     
# * Course: EE 234 Microprocessor Systems                                                                                   
# * Project: ROBOMAL                                                                                                        
# * File: ROBOMAL.s                                                                                                         
# * Subroutine: fetch                                                                                                       
# * Description: This function fetches the intsruction to be executed in the ROBOMAL program, then increments the program   
# * by one to indictate the instruction was fetched                                                                         
# * Inputs: None                                                                                                            
# * Outputs: $v0 - The ROBOMAL instruction fetched                                                                          
# * Computations: Increments the program counter by 1                                                                       
# *                                                                                                                         
# * Revision History: 3/2/2017                                                                                              
# ***************************************************************************************************************************
.ent fetch
    fetch:
    LW $s1, program_counter # Loads the value of the program counter
    LA $t1, instructions # Loads the address of the instruction
    SLL $t0, $s1, 2 # Multiply the value of the program counter by 4 
    ADD $t0, $t0, $t1 # Adding the multiply value to address of instruction
    LW $v0, 0($t0) # Loads the instruction into $v0
    LW $s2, 0($t0) # Store the instruction into $s2
    ADD $s1, $s1, 1 # Increments the program counter
    SW $s1, program_counter # Store the value of the program counter into $s1
    
    JR $ra
.end fetch
 
# ***************************************************************************************************************************
# * Author: Aron Galvan                                                                                                     
# * Course: EE 234 Microprocessor Systems                                                                                   
# * Project: ROBOMAL                                                                                                        
# * File: ROBOMAL.s                                                                                                         
# * Subroutine: decode                                                                                                      
# * Description: This function decodes the instruction fected into its consituent parts, family, operation, and operands.   
# * Inputs: $a0 - The ROBOMAL instruction to decode                                                                         
# * Outputs: $v0 - The ROBOMAL operation, the address of the operation                                                      
# *          $v1 - The operands of the ROBOMAL instruction                                                                  
# * Computations: None                                                                                                      
# *                                                                                                                         
# * Revision History: 3/2/2017                                                                                              
# ***************************************************************************************************************************
.ent decode
    decode:
    LI $t0, 0xF00000
    AND $t3, $a0, $t0 # Mask off family
    LI $t0, 0x0F0000
    AND $t4, $a0, $t0 # Mask off the operation 
    LI $t0, 0x00FFFF
    AND $t5, $a0, $t0 # Mask of the last 16 bits 
    
    
    ADD $s3, $t3, $t4 # Stores the opcode 
    MOVE $v1, $t5 # Stores the data section of the command
    MOVE $s4, $t5 # Store Data/Operand section of the instruction into $s4
    
    SRL $t1, $t3, 20 # Shift the four bits values to the first four bits, used to check the family
    MOVE $t2, $t1 
 
    BEQ $t2, 0x1, Control # Jumps to control which will decode which control operation to perform
    BEQ $t2, 0x2, Branch # Jumps to Branch which will decode which branch operation to perform
    BEQ $t2, 0x3, Data # Jumps to Data which will decode which Data operation to perform
    BEQ $t2, 0x4, Math # Jumps to Math which will decode which Math operation to perform
    
    Control:
    LA $t0, control_ops # Loads the address of the control_ops array 
    J op
    Branch:
    LA $t0, branch_ops # Loads the address of the branch_ops array 
    J op
    Data:
    LA $t0, data_ops # Loads the address of the data_ops array 
    J op
    Math:
    LA $t0, math_ops # Loads the address of the math_ops array 
    J op 
    
    op:
    SRL $t1, $t4, 16 # Shifts the second hex value over to the far right aligned with bits 0 - 3
    SUB $t1, $t1, 1
    SLL $t1, $t1, 2 # Mutiples the value to get the offset of the address
    ADD $t0, $t0, $t1 # Adds the offset to the ops array address
    MOVE $v0, $t0 # Stores the new address to $v0
    
    JR $ra 
.end decode

# ***************************************************************************************************************************
# * Author: Aron Galvan                                                                                                     
# * Course: EE 234 Microprocessor Systems                                                                                   
# * Project: ROBOMAL                                                                                                        
# * File: ROBOMAL.s                                                                                                         
# * Subroutine: execute                                                                                                     
# * Description: This function executes the instruction operation, by jumping to the correct operation address, which was   
# *              decode previsouly, the function also sets $s6 to the base address the program_counter, and $s7 to the base 
# *              of numbers_data                                                                                            
# * Inputs: $a0 - The ROBOMAL operation address                                                                             
# * Outputs: None                                                                                                           
# * Computations: None                                                                                                      
# *                                                                                                                         
# * Revision History: 3/2/2017                                                                                              
# *************************************************************************************************************************** 
 .ent execute
    execute:
    ADD $sp, $sp, -4 # Adds space on the stack
    SW  $ra, 0($sp) # Save the current return address in the stack
    
    LA $s6, program_counter  # Loads the address of program counter
    LW $t0, 0($a0) # Get the value stored in a0
    JAL $t0 # Jump to the operation 
    
    LW  $ra, 0($sp)
    ADD $sp, $sp, 4

    JR $ra
 .end execute
 
 # *****************************************************************************************
 # Functions Used to get Bluetooth instructions
 # places instructions in corresponing spot in array
 # 
 # Gets ASCII value from UART input and converts to HEX, places in instruction array
 # *****************************************************************************************
 
 
.ent place_instructions
place_instructions:
    # pushes to stack
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    la $s0, instructions    # loads instruction address
    move $s1, $zero # begins counter
    
    place_in_array:
	jal get_instruction	# gets hex instruction
	move $t0, $v0
	
	sll $t1, $s1, 2	# shifts for placing in array
	add $t1, $s0, $t1  # adds offset
	sw $t0, 0($t1) # place in instruction array
	addi $s1, $s1, 1
	
	beq $t0, 0x240000, end_place	# if halt, end
	j place_in_array
	
    end_place:
    # pops off stack
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra
    
.end place_instructions
    
# loads 6-digit hex value from BT
.ent get_instruction
get_instruction:
    # pushes to stack
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)
    
    # load counter
    li $s0, 5
    move $s1, $zero
    read_from_BT:
	# reads byte from BT
	jal receive_byte_on_UART1
	move $a0, $v0	# moves output from recieve_byte to ascii_to_hex input
	jal ascii_to_hex

	# moves BT output to temp reg
	move $t0, $v0
	
	# places digits in their place in the opcode
	li $t3, 4
	mul $t1, $s0, $t3	# multiplies counter by 4
	sllv $t0, $t0, $t1  # shifts by counter x 4
	or $s1, $s1, $t0
	
	addi $s0, $s0, -1    # decrement counter
	bgez $s0, read_from_BT 
    
    # move to output
    move $v0, $s1
    
    # pops off stack
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    
    jr $ra
.end get_instruction
    
# converts ascii input (a0) to hex output (v0)
.ent ascii_to_hex
ascii_to_hex:
    ADDI $sp, $sp, -4
    SW $ra, 0($sp)

    move $t0, $a0	# moves input to temp reg
    li $t1, 0x30
    sub $t0, $t0, $t1 # moves ascii 0-9 to hex 0-9

    sltiu $t1, $t0, 0xA	# if less than A, return to caller
    bgtz $t1, return	# skips if 0-9

    li $t1, 0x7
    sub $t0, $t0, $t1	# if greater than A, subtract 7 more

    return:
    # moves to output
    move $v0, $t0
    LW $ra, 0($sp)
    ADDI $sp, $sp, 4
    jr $ra  
.end ascii_to_hex
 .endif
 


