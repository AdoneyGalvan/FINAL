.ifndef ROBOMAL_DATAOPS
    ROBOMAL_DATAOPS:
	.include "GENERAL_LEDS.s"
    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: DataOperations.s                                                                                                  
    # * Subroutine: ROBO_READ                                                                                                   
    # * Description: This function reads PORTE7:0 and stores the read value and stored in a specified memory location in        
    # *              numbers_data array                                                                                                                                             
    # * Inputs: $s4 - The operands of the instruction, where to store the read value in the numbers_data array the offset       
    # *         $s7 - The base address of numbers_data array                                                                    
    # * Outputs: None                                                                                                           
    # * Computations: None                                                                                                      
    # *                                                                                                                         
    # * Revision History: 3/2/2017                                                                                              
    # ***************************************************************************************************************************
	.ent ROBO_READ
	    ROBO_READ:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    MOVE $t0, $s7  # Loads the base address of numbers 
	    MOVE $t1, $s4 # The operands are the offset to be add to the base address of numbers_data
	    SLL  $t1, $t1, 2 # Mutiple the operand by 4 to get the offset 
	    ADD $t1, $t0, $t1 # Adds the offset to the base address of numbers_data

	    LW $t0, PORTE # Read PORTE 7:0 
	    ANDI $t0, $t0, 0xFF # Mask off the first 8 bits 
	    SW $t0, 0($t1) # Store into a specific memory location

	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_READ

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: DataOperations.s                                                                                                  
    # * Subroutine: ROBO_WRITE                                                                                                  
    # * Description: This function reads specified memory location in numbers_data array, and writes the value to PORTE 7:0                                                                                                                                     
    # * Inputs: $s4 - The operands of the instruction, where to read value in the numbers_data array the offset                 
    # *         $s7 - The base address of numbers_data array                                                                    
    # * Outputs: None                                                                                                           
    # * Computations: None                                                                                                      
    # *                                                                                                                         
    # * Revision History: 3/2/2017                                                                                              
    # ***************************************************************************************************************************
	.ent ROBO_WRITE
	    ROBO_WRITE:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save

	    MOVE $t0, $s7  # Loads the base address of numbers 
	    MOVE $t1, $s4 # The operands are the offset to be add to the base address of numbers_data
	    SLL  $t1, $t1, 2 # Mutiple the operand by 4 to get the offset 
	    ADD $t1, $t0, $t1 # Adds the offset to the base address of numbers_data

	    LW $t0, 0($t1) # Read the memory space 
	    ANDI $t0, $t0, 0xFF # Mask off the first 8 bits 
	    SW $t0, LATESET # Write to to PORTE 

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_WRITE

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: DataOperations.s                                                                                                  
    # * Subroutine: ROBO_LOAD                                                                                                   
    # * Description: This function reads specified memory location in numbers_data array, and loads the value in $s0-accumalator                                                                                                                                 
    # * Inputs: $s4 - The operands of the instruction, where to read value in the numbers_data array the offset                 
    # *         $s7 - The base address of numbers_data array                                                                   
    # * Outputs: None                                                                                                           
    # * Computations: None                                                                                                      
    # *                                                                                                                        
    # * Revision History: 3/2/2017                                                                                              
    # ***************************************************************************************************************************
	.ent ROBO_LOAD
	    ROBO_LOAD:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    MOVE $t0, $s7  # Loads the base address of numbers 
	    MOVE $t1, $s4 # The operands are the offset to be add to the base address of numbers_data
	    SLL  $t1, $t1, 2 # Mutiple the operand by 4 to get the offset 
	    ADD $t1, $t0, $t1 # Adds the offset to the base address of numbers_data

	    LW $s0, 0($t1) # Loads the value in the memory space into $s0

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_LOAD

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: DataOperations.s                                                                                                  
    # * Subroutine: ROBO_STORE                                                                                                  
    # * Description: This function stores the value in $s0-accumalator into a specified memory location in numbers_data array                                                                                                                                    
    # * Inputs: $s4 - The operands of the instruction, where to read value in the numbers_data array the offset                 
    # *         $s7 - The base address of numbers_data array                                                                    
    # * Outputs: None                                                                                                           
    # * Computations: None                                                                                                      
    # *                                                                                                                         
    # * Revision History: 3/2/2017                                                                                             
    # ***************************************************************************************************************************
	.ent ROBO_STORE
	    ROBO_STORE:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    MOVE $t0, $s7  # Loads the base address of numbers 
	    MOVE $t1, $s4 # The operands are the offset to be add to the base address of numbers_data
	    SLL  $t1, $t1, 2 # Mutiple the operand by 4 to get the offset 
	    ADD $t1, $t0, $t1 # Adds the offset to the base address of numbers_data

	    SW $s0, 0($t1) # Stores the value iinto specified memory location 

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_STORE

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: DataOperations.s                                                                                                  
    # * Subroutine: ROBO_LOADI                                                                                                 
    # * Description:                                                                                                                                                                
    # * Inputs: $s4 - The operands of the instruction, where to read value in the numbers_data array the offset                 
    # *         $s7 - The base address of numbers_data array                                                                   
    # * Outputs: None                                                                                                           
    # * Computations: None                                                                                                      
    # *                                                                                                                         
    # * Revision History: 3/2/2017                                                                                              
    # ***************************************************************************************************************************
	.ent ROBO_LOADI
	    ROBO_LOADI:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    # 32-Bit system needed for this function to be of any use 

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_LOADI
.endif





