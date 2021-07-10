	.CR 8085	To load the 8085 cross overlay

	.TF lcd_test.hex,INT,32
	.OR $0000

	MVI A,0EH
	OUT 40H		;8155 con PB y PC como salidas
	MVI A,8FH
	OUT 63H		;8255 con PA como salidas
		
	LXI SP,2FFFH	;Initialize Stack Pointer End of RAM 6264

	CALL LCDINIT	;Inicializacion del LCD
	CALL LCDMSG	;Imprime Hola mundo! en la primera linea
	CALL LCDL2	;Cursor en la segunda linea
	CALL LCDMSG2	;Imprime Intel 8085 ready en la seguna linea
		
LOOP:	NOP
	JMP LOOP

LCDINIT:	MVI A,00H	;Rutina de inicialización para el LCD
	OUT 43H		;RS=0,RW=0,E=0
	CALL DELAY
	MVI A, 30H	;Primer 30H
	OUT 42H
	CALL DELAY
	CALL PULSOE
	MVI A, 30H	;Segundo 30H
	OUT 42H
	CALL DELAY
	CALL PULSOE
	MVI A, 30H	;Tercer 30H
	OUT 42H
	CALL DELAY
	CALL PULSOE
	MVI A, 30H	;Tercer 30H
	OUT 42H
	CALL DELAY
	CALL PULSOE
	MVI A, 38H	;Primera funcion real
	OUT 42H
	CALL DELAY
	CALL PULSOE
	MVI A, 08H	;Display on/off control
	OUT 42H
	CALL DELAY
	CALL PULSOE
	MVI A, 01H	;Clear display
	OUT 42H
	CALL DELAY
	CALL PULSOE
	MVI A, 06H	;Entry mode set
	OUT 42H
	CALL DELAY
	CALL PULSOE
	MVI A, 0CH	;Display on/off control
	OUT 42H
	CALL DELAY
	CALL PULSOE
	RET

LCDMSG:	MVI A, 01H	;Mensaje Hola mundo!
	OUT 43H
	MVI A, 'H'
	OUT 42H
	CALL PULSOE2
	MVI A, 'o'
	OUT 42H
	CALL PULSOE2
	MVI A, 'l'
	OUT 42H
	CALL PULSOE2
	MVI A, 'a'
	OUT 42H
	CALL PULSOE2
	MVI A, ' '
	OUT 42H
	CALL PULSOE2
	MVI A, 'M'
	OUT 42H
	CALL PULSOE2
	MVI A, 'u'
	OUT 42H
	CALL PULSOE2
	MVI A, 'n'
	OUT 42H
	CALL PULSOE2
	MVI A, 'd'
	OUT 42H
	CALL PULSOE2
	MVI A, 'o'
	OUT 42H
	CALL PULSOE2
	MVI A, '!'
	OUT 42H
	CALL PULSOE2
	RET

LCDMSG2: MVI A, 01H	;Mensaje Intel 8085 ready
	OUT 43H
	MVI A, 'I'
	OUT 42H
	CALL PULSOE2
	MVI A, 'n'
	OUT 42H
	CALL PULSOE2
	MVI A, 't'
	OUT 42H
	CALL PULSOE2
	MVI A, 'e'
	OUT 42H
	CALL PULSOE2
	MVI A, 'l'
	OUT 42H
	CALL PULSOE2
	MVI A, ' '
	OUT 42H
	CALL PULSOE2
	MVI A, '8'
	OUT 42H
	CALL PULSOE2
	MVI A, '0'
	OUT 42H
	CALL PULSOE2
	MVI A, '8'
	OUT 42H
	CALL PULSOE2
	MVI A, '5'
	OUT 42H
	CALL PULSOE2
	MVI A, ' '
	OUT 42H
	CALL PULSOE2
	MVI A, 'r'
	OUT 42H
	CALL PULSOE2
	MVI A, 'e'
	OUT 42H
	CALL PULSOE2
	MVI A, 'a'
	OUT 42H
	CALL PULSOE2
	MVI A, 'd'
	OUT 42H
	CALL PULSOE2
	MVI A, 'y'
	OUT 42H
	CALL PULSOE2
	RET

LCDL2:	MVI A,00H	;Comando para mover cursor a linea 2
	OUT 43H	
	MVI A, 0C0H	
	OUT 42H
	CALL DELAY
	CALL PULSOE
	RET

PULSOE2: MVI A, 05H	;Pulso en E para dato
	OUT 43H
	CALL DELAY
	MVI A, 01H
	OUT 43H
	CALL DELAY
	RET

PULSOE:	MVI A, 04H	;Pulso en E para comando
	OUT 43H
	CALL DELAY
	MVI A, 00H
	OUT 43H
	CALL DELAY
	RET
	
DELAY:	PUSH B		; Saving B. This delay subroutine uses 2 single registers A & D and 1 register pair BC
	PUSH D
	PUSH PSW	; Saving PSW
	MVI D, 0FFH	; Loading counter for outer loop
ST:	LXI B, 08H	; Loading counter for inner loop
L:	DCX B		; Decrement inner counter
	MOV A, C		; If not exhausted go again for inner loop
	ORA B	
	JNZ L	
	DCR D		; Decrement outer counter
	JNZ ST		; If not exhausted go again for outer loop
	POP PSW		; Restore PSW
	POP D
	POP B		; Restore B
	RET