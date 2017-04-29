.global main
    
.include "ROBOMAL.s"  
.include "LINE_FOLLOWER.s"
.include "RC.s"
    
.data
mains: .word default, ROBO_MAIN_SETUP, LINE_FOLLOWER_MAIN_SETUP, default, RC_MAIN_SETUP
    
.text
# main that includes all modes
.ent main
main:
    
    final_loop:
    LA $s7, final_loop
    # get switch states
    lw $t0, PORTA
    # mask bits
    andi $t1, $t0, 0xC000
    andi $t2, $t0, 0xC0
    # shift to position
    sra $t1, $t1, 14
    sra $t2, $t2, 4
    or $t0, $t1, $t2
    
    beqz $t0, final_loop 
    
    # if greater than three, re-read
    li $t1, 4
    slt $t1, $t1, $t0
    bgtz $t1, final_loop
    
    la $t1, mains
    # multiply offset by 4
    sll $t0, $t0, 2
    # add base
    add $t0, $t1, $t0
    lw $t1, 0($t0)
    jal $t1
    
    default:
    j final_loop
    
.end main

    
# set switches pins to input
.ent setup_switches
setup_switches:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $t0, 0b11 << 6
    sw $t0, TRISASET
    li $t0, 0b11 << 14
    sw $t0, TRISASET
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
.end setup_switches

.ent RC_MAIN_SETUP
RC_MAIN_SETUP:
    
    .section .vector_24, code
    j UART1_handler
    
    .text
    j RC_MAIN
    
.end RC_MAIN_SETUP
    
.ent ROBO_MAIN_SETUP
ROBO_MAIN_SETUP:
    # vector table referenece handlers
    .section .vector_20, code
    J timer_4_5_handler

    .section .vector_4, code
    J timer_1_handler

    .section .vector_13, code
    J input_capture_handler_3

    .section .vector_9, code
    J input_capture_handler_2
    
    .text
    j ROBO_MAIN
.end ROBO_MAIN_SETUP
    
.ent LINE_FOLLOWER_MAIN_SETUP
LINE_FOLLOWER_MAIN_SETUP:
     .section .vector_4, code
    J timer_1_handler

    .section .vector_13, code
    J input_capture_handler_3

    .section .vector_9, code
    J input_capture_handler_2
    .text
    j LINE_FOLLOWER_MAIN
.end LINE_FOLLOWER_MAIN_SETUP
    
    