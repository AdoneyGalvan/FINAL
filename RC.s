.ifndef RC
RC:
    .include "GENERAL_MOTORS.s"
    .include "GENERAL_UART2.s"
.Data
   char_num: .asciiz "1111"
   motors_data: .space 4
   counter: .word 0
   U1RX_flag: .byte 0
.Text
.ent RC_MAIN
    RC_MAIN:
    li $t0,1 << 12  # turns on multivector mode
    sw $t0, INTCONSET
    JAL left_motor # Configures the left motor output compare 
    JAL right_motor # Configures the right motot output compare
    JAL motor_timer # Configures timer 2 which clocks the output compares	
    JAL setup_UART1_recveive # Configures UART1 to receive data via bluetooth 
    JAL setup_UART2 # Configures UART2 to send data to LCD
    LI $s5, 4 # Drive flag compare 
    
    while_rc:
#     # get switch states
#     lw $t0, PORTB
#     # mask bits
#     andi $t0, $t0, 0x3C00
#     # shift to position
#     sra $t0, $t0, 10
#     LI $t1, 3
#     BEQ $t1, $t0, continue_rc # If switch not in mode 3 jump back to main while 
#     JR $s7 # Jump back to main program loop, final loop
#     
#     continue_rc:
    lb $s1, U1RX_flag
    BEQ $s1, 1, update
    NOP
    J while_rc

    update:
    LA $t0, motors_data
    move $s1, $zero
    sb $s1, U1RX_flag
    lb $s1, 0($t0) # Load left motor
    lb $s2, 1($t0) # Load right motor
    lb $s3, 2($t0) # Drive flags
    AND $s3, $s3, 6
    
    
    BEQ $s3, $s5, keepgoing # Check if the flags have changed
    
    change_motor_direction:
    SW $zero, OC2RS
    SW $zero, OC3RS
    
    # set enable bit directions
    lw $t0, PORTD
    li $t1, 0xFFFFFF3F
    and $t0, $t0, $t1	# masks 6&7 to zero
    move $t2, $s3
    sll $t2, $t2, 5	# shifts to 6&7
    or $t0, $t0, $t2
    sw $t0, PORTD
    
    JAL delay_update 
    J end_update
    
    keepgoing:
    LI $t1, 10
    MUL $s1, $t1
    MUL $s2, $t1
    
    SW $s1, OC2RS
    SW $s2, OC3RS
    
    end_update:
    move $s5, $s3 # Update the drive state with the current drive flag staus 
    li $t0, 1 << 27
    sw $t0, IEC0SET
    J while_rc
.end RC_MAIN

.ent delay_update
    delay_update:
    ADDI $sp, $sp, -8
    SW $ra, 0($sp)
    SW $t0, 4($sp)
    
    LI $t0, 1000
    delay_loop_update:
    BEQZ $t0, exit_delay_update
    ADDI $t0, $t0, -1
    J delay_loop_update
    exit_delay_update:
    
    LW $t0, 4($sp)
    LW $ra, 0($sp)
    ADDI $sp, $sp, 8
    JR $ra
.end delay_update
    
 # Specific setup for UART1 receieve data different from general
 .ent setup_UART1_recveive
    setup_UART1_recveive:
    ADDI $sp, $sp, -4
    SW $ra, 0($sp)

    # UART 1 on PORT JE, RD14, RF8, RF2, RD15, Top
    # Setting the buad rate generator to 9600 baud
    # U1BRG = 259
    LI $t0, 259
    SW $t0, U1BRG

    # Setting up the UART frame
    # Frame 8 data bits, 1 stop bit, no parity bit

    # Disable URAT1 while configuring
    # U1MODE<15> = 0
    LI $t0, 1 << 15
    SW $t0, U1MODECLR

    # Parity and Data Seelection, 8 bits no parity
    # U1MODE<2:1> = 00
    LI $t0, 3 << 1
    SW $t0, U1MODECLR

    # Select number of stop bits, 1 stop bit
    # U1MODE<0> = 0
    LI $t0, 1
    SW $t0, U1MODECLR

    # Enable UART Transmission
    LI $t0, 1 << 10
    SW $t0, U1STASET

    # Enable UART Recieve
    LI $t0, 1 << 12
    SW $t0, U1STASET

    # Enable URAT1 while configuring
    # U1MODE<15> = 1
    LI $t0, 1 << 15
    SW $t0, U1MODESET

    # Generate interrupt when receive buffer is full
    # U1STA<7:6> = 11
    LI $t0, 3 << 6
    SW $t0, U1STASET

    # Setup Receive Interrupt
    # Set the priority to iinterrupt
    # IPC6<4:2> = 0b110
    LI $t0, 6 << 2
    SW $t0, IPC6SET

    # Enable Receive interrupt 
    LI $t0, 1 << 27
    SW $t0, IEC0SET

    LW $ra, 0($sp)
    ADDI $sp, $sp, 4
    JR $ra
.end setup_UART1_recveive
# grabs 4 byts when receiver flag triggered
# loads data into motors_data label
.text
.ent UART1_handler
    UART1_handler:
    di
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    # clears flag bit
    li $t0, 1 << 27
    sw $t0, IFS0CLR
    
    # places current byts in motors_data receive buffer
    la $t0, motors_data
    lb $t1, U1RXREG
    sb $t1, 0($t0)
    lb $t1, U1RXREG
    sb $t1, 1($t0)
    lb $t1, U1RXREG
    sb $t1, 2($t0)
    lb $t1, U1RXREG
    sb $t1, 3($t0)
    LI $t1, 1
    sb $t1, U1RX_flag
    # Disable interrupt
    li $t0, 1 << 27
    sw $t0, IEC0CLR 
    addi $sp, $sp, 4
    ei
    eret
.end UART1_handler
    
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


