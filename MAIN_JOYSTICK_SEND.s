.ifndef MAIN_JOYSTICK_SEND
  MAIN_JOYSTICK_SEND:
    .include "TIMER_JOYSTICK_TIMER.s"
    .include "SPI2_JOYSTICK_SEND.s"
    .include "SPI1_JOYSTICK_SEND.s"
    .include "GENERAL_UART2.s"
    .include "GENERAL_UART1.s"
    .include "CONTROLLER_MUSIC.s"

.Data
    char_num: .asciiz "1111"
    x_label: .asciiz "X:"
    y_label: .asciiz "Y:"
    clear_disp2: .byte 0x1B, '[', 'j', 0x00
    direction: .byte 0
    speed: .asciiz "11"
    drive_flag: .byte 0
    left_motor_tx: .byte 0
    right_motor_tx: .byte 0
    left_motor_ascii: .asciiz "Left Motor: "
    right_motor_ascii: .asciiz "Right Motor:"
    set_to_1row_0col: .byte 0x1B, '[', '1', ';', '0', 'H', 0x00
    mode_joystick: .asciiz "Joystick Mode ;)"
.Text
.ent MAIN_JOYSTICK
    MAIN_JOYSTICK:
    li $t0, 1 << 12  # turns on multivector mode
    sw $t0, INTCONSET
    JAL setup_UART2
    jal setup_UART1
    JAL setup_SPI2
    JAL setup_SPI1
    JAL setup_timer_1
    jal setup_pins
    jal setup_output_compare1
    jal setup_timers
    jal init_amp2
    LA $a0, mode_joystick
    JAL send_char_arr_to_UART1
    
    set:
    LI $a0, 6500 # Set period register for one millisecond
    JAL timer_1_delay
    
    jal get_x_y_1
    move $t0, $v1
    
    li $t1, 553
    slt $t1, $t1, $t0
    bgtz $t1, forward
    
    li $t1, 513
    slt $t1, $t0, $t1
    bgtz $t1, backward
    
    # halt by default with no input capture
    li $t0, 50
    sb $t0, left_motor_tx
    sb $t0, right_motor_tx
    li $t0, 0b100
    sb $t0, drive_flag
    j send_to_UART
    
    forward:
    # get jstk data
    JAL drive_forward
    j send_to_UART
    
    # drives backwards y < (dead zone)
    backward:
    jal drive_backward
    j send_to_UART
    
    send_to_UART:
    LB $s0, left_motor_tx
    LB $s1, right_motor_tx
    LB $s2, drive_flag
    LI $s3, 0
    
    # clears LCD
    la $a0, clear_disp2
    jal send_char_arr_to_UART1
    
    # sends data to LCDscreen
    la $a0, left_motor_ascii
    jal send_char_arr_to_UART1
    
    MOVE $a0, $s0
    JAL convert_to_ascii
    LA $a0, char_num
    JAL send_char_arr_to_UART1
  
    la $a0, set_to_1row_0col
    jal send_char_arr_to_UART1
    
    la $a0, right_motor_ascii
    jal send_char_arr_to_UART1
    
    MOVE $a0, $s1
    JAL convert_to_ascii
    LA $a0, char_num
    JAL send_char_arr_to_UART1
    
    # sends the info bits to BT
    MOVE $a0, $s0
    JAL send_byte_to_UART2
    
    MOVE $a0, $s1
    JAL send_byte_to_UART2
    
    MOVE $a0, $s2
    JAL send_byte_to_UART2
    
    MOVE $a0, $s3
    JAL send_byte_to_UART2
  
    J set
    
.end MAIN_JOYSTICK
    
# drive_forward subroutine assumes y-value
# from the joystick is north of the highest point in the dead zone
.ent drive_forward
drive_forward:
    # pushes to stack
    addi $sp, $sp, -12
    sw $s1, 0($sp)
    sw $s2, 4($sp)
    sw $ra, 8($sp)
    
    li $t0, 0b100
    sb $t0, drive_flag
    
    # get x-axis from jstk2
    JAL get_x_y_2
    MOVE $s1, $v0 # x-axis 
    
    # get y-axis from jstk1
    JAL get_x_y_1
    MOVE $s2, $v1 # y-axis
    
    # converts y values to duty cycle
    # Equation is y = (30/372)x + 28
    LI $t0, 30
    LI $t1, 372
    MUL $s2, $s2, $t0
    DIV $s2, $t1
    ADDI $s2, $s2, 28
    # x-axis is converted to duty-cycle w/in turn subr
    
    decide_turn:
    # decides which way to turn
    li $t0, 538
    slt $t1, $t0, $s1
    bgtz $t1, right_turn
    
    li $t0, 498
    slt $t1, $s1, $t0
    bgtz $t1, left_turn
    
    # if no turning, goes straight
    
    # drive_flag<2:1> = direction pins
    # drive_flag<0> = 0 - input capture off
    # 		      1 - input capture on
    li $t0, 0b101
    sb $t0, drive_flag
    
    # saves to transmit labels
    sb $s2, left_motor_tx
    sb $s2, right_motor_tx
    
    # jumps to end of drive_forward
    J end_drive_forward
    
    right_turn:
    # drive_flag<2:1> = direction pins
    # drive_flag<0> = 0 - input capture off
    # 		      1 - input capture on
    lb $t0, drive_flag
    andi $t0, 0b110
    sb $t0, drive_flag
    
    # writes y-value duty cycle to left motor
    sb $s2, left_motor_tx
    
    # Equation is y = (20/356)x - 28 
    LI $t0, 20
    LI $t1, 356
    MUL $s1, $s1, $t0
    DIV $s1, $t1
    ADDI $s1, $s1, -28
    
    # subtracts from y-axis duty cycle
    sub $s1, $s2, $s1
    
    # writes adjusted duty cycle to right motor
    sb $s1, right_motor_tx
    
    j end_drive_forward
    
    left_turn:
    # drive_flag<2:1> = direction pins
    # drive_flag<0> = 0 - input capture off
    # 		      1 - input capture on
    lb $t0, drive_flag
    andi $t0, 0b110
    sb $t0, drive_flag
    
    # writes y-value duty cycle to right motor
    sb $s2, right_motor_tx
    
    # gets x-axis duty cycle
    # Equation is y = (-20/319)x + 31
    LI $t0, -20
    LI $t1, 319
    MUL $s1, $s1, $t0
    DIV $s1, $t1
    ADDI $s1, $s1, 31
    
    # subtracts from y-axis duty cycle
    sub $s1, $s2, $s1
    
    # writes adjusted duty cycle to right motor
    sb $s1, left_motor_tx
    
    end_drive_forward:
    # pops off stack
    lw $s1, 0($sp)
    lw $s2, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    
    # return to caller
    jr $ra
    
.end drive_forward
    
.ent drive_backward
drive_backward:
    # pushes to stack
    addi $sp, $sp, -12
    sw $s1, 0($sp)
    sw $s2, 4($sp)
    sw $ra, 8($sp)
    
    li $t0, 0b010
    sb $t0, drive_flag
    
    # get x-axis from jstk2
    JAL get_x_y_2
    MOVE $s1, $v0 # x-axis 
    
    # get y-axis from jstk1
    JAL get_x_y_1
    MOVE $s2, $v1 # y-axis
    
    # converts y values to duty cycle
    # Equation is y = (-30/316)x + 118
    LI $t0, -30
    LI $t1, 285
    MUL $s2, $s2, $t0
    DIV $s2, $t1
    ADDI $s2, $s2, 102
    # x-axis is converted to duty-cycle w/in turn subr
    
    decide_turn_back:
    # decides which way to turn
    li $t0, 538
    slt $t1, $t0, $s1
    bgtz $t1, right_turn_back
    
    li $t0, 498
    slt $t1, $s1, $t0
    bgtz $t1, left_turn_back
    
    # if no turning, goes straight
    
    # drive_flag<2:1> = direction pins
    # drive_flag<0> = 0 - input capture off
    # 		      1 - input capture on
    lb $t0, drive_flag
    ori $t0, $t0, 1
    sb $t0, drive_flag
    
    # saves to transmit labels
    sb $s2, left_motor_tx
    sb $s2, right_motor_tx
    
    # jumps to end of drive_forward
    J end_drive_backward
    
    right_turn_back:
    # drive_flag<2:1> = direction pins
    # drive_flag<0> = 0 - input capture off
    # 		      1 - input capture on
    lb $t0, drive_flag
    andi $t0, 0b110
    sb $t0, drive_flag
    
    # writes y-value duty cycle to left motor
    sb $s2, left_motor_tx
    
    # Equation is y = (20/356)x - 28 
    LI $t0, 20
    LI $t1, 356
    MUL $s1, $s1, $t0
    DIV $s1, $t1
    ADDI $s1, $s1, -28
    
    # subtracts from y-axis duty cycle
    sub $s1, $s2, $s1
    
    # writes adjusted duty cycle to right motor
    sb $s1, right_motor_tx
    
    j end_drive_backward
    
    left_turn_back:
    # drive_flag<2:1> = direction pins
    # drive_flag<0> = 0 - input capture off
    # 		      1 - input capture on
    lb $t0, drive_flag
    andi $t0, 0b110
    sb $t0, drive_flag
    
    # writes y-value duty cycle to right motor
    sb $s2, right_motor_tx
    
    # gets x-axis duty cycle
    # Equation is y = (-20/319)x + 31
    LI $t0, -20
    LI $t1, 319
    MUL $s1, $s1, $t0
    DIV $s1, $t1
    ADDI $s1, $s1, 31
    
    # subtracts from y-axis duty cycle
    sub $s1, $s2, $s1
    
    # writes adjusted duty cycle to right motor
    sb $s1, left_motor_tx
    
    end_drive_backward:
    # pops off stack
    lw $s1, 0($sp)
    lw $s2, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    
    # return to caller
    jr $ra

.end drive_backward

.ent convert_to_ascii
    convert_to_ascii:
    ADDI $sp, $sp, -4
    SW $ra, 0($sp)
    
    LI $t6, 10
    DIV $a0, $t6
    LA $t0, char_num
    MFHI $t1
    ADDI $t1, $t1, 48
    SB $t1, 3($t0)
    MFLO $a0

    DIV $a0, $t6
    LA $t0, char_num
    MFHI $t1
    ADDI $t1, $t1, 48
    SB $t1, 2($t0)
    MFLO $a0

    DIV $a0, $t6
    LA $t0, char_num
    MFHI $t1
    ADDI $t1, $t1, 48
    SB $t1, 1($t0)
    MFLO $a0

    DIV $a0, $t6
    LA $t0, char_num
    MFHI $t1
    ADDI $t1, $t1, 48
    SB $t1, 0($t0)
    MFLO $a0
    
    LW $ra, 0($sp)
    ADDI $sp, $sp, 4
    JR $ra
.end convert_to_ascii

.endif
 