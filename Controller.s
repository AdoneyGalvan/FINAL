.Global main
    .include "MAIN_JOYSTICK_SEND.s"
    .include "SEND_KEYPAD.s"
    .include "GENERAL_UART1.s"
    .include "SWITCH.s"
    .include "CONTROLLER_MUSIC.s"
.Data
    mode: .word default, MAIN_JOYSTICK, MAIN_KEYPAD, default, MUSIC_MAIN
    Select_mode: .asciiz "Select Mode..."
    clear_mode: .byte 0x1B, '[', 'j', 0x00
.Text
.ent main
    main: 
    # setup for switches
    JAL setup_switch
    
    # setup for UART1
    JAL setup_UART1
    
    # setup for music functions
    jal setup_pins
    jal init_amp2
    jal setup_output_compare2
    jal setup_timers
    
    LA $a0, clear_mode
    JAL send_char_arr_to_UART1
    
    main_while:
    JAL read_switch
    move $t0, $v0
    
    LA $t1, mode
    # multiply offset by 4
    SLL $t0, $t0, 2
    # add base
    ADD $t0, $t1, $t0
    LW $t1, 0($t0)
    JAL $t1
    
    default:
    J main_while  
.end main

.section .vector_4, code
 J timer_1_handler

 .section .vector_12,code
 j timer3_ISR


