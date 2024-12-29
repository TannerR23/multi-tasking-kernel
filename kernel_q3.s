.text
.global main

main:
    movsg $2, $cctrl       #copy value of cctrl to register 2
    andi $2, $2, 0x000f     #disable all interrutps
    ori $2, $2, 0x42        #mask to enable IRQ2 interrupt and IE
    movgs $cctrl, $2        #save value back to cctrl

    movsg $2, $evec         #copy exception handler to register 2
    sw $2, old_vector($0)   #save it to old_vector
    la $2, handler          #get address to our handler
    movgs $evec, $2         #save it to the $evec register

    #put our count value into the timer load reg
    addi $11, $0, 24
    sw $11, 0x72001($0)
    #enable the timer and set auto-retsart mode
    addi $11, $0, 0x3
    sw $11, 0x72000($0)

    jal serial_main

handler:
    movsg $13, $estat       #get value of exeption status register
    andi $13, $13, 0xFFB0   #mask for exception we don't handle
    beqz $13, handler_timer #if it is one of ours, go to our exception handler

    lw $13, old_vector($0)  #if not load default handler
    jr $13

handler_timer:
    sw $0, 0x72003($0)
    lw $13, counter($0)
    addi $13, $13, 1
    sw $13, counter($0)
    rfe 


.bss
old_vector:
    .word
