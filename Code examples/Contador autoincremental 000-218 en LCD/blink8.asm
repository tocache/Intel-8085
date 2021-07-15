;Contador autoincremental 000-218 con visualización en LCD qu esta conectado en el 8155
	.CR 8085	To load the 8085 cross overlay
	.TF blink8.hex,INT,32

	.OR $0800	;Zona de EEPROM, datos constantes
MSG1: .DB "i8085 Example 8"
MSG2: .DB "Counter:"

DIGTMP 	.EQU 2000H
DIGCEN	.EQU 2001H
DIGDEC	.EQU 2002H
DIGUNI	.EQU 2003H
	
	.OR $0000	;Zona de EEPROM, inicio de programa
INIT:	MVI A,0EH
	OUT 40H		;8155 con PB y PC como salidas
	LXI SP,2FFFH	;Initialize Stack Pointer End of RAM 6264
	CALL LCDINIT	;Inicializacion del LCD
	CALL LCDMSG	;Imprime MSG1 en la primera linea
	CALL LCDL2	;A la segunda linea
	CALL LCDMSG2	;Imprime MSG2 en la segunda linea

	MVI D, 00H	;Valor inicial de la cuenta (0)
LOOP:	MOV B, D
	CALL DIGBYTE	;Llamo a subrutina para sacar digitos individuales
	CALL LCDP29	;Muevo el cursor del LCD a 2,9
	LDA DIGCEN	;Llamo a la centena
	CALL LCDNUM	;Mando el digito centena al LCD
	LDA DIGDEC	;Llamo a la decena
	CALL LCDNUM	;Mando el digito decena al LCD
	LDA DIGUNI	;Llamo a la unidad
	CALL LCDNUM	;MAndo el digito unidad al LCD
	MVI A, 218	;\
	SUB D		;/ Implementacion de if(cuenta=218) empleando flag Z
	JZ LIMPIO	;Viene aqui cuando se cumplio con lo anterior, salto a label limpio
	INR D		;Salta aqui cuando no se cumplio lo anterior, incremento la cuenta
	CALL DELAY	;Llamada a retardo
	JMP LOOP	;Retorna a label LOOP
LIMPIO: MVI D, 00H	;Inicia a cero la cuenta
	CALL DELAY	;Llamada a subrutina de retardo
	JMP LOOP	;Retorna a label LOOP

DIGBYTE:	 MVI A, 00H	;Rutina para obtener los digitos de reg B
	STA DIGCEN
	STA DIGDEC
	STA DIGUNI	;Limpio todos los registros de digitos
	MOV A, B		;Cargo en reg A valor de ingreso que esta en reg B
	MVI C, 100	
LABEL1:	LXI H, DIGCEN
	INR M		;Incremento reg DIGCEN
	SUB C		;Resto reg A - reg C
	JNC LABEL1	;Salto si carry flag = 0 (resultado positivo en resta)
	LXI H, DIGCEN	;Cuando carry flag = 1 (resultado negativo en resta)
	DCR M		;Decremento reg DIGCEN
	ADD C		;Sumo reg A + reg C (tiene el valor de 100)
	MVI C, 10
LABEL2:	LXI H, DIGDEC
	INR M		;Incremento reg DIGCEN
	SUB C		;Resto reg A - reg C
	JNC LABEL2	;Salto si carry flag = 0 (resultado positivo en resta)
	LXI H, DIGDEC	;Cuando carry flag = 1 (resultado negativo en resta)
	DCR M		;Decremento reg DIGCEN
	ADD C		;Sumo reg A + reg C (tiene el valor de 10)
	STA DIGUNI	;Almaceno reg A en reg DIGUNI	
	RET

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
	MVI E, 0FH
	LXI H, MSG1
	MOV B, H
	MOV C, L
LAZO:	LDAX B
	OUT 42H
	CALL PULSOE2
	INX B
	NOP
	DCR E
	JNZ LAZO
	RET

LCDMSG2: MVI A, 01H	;Mensaje Intel8085 inside
	OUT 43H
	MVI E, 08H
	LXI H, MSG2
	MOV B, H
	MOV C, L
LAZO2:	LDAX B
	OUT 42H
	CALL PULSOE2
	INX B
	NOP
	DCR E
	JNZ LAZO2
	RET

LCDL2:	MVI A,00H	;Comando para mover cursor a linea 2
	OUT 43H	
	MVI A, 0C0H	
	OUT 42H
	;CALL DELAY
	CALL PULSOE
	RET

LCDP29:	MVI A,00H	;Comando para mover cursor a posicion 2,9
	OUT 43H	
	MVI A, 0C9H	
	OUT 42H
	;CALL DELAY
	CALL PULSOE
	RET

LCDNUM: ADI 30H		;Rutina para visualizar un digito numérico en el LCD
	OUT 42H
	CALL PULSOE2
	RET

PULSOE2: MVI A, 05H	;Pulso en E para dato
	OUT 43H
	;CALL DELAY
	MVI A, 01H
	OUT 43H
	;CALL DELAY
	RET

PULSOE:	MVI A, 04H	;Pulso en E para comando
	OUT 43H
	;CALL DELAY
	MVI A, 00H
	OUT 43H
	;CALL DELAY
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