.ifndef ROBOMAL_MATHOPS
    ROBOMAL_MATHOPS:
	.include "GENERAL_LEDS.s"
    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: MathOperations.s                                                                                                  
    # * Subroutine: ROBO_ADD                                                                                                    
    # * Description: This function adds the accumalator $s0 and the value stored in a spcecifed address in numbers_data, then  
    # *              stores the result back into the accumaltor $s0                                                                                                                               
    # * Inputs: $s4 - The operands of the instruction, where to read value in the numbers_data array the offset                 
    # *         $s7 - The base address of numbers_data array                                                                   
    # * Outputs: None                                                                                                           
    # * Computations: Addition                                                                                                  
    # *                                                                                                                         
    # * Revision History: 3/2/2017                                                                                             
    # ***************************************************************************************************************************
	.ent ROBO_ADD
	    ROBO_ADD:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    MOVE $t0, $s7  # Loads the base address of numbers 
	    MOVE $t1, $s4 # The operands are the offset to be add to the base address of numbers_data
	    SLL  $t1, $t1, 2 # Mutiple the operand by 4 to get the offset 
	    ADD $t1, $t0, $t1 # Adds the offset to the base address of numbers_data
	    LW $t0, 0($t1) # Loads the value in memeory 
	    ADD $s0, $s0, $t0 # Adds $s0 + memory and stores into $s0

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_ADD

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: MathOperations.s                                                                                                 
    # * Subroutine: ROBO_SUB                                                                                                    
    # * Description: This function subtracts the accumalator $s0 and the value stored in a spcecifed address in numbers_data,   
    # *              then stores the result back into the accumaltor $s0                                                                                                                          
    # * Inputs: $s4 - The operands of the instruction, where to read value in the numbers_data array the offset                
    # *         $s7 - The base address of numbers_data array                                                                    
    # * Outputs: None                                                                                                           
    # * Computations: Subtraction                                                                                               
    # *                                                                                                                         
    # * Revision History: 3/2/2017                                                                                              
    # ***************************************************************************************************************************
	.ent ROBO_SUB
	    ROBO_SUB:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    MOVE $t0, $s7  # Loads the base address of numbers 
	    MOVE $t1, $s4 # The operands are the offset to be add to the base address of numbers_data
	    SLL  $t1, $t1, 2 # Mutiple the operand by 4 to get the offset 
	    ADD $t1, $t0, $t1 # Adds the offset to the base address of numbers_data
	    LW $t0, 0($t1) # Loads the value in memeory 
	    SUB $s0, $s0, $t0 # Subs $s0 + memory and stores into $s0

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_SUB

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: MathOperations.s                                                                                                  
    # * Subroutine: ROBO_MUL                                                                                                    
    # * Description: This function multiples the accumalator $s0 and the value stored in a spcecifed address in numbers_data,   
    # *              then stores the result $s0, and the remainder in $s5                                                                                                                         
    # * Inputs: $s4 - The operands of the instruction, where to read value in the numbers_data array the offset                 
    # *         $s7 - The base address of numbers_data array                                                                    
    # * Outputs: None                                                                                                           
    # * Computations: Subtraction                                                                                               
    # *                                                                                                                         
    # * Revision History: 3/2/2017                                                                                              
    # ***************************************************************************************************************************
	.ent ROBO_MUL
	    ROBO_MUL:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    MOVE $t0, $s7  # Loads the base address of numbers 
	    MOVE $t1, $s4 # The operands are the offset to be add to the base address of numbers_data
	    SLL  $t1, $t1, 2 # Mutiple the operand by 4 to get the offset 
	    ADD $t1, $t0, $t1 # Adds the offset to the base address of numbers_data
	    LW $t0, 0($t1) # Loads the value in memeory 
	    MULT $s0, $t0  # Perform the mutiplication 
	    MFHI $s0 # Store the result of the mutiplication
	    MFLO $s5 # Store the remainder of the mutiplication

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_MUL   
.endif





