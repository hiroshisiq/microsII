;;;;;;;;;;;;;;;	HEADER ;;;;;;;;;;;;;;;;;;
	BX	EQU P2
	LX	EQU P0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ORG 0

MAIN:	MOV 	LX, BX		; Lê dos botões, e escreve na mesma ordem nos LED's
	SJMP 	MAIN		; Repete
	
	END


