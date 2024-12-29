.text
.global main

.equ pcb_link, 0
.equ pcb_reg1, 1
.equ pcb_reg2, 2
.equ pcb_reg3, 3
.equ pcb_reg4, 4
.equ pcb_reg5, 5
.equ pcb_reg6, 6
.equ pcb_reg7, 7
.equ pcb_reg8, 8
.equ pcb_reg9, 9
.equ pcb_reg10, 10
.equ pcb_reg11, 11
.equ pcb_reg12, 12
.equ pcb_reg13, 13
.equ pcb_sp, 14
.equ pcb_ra, 15
.equ pcb_ear, 16
.equ pcb_cctrl, 17

main:
    movsg $2, $evec         #copy exception handler to register 2
    sw $2, old_vector($0)   #save it to old_vector
    la $2, handler          #get address to our handler
    movgs $evec, $2         #save it to the $evec register

    #mask to enable IRQ2 KU, OKU, OIE
    addi $5, $0, 0x4d

    #setup the pcb for task 1
    la $1, task1_pcb
    #set up link field
    la $2, task2_pcb
    sw $2, pcb_link($1)
    #setup the stack pointer
    la $2, task1_stack
    sw $2, pcb_sp($1)
    #setup the $ear field
    la $2, serial_main
    sw $2, pcb_ear($1)
    #set up $cctrl field
    sw $5, pcb_cctrl($1)

    #setup the pcb for task 2
    la $1, task2_pcb
    #set up link field
    la $2, task1_pcb
    sw $2, pcb_link($1)
    #setup the stack pointer
    la $2, task2_stack
    sw $2, pcb_sp($1)
    #setup the $ear field
    la $2, parallel_main
    sw $2, pcb_ear($1)
    #set up $cctrl field
    sw $5, pcb_cctrl($1)

    #set first task as the current task
    la $1, task1_pcb
    sw $1, current_task($0)

    #put our count value into the timer load reg
    addi $11, $0, 24
    sw $11, 0x72001($0)
    #enable the timer and set auto-retsart mode
    addi $11, $0, 0x3
    sw $11, 0x72000($0)

    jal load_context

dispatcher:
save_context:
    lw $13, current_task($0)    #get address of the current PCB

    #save the registers
    sw $1, pcb_reg1($13)
    sw $2, pcb_reg2($13)
    sw $3, pcb_reg3($13)
    sw $4, pcb_reg4($13)
    sw $5, pcb_reg5($13)
    sw $6, pcb_reg6($13)
    sw $7, pcb_reg7($13)
    sw $8, pcb_reg8($13)
    sw $9, pcb_reg9($13)
    sw $10, pcb_reg10($13)
    sw $11, pcb_reg11($13)
    sw $12, pcb_reg12($13)
    sw $sp, pcb_sp($13)
    sw $ra, pcb_ra($13)

    #get old value of $13
    movsg $1, $ers
    sw $1, pcb_reg13($13)
    #save $ear
    movsg $1, $ear
    sw $1, pcb_ear($13)
    #save $cctrl
    movsg $1, $cctrl
    sw $1, pcb_cctrl($13)

schedule:
    lw $13, current_task($0)        #Get current task
    lw $13, pcb_link($13)           #get next task from pcb_link field
    sw $13, current_task($0)        #set next task as current task

    lw $13, timeslice($0)
    addi $13, $0, 100
    sw $13, timeslice($0)

load_context:
    lw $13, current_task($0)        #Get PCB of current task

    #get the PCB value for $13 back into $ers
    lw $1, pcb_reg13($13)
    movgs $ers, $1
    #restore $ear
    lw $1, pcb_ear($13)
    movgs $ear, $1
    #restore $cctrl
    lw $1, pcb_cctrl($13)
    movgs $cctrl, $1

    #restore registers
    lw $1, pcb_reg1($13)
    lw $2, pcb_reg2($13)
    lw $3, pcb_reg3($13)
    lw $4, pcb_reg4($13)
    lw $5, pcb_reg5($13)
    lw $6, pcb_reg6($13)
    lw $7, pcb_reg7($13)
    lw $8, pcb_reg8($13)
    lw $9, pcb_reg9($13)
    lw $10, pcb_reg10($13)
    lw $11, pcb_reg11($13)
    lw $12, pcb_reg12($13)
    lw $sp, pcb_sp($13)
    lw $ra, pcb_ra($13)

    rfe                         #return to the new task

handler:
    movsg $13, $estat       #get value of exeption status register
    andi $13, $13, 0xFFB0   #mask for exception we don't handle
    beqz $13, handler_timer #if it is one of ours, go to our exception handler

    lw $13, old_vector($0)  #if not load default handler
    jr $13

handler_timer:
    sw $0, 0x72003($0)      #Acknowledge timer interrupt

    lw $13, counter($0)
    addi $13, $13, 1
    sw $13, counter($0)

    #subtract 1 from time slice
    lw $13, timeslice($0)
    subi $13, $13, 1
    #branch to dispatch if equal to 0
    beqz $13, dispatcher
    sw $13, timeslice($0)

    rfe

.data
timeslice:
    .word 100

.bss
task1_pcb:
    .space 18
task2_pcb:
    .space 18
old_vector:
    .word
current_task:
    .word
    #stack for task 1
    .space 200
task1_stack:
    #stack for task 2
    .space 200
task2_stack:
