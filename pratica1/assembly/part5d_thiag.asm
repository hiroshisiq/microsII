; 			HEADER					;
;			LCD 8 BITS MODE				;
	BUS1	EQU	P0
	BUS2	EQU	P2
	ENAB	EQU	P0.2
	RW	EQU	P0.1
	RS	EQU	P0.0


; RS 0/1	Instruction/Data
; RW 0/1	Write/Read
; ENAB 1->0	Instruction/Data acquire	

	ORG 	0
	SJMP 	MAIN

	ORG 	23H
	SJMP 	SERIAL

MAIN:	MOV 	SCON, #01010000B 	; Serial Mode 1 + Receiver Enable 
	MOV 	TMOD, #00100001B 	; Timer 1 Mode 2 (auto reload), Timer 0 Mode 1
	MOV 	TH1,  #253D      	; Baud Rate 9600
	MOV 	IE,   #10010000B 	; Enable SERIAL interrupt
	SETB 	TR1

	LCALL DELAY_30
	
PROG:	LCALL 	INIT
	LCALL	CLEAR			; Configuring the lcd
	MOV	R7, #00H		; R7 is the character counter
LOOP1:	CJNE	R7, #0FH, LOOP1		; Writes 15 characters
	CLR	ES			
	MOV	A, #40H			; Jump to 2 line
	LCALL	POS
	SETB 	ES			
LOOP2:	CJNE	R7, #1EH, LOOP2		; Writes 15 more characters
	SJMP 	PROG	


SERIAL:	CLR ES
	CLR RI
	MOV A, SBUF
	LCALL WRITE
	INC R7
	SETB ES
	RETI

SEND:	SETB 	ENAB
	LCALL	CONV
	CLR	ENAB
	LCALL	WAIT
	RET

CONV:	MOV 	R6, A
	ANL 	A, #0F0H
	ANL 	BUS1, #0FH
	ORL 	BUS1, A
	MOV	A, R6
	ANL 	A, #0FH
	MOV	BUS2, A
	MOV 	A, R6
	RET

WRITE:	CLR	RW
	SETB 	RS
	LCALL 	SEND
	RET

CLEAR:	CLR	RW
	SETB 	ENAB
	CLR 	RS
	MOV 	A, #01H
	LCALL 	SEND
	RET
	
POS:	CLR	RW
	SETB 	ENAB
	CLR 	RS
	ADD 	A, #80H
	LCALL 	SEND
	RET
	
INIT:	CLR	RW
	SETB 	ENAB
	CLR 	RS
	MOV	P0, #00H			; 2 line mode, 8 bits

	CLR 	RS
	MOV	A, #0EH			; turn lcd and cursor on
	LCALL 	SEND
	
	MOV	A, #06H			; cursor increments to the right
	LCALL 	SEND
	
	RET

WRITE_TEXT:
LOOP:	MOV	A, #00h
	MOVC	A, @A+DPTR
	CJNE	A, #'$', GO
	SJMP	PEND
GO:	INC	DPTR
	LCALL 	SEND	
	SJMP	LOOP

PEND:	RET			


WAIT:	SJMP DELAY
;
;DELAY:	MOV 	R2, #10D		; 2.53MS DELAY
;DELAY2:	MOV	R1, #10D			;
;DELAY1:	MOV 	R0, #10D			;((((R0*2)+3)*R1+3)*R2+3)*12/(f)
;	DJNZ	R0, $
;	DJNZ	R1, DELAY1
;	DJNZ 	R2, DELAY2
;			
;	RET
DELAY:	MOV	TH0, #06CH		; this is for the number of cycles for th1 interrupt
	MOV	TL0, #00H
	SETB	TR0
	JNB	TF0, $
	CLR	TF0
	CLR 	TR0
	RET

DELAY_30:	MOV	R5, #08H
LOOP_30:	LCALL 	WAIT
		DJNZ	R5, LOOP_30


	END

