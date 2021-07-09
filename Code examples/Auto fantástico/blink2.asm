	.CR 8085	To load the 8085 cross overlay

	.TF blink2.hex,INT,32
	.OR $0000

	MVI A,8FH
	OUT 63H		; Initialize 8255 (PA output)
		
	LXI SP,2FFFH	; Initialize Stack Pointer End of RAM 6264
;	LXI SP,40FFH	; Initialize Stack Pointer End of RAM 8155
		
LOOP:	MVI A,01H
	OUT 60H
	CALL DELAY
	MVI A,02H
	OUT 60H	
	CALL DELAY
	MVI A,04H
	OUT 60H	
	CALL DELAY
	MVI A,08H
	OUT 60H	
	CALL DELAY
	MVI A,10H
	OUT 60H	
	CALL DELAY
	MVI A,20H
	OUT 60H	
	CALL DELAY
	MVI A,40H
	OUT 60H	
	CALL DELAY
	MVI A,80H
	OUT 60H	
	CALL DELAY
	MVI A,40H
	OUT 60H	
	CALL DELAY
	MVI A,20H
	OUT 60H	
	CALL DELAY
	MVI A,10H
	OUT 60H	
	CALL DELAY
	MVI A,08H
	OUT 60H	
	CALL DELAY
	MVI A,04H
	OUT 60H	
	CALL DELAY
	MVI A,02H
	OUT 60H	
	CALL DELAY
	JMP LOOP
	
DELAY:	PUSH B		; Saving B. This delay subroutine uses 2 single registers A & D and 1 register pair BC
	PUSH D
	PUSH PSW	; Saving PSW
	MVI D, 0FFH	; Loading counter for outer loop
ST:	LXI B, 10H	; Loading counter for inner loop
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