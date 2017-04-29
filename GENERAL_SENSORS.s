.ifndef GENERAL_SENSORS
    GENERAL_SENSORS:
    .ent setup_sensor
	setup_sensor:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LI $t0, 15 << 4 # Set pins RE4, RE5, RE6, RE7 as input
	SW $t0, TRISECLR
	SW $t0, TRISESET
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end setup_sensor
    
    .ent READ_SENSOR
	READ_SENSOR:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LW $t0, PORTE # Read PORTE
	LI $t1, 15 << 4 # Load and value
	AND $t0, $t0, $t1 # Mask of the bits 4,5,6,7
	SRL $t0, $t0, 4 # Shift to first four bits
	MOVE $v0, $t0 # Move to $v0
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end READ_SENSOR	
 .endif 





