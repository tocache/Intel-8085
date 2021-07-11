	.CR 8085	To load the 8085 cross overlay
	.TF blink7.hex,INT,32

	.OR $0800	
DEC7S: .DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,67H,79H,79H,79H,79H,79H,79H

	.OR $0000
INIT:	MVI A,89H
	OUT 63H		;8255 con PA  y PB como salidas
		
	LXI SP,2FFFH	;Initialize Stack Pointer End of RAM 6264

	MVI D, 00H	;Valor inicial de la cuenta (0)

LOOP:	LXI H, DEC7S	;Obtengo la dirección de la cadena DEC7S
	MOV B, H		;Para que se pueda sacar el dato de la cadena la
	MOV A, D		;Dirección debe de estar en reg B:C pero debemos sumarle
	ADD L		;el valor de D (la cuenta) para que funcione como LUT
	MOV C, A
	LDAX B		;Obtención del dato apuntado en cadena y se almacena en reg A
	OUT 61H		;Envío de datos al PB del 8255 que esta en dirección 6000H
	MVI A, 09H	;\
	SUB D		;/ Implementacion de if(cuenta=9) empleando flag Z
	JZ LIMPIO	;Viene aqui cuando se cumplio con lo anterior, salto a label limpio
	INR D		;Salta aqui cuando no se cumplio lo anterior, incremento la cuenta
	CALL DELAY	;Llamada a retardo
	JMP LOOP	;Retorna a label LOOP

LIMPIO: MVI D, 00H	;Inicia a cero la cuenta
	CALL DELAY	;Llamada a subrutina de retardo
	JMP LOOP	;Retorna a label LOOP

DELAY:	PUSH B		; Saving B. This delay subroutine uses 2 single registers A & D and 1 register pair BC
	PUSH D
	PUSH PSW	; Saving PSW
	MVI D, 0FFH	; Loading counter for outer loop
ST:	LXI B, 90H	; Loading counter for inner loop
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