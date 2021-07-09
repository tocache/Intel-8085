blink1.asm: Código para el auto fantástico, el 8085 tiene conectado un 8155 y mapeado en la dirección 0x4000.
Se está empleando el puerto PA(7..0) del 8155 para emitir el efecto del auto fantástico, por consiguiente se conectaron LEDs en dicho puerto.

blink2.asm: Código similar a blink1.asm pero el puerto de saluda empleado es el PA de un 8255 mapeado en la dirección 0x6000
