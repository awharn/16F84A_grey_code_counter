;**********************************************************************
;                                                                     *
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F84A. This file contains the basic code               *
;   building blocks to build upon.                                    *
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:        GreyCodeCounter.asm                             *
;    Date:            10-11-17  rev. 10-13-17                         *
;    File Version:    0.0.1                                           *
;                                                                     *
;    Author:          Andrew W. Harn                                  *
;    Company:         Geneva College                                  *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files required: P16F84A.INC                                      *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************


    list      p=16F84A             ; list directive to define processor
    #include "p16f84a.inc"         ; processor specific variable definitions

    __CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _RC_OSC

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.

;***** VARIABLE DEFINITIONS
w_temp        EQU     0x0C        ; variable used for context saving 
status_temp   EQU     0x0D        ; variable used for context saving
loopcount1    EQU     0x0E	  ; Loop counter variable
loopcount2    EQU     0x0F	  ; Loop counter variable
counter	      EQU     0x10	  ; Counter for the Lookup Table
   
;**********************************************************************
RESET_VECTOR      CODE    0x0000  ; processor reset vector
        goto    start             ; go to beginning of program

ISR               CODE    0x0004  ; interrupt vector location

Interrupt:

        movwf  w_temp             ; save off current W register contents
        movf   STATUS,w           ; move status register into W register
        movwf  status_temp        ; save off contents of STATUS register

;  Place ISR Here

        movf   status_temp,w      ; retrieve copy of STATUS register
        movwf  STATUS             ; restore pre-isr STATUS register contents
        swapf  w_temp,f
        swapf  w_temp,w           ; restore pre-isr W register contents
        retfie                    ; return from interrupt

MAIN_PROGRAM    CODE

start:
	banksel	TRISA
	movlw	0x10
	movwf	TRISA		  ;Set Port RA4 to an input
	movlw	0x00
	movwf	TRISB		  ;Set Ports RB0 - RB7 to outputs
	banksel PORTB
	movlw	0x00
	movwf	PORTB		  ;Make sure RB0 - RB7 are clear on startup (this was an issue)
	clrf	counter		  ;Clear the nutton press counter
	
press1:	btfsc	PORTA,4		  ;Test if RA4 is pressed
	goto	press1
	call	wait
	
press2:	btfss	PORTA,4		  ;Test if RA4 is released
	goto	press2
	call	wait
	incf	counter		  ;Increment the counter
	movf	counter,0	  ;Move the counter to the W register
	andlw	0x0F		  ;Use an AND to set the upper 4 bits to 0
	call	table		  ;Use the lookup table
	movwf	PORTB
	goto	press1
	
;Wait timer to deal with switch bounce (50ms - 20ms still had bounce)
wait:	movlw	0x19		  ; Set outer loop to 125
	movwf	loopcount2
	
wait1:	movlw	0xC8		  ; Set inner loop to 200
	movwf	loopcount1	
	
loop:	nop
	nop
	nop
	nop
	nop
	nop
	nop
	decfsz	loopcount1
	goto	loop
	decfsz  loopcount2
	goto	wait1
	return
	
;Lookup Table
table:	addwf	PCL
	retlw	b'0000'
	retlw	b'0001'
	retlw	b'0011'
	retlw	b'0010'
	retlw	b'0110'
	retlw	b'0111'
	retlw	b'0101'
	retlw	b'0100'
	retlw	b'1100'
	retlw	b'1101'
	retlw	b'1111'
	retlw	b'1110'
	retlw	b'1010'
	retlw	b'1011'
	retlw	b'1001'
	retlw	b'1000'
	
        END                       ; directive 'end of program'