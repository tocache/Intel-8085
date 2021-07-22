	.CR 8085	To load the 8085 cross overlay
	.TF blink13.hex,INT,32

	.OR $0000	;Zona de EEPROM, inicio de programa
	JMP INIT		;Salta a label INIT

	.OR $0050	;Zona de programa de usuario
INIT:	MVI A, 0D0H
	OUT 44H		;Carga de dato en registro LSB del Timer del 8155
	MVI A, 47H
	OUT 45H		;Carga de dato en registro MSB del Timer del 8155
	MVI A, 0C0H
	OUT 40H		;8155 con Timer iniciado

LOOP:	NOP
	JMP LOOP
