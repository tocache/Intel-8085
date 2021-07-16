;Interrupciones habilitadas con visualizacion en LCD de la fuente de interrupcion

	.CR 8085	To load the 8085 cross overlay
	.TF blink11.hex,INT,32

	.OR $0800	;Zona de EEPROM, datos constantes
MSG1: .DB "i8085 Example 11"
MSG3: .DB "Int7.5 received!"
MSG4: .DB "Int6.5 received!"
MSG5: .DB "Int5.5 received!"
	
	.OR $0000	;Zona de EEPROM, inicio de programa
	JMP INIT		;Salta a label INIT

	.OR $003C	;Vector de interrupcion 7.5
	JMP I75_ISR

	.OR $0034	;Vector de interrupcion 6.5
	JMP I65_ISR

	.OR $002C	;Vector de interrupcion 5.5
	JMP I55_ISR

	.OR $0050	;Zona de programa de usuario
INIT:	MVI A,0EH
	OUT 40H		;8155 con PA, PB y PC como salidas
	LXI SP,2FFFH	;Initialize Stack Pointer End of RAM 6264
	EI		;Habilitamos interrupciones
	MVI A, 08H
	SIM		;Interrupciones sin masking
	CALL LCDINIT	;Inicializacion del LCD
	MVI E, 10H
	LXI H, MSG1
	CALL LCDMSG	;Imprime MSG1 en la primera linea

LOOP:	NOP
	JMP LOOP	;Retorna a label LOOP

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

LCDMSG:	MOV B, H		;Enviar cadena a LCD
	MOV C, L
	MVI A, 01H
	OUT 43H
LAZO:	LDAX B
	OUT 42H
	CALL PULSOE2
	INX B
	NOP
	DCR E
	JNZ LAZO
	RET

LCDCLR:	MVI A,00H	;Comando para limpiar LCD
	OUT 43H	
	MVI A, 01H	
	OUT 42H
	CALL PULSOE
	RET

LCDL1:	MVI A,00H	;Comando para mover cursor a linea 1
	OUT 43H	
	MVI A, 02H	
	OUT 42H
	CALL PULSOE
	RET

LCDL2:	MVI A,00H	;Comando para mover cursor a linea 2
	OUT 43H	
	MVI A, 0C0H	
	OUT 42H
	CALL PULSOE
	RET

PULSOE2: MVI A, 05H	;Pulso en E para dato
	OUT 43H
	MVI A, 01H
	OUT 43H
	RET

PULSOE:	MVI A, 04H	;Pulso en E para comando
	OUT 43H
	MVI A, 00H
	OUT 43H
	RET

DELAY:	PUSH B		; Saving B. This delay subroutine uses 2 single registers A & D and 1 register pair BC
	PUSH D
	PUSH PSW	; Saving PSW
	MVI D, 0FFH	; Loading counter for outer loop
ST:	LXI B, 20H	; Loading counter for inner loop
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

I75_ISR:	CALL LCDL1
	MVI E, 10H
	LXI H, MSG3
	CALL LCDMSG	;Imprime MSG3 en la primera linea
	EI
	RET

I65_ISR:	CALL LCDL1
	MVI E, 10H
	LXI H, MSG4
	CALL LCDMSG	;Imprime MSG3 en la primera linea
	EI
	RET

I55_ISR:	CALL LCDL1
	MVI E, 10H
	LXI H, MSG5
	CALL LCDMSG	;Imprime MSG3 en la primera linea
	EI
	RET
