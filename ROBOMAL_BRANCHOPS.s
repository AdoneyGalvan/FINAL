.ifndef ROBOMAL_BRANCHOPS
    ROBOMAL_BRANCHOPS:
	.include "GENERAL_LEDS.s"

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: BranchOperations.s                                                                                                
    # * Subroutine: ROBO_JUMP                                                                                                   
    # * Description: This function increments the program counter by the value specified by the operand, which intern is        
    # *              equivalent to a jump in the ROBOMAL program.                                                               
    # * Inputs: $s4 - The operands of the instruction, how far to jump from the current instruction                             
    # * Outputs: None                                                                                                           
    # * Computations: None                                                                                                      
    # *                                                                                                                        
    # * Revision History: 3/2/2017                                                                                              
    # ***************************************************************************************************************************
	.ent ROBO_JUMP
	    ROBO_JUMP:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    SW $s4, 0($s6)

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_JUMP

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: BranchOperations.s                                                                                                
    # * Subroutine: ROBO_BEQZ                                                                                                   
    # * Description: This function increments the program counter by the value specified by the operand if $s0 is equal to zero 
    # *              which intern is equivalent to a jump in the ROBOMAL program.                                               
    # * Inputs: $s4 - The operands of the instruction, how far to jump from the current instruction                             
    # * Outputs: None                                                                                                           
    # * Computations: None                                                                                                      
    # *                                                                                                                         
    # * Revision History: 3/2/2017                                                                                              
    # ***************************************************************************************************************************
	.ent ROBO_BEQZ
	    ROBO_BEQZ:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    BNEZ $s0, end_branch_BENZ  # If not equal to zero jump to end else perform branch
	    MOVE $t1, $s4 # The operands are the offset to add to the program counter interms the instruction index
	    LW $t0, 0($s6) # Load the current value of the program counter 
	    ADD $t0, $t1, $t0 # Adds the current value of the program counter to the jump instruction 
	    SUB $t0, $t0, 1 # Subtract one from the program counter since it has already been incremented in the fetch cycle
	    SW $t0, 0($s6) # Loads the new value of the program counter 
	    end_branch_BENZ:    

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_BEQZ

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: BranchOperations.s                                                                                                
    # * Subroutine: ROBO_BNEZ                                                                                                   
    # * Description: This function increments the program counter by the value specified by the operand if $s0 is not equal to  
    # *              zero which intern is equivalent to a jump in the ROBOMAL program.                                          
    # * Inputs: $s4 - The operands of the instruction, how far to jump from the current instruction                             
    # * Outputs: None                                                                                                           
    # * Computations: None                                                                                                      
    # *                                                                                                                         
    # * Revision History: 3/2/2017                                                                                              
    # ***************************************************************************************************************************
	.ent ROBO_BNEZ
	    ROBO_BNEZ:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    BEQZ $s0, end_branch_BEQZ  # If equal to zero jump to end do nothing else perform jump by incrementing the program counter
	    MOVE $t1, $s4 # The operands are the offset to add to the program counter interms the instruction index
	    LW $t0, 0($s6) # Load the current value of the program counter 
	    ADD $t0, $t1, $t0 # Adds the current value of the program counter to the jump instruction 
	    SUB $t0, $t0, 1 # Subtract one from the program counter since it has already been incremented in the fetch cycle
	    SW $t0, 0($s6) # Loads the new value of the program counter 
	    end_branch_BEQZ:

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_BNEZ

    # ***************************************************************************************************************************
    # * Author: Aron Galvan                                                                                                     
    # * Course: EE 234 Microprocessor Systems                                                                                   
    # * Project: ROBOMAL                                                                                                        
    # * File: BranchOperations.s                                                                                                
    # * Subroutine: HALT                                                                                                        
    # * Description: This function increments HALTS the ROBOLAB program                                                         
    # * Inputs: None                                                                                                            
    # * Outputs: None                                                                                                           
    # * Computations: None                                                                                                     
    # *                                                                                                                         
    # * Revision History: 3/2/2017                                                                                              
    # ***************************************************************************************************************************
	.ent ROBO_HALT
	    ROBO_HALT:
	    JR $a3
	.end ROBO_HALT
.endif





