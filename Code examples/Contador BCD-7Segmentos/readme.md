Contador autoincremental 0-9 (BCD) con visualización en un display de siete segmentos del tipo cátodo común.

-La decodificación para el display de siete segmentos se esta realizando con una tabla de búsqueda (LUT).
-El display de siete segmentos del tipo cátodo común se encuentra conectado en el PB del 8255 con dirección 6000H.

blink6:
  -Primera versión del programa, empleando regE en decremento y pregunta a flagZ como función de condición de haber llegado a la cuenta 9 y hacer la cuenta a 0
  
blink7:
  -Versión mejorada, empleando una resta y pregunta a flagZ como función de condición de cuenta igual a 9, si se cumple sera cuenta=0 y si no cumple cuenta++ 
