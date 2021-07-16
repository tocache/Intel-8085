;Contador autoincremental 000-255 con visualización en LCD que esta conectado en el 8155
;Visualizacion de las unidades en displays 7 segmentos en PB del 8255
;Visualizacion de la cuenta en binario por PB drel 8255
;Estado de las interrupciones en PA del 8155
;Interrupciones habilitadas con visualizacion en LCD de la fuente de interrupcion

	.CR 8085	To load the 8085 cross overlay
	.TF blink10.hex,INT,32

	.OR $0800	;Zona de EEPROM, datos constantes
MSG1: .DB "i8085 Example 10"
MSG2: .DB "Counter:"
MSG3: .DB "Int7.5 received!"
MSG4: .DB "Int6.5 received!"
MSG5: .DB "Int5.5 received!"

DEC7S: .DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,67H,79H,79H,79H,79H,79H,79H

DIGTMP 	.EQU 2000H
DIGCEN	.EQU 2001H
DIGDEC	.EQU 2002H
DIGUNI	.EQU 2003H
CTA	.EQU 2004H
	
	.OR $0000	;Zona de EEPROM, inicio de programa
	JMP INIT		;Salta a label INIT

	.OR $003C	;Vector de interrupcion 7.5
	JMP I75_ISR

	.OR $0034	;Vector de interrupcion 6.5
	JMP I65_ISR

	.OR $002C	;Vector de interrupcion 5.5
	JMP I55_ISR

	.OR $0050	;Zona de programa de usuario
INIT:	MVI A,0FH
	OUT 40H		;8155 con PA, PB y PC como salidas
	MVI A,89H
	OUT 63H		;8255 con PA  y PB como salidas
	LXI SP,2FFFH	;Initialize Stack Pointer End of RAM 6264
	EI		;Habilitamos interrupciones
	MVI A, 08H
	SIM		;Interrupciones sin masking
	CALL LCDINIT	;Inicializacion del LCD
	MVI E, 10H
	LXI H, MSG1
	CALL LCDMSG	;Imprime MSG1 en la primera linea
	CALL LCDL2	;A la segunda linea
	MVI E, 08H
	LXI H, MSG2
	CALL LCDMSG	;Imprime MSG2 en la segunda linea

	MVI A, 00H
	STA CTA
LOOP:	RIM
	OUT 41H		;Mandamos a PA el estado de la interrupcion
	LDA CTA
	OUT 60H		;Mandamos la cuenta binaria a PA del 8255
	MOV D, A
	CALL DIGBYTE	;Llamo a subrutina para sacar digitos individuales
	CALL LCDP29	;Muevo el cursor del LCD a 2,9
	LDA DIGCEN	;Llamo a la centena
	CALL LCDNUM	;Mando el digito centena al LCD
	LDA DIGDEC	;Llamo a la decena
	CALL LCDNUM	;Mando el digito decena al LCD
	LDA DIGUNI	;Llamo a la unidad
	CALL LCDNUM	;Mando el digito unidad al LCD
	CALL D7S	;Mandamos la unidad al display de 7 segmentos en PB del 8255
	MVI A, 255	;\
	SUB D		;/ Implementacion de if(cuenta=218) empleando flag Z
	JZ LIMPIO	;Viene aqui cuando se cumplio con lo anterior, salto a label limpio
	MVI A, 30
	SUB D
	JZ LCDREF	;Condicion para que cuando llegue a 50 la cuenta mande MSG1
	INR D		;Salta aqui cuando no se cumplio lo anterior, incremento la cuenta
	MOV A, D
	STA CTA
	CALL DELAY	;Llamada a retardo
	JMP LOOP	;Retorna a label LOOP
LIMPIO:	MVI D, 00H	;Inicia a cero la cuenta
	MOV A, D
	STA CTA
	CALL DELAY	;Llamada a subrutina de retardo
	JMP LOOP	;Retorna a label LOOP
LCDREF:	CALL LCDL1
	MVI E, 10H
	LXI H, MSG1
	CALL LCDMSG	;Imprime MSG1 en la primera linea
	INR D
	MOV A, D
	STA CTA
	CALL DELAY	;Llamada a subrutina de retardo
	JMP LOOP	;Retorna a label LOOP

D7S:	LXI H, DEC7S	;Apuntamos a cadena DEC7A, la direccion base apuntada se aloja en H:L
	MOV B, H		;La dirección debe de estar en B:C para sacar el contenido
	LDA DIGUNI	;Obtenemos el dato que hará el offset de la dirección
	ADD L		;Sumamos el dato con la direccion base apuntada para hacer el offset
	MOV C, A		;Movemos el reg A hacia reg C para completar el B:C
	LDAX B		;Sacamos el dato que se encuentra en B:C
	OUT 61H
	RET
	
DIGBYTE:	 MVI A, 00H	;Rutina para obtener los digitos de reg D
	STA DIGCEN
	STA DIGDEC
	STA DIGUNI	;Limpio todos los registros de digitos
	MOV A, D		;Cargo en reg A valor de ingreso que esta en reg D
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
	;CALL DELAY
	CALL PULSOE
	RET

LCDL1:	MVI A,00H	;Comando para mover cursor a linea 1
	OUT 43H	
	MVI A, 02H	
	OUT 42H
	;CALL DELAY
	CALL PULSOE
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

I75_ISR:	MVI D, 00H	;Mandamos cuenta del contador a cero
	MOV A, D
	STA CTA
	CALL LCDL1
	MVI E, 10H
	LXI H, MSG3
	CALL LCDMSG	;Imprime MSG3 en la primera linea
	EI
	RET

I65_ISR:	MVI D, 00H	;Mandamos cuenta del contador a cero
	MOV A, D
	STA CTA
	CALL LCDL1
	MVI E, 10H
	LXI H, MSG4
	CALL LCDMSG	;Imprime MSG3 en la primera linea
	EI
	RET

I55_ISR:	MVI D, 00H	;Mandamos cuenta del contador a cero
	MOV A, D
	STA CTA
	CALL LCDL1
	MVI E, 10H
	LXI H, MSG5
	CALL LCDMSG	;Imprime MSG3 en la primera linea
	EI
	RET
