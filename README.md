# EncriptacionVisual

Uso: ruby encripta_imagen.rb archivo_entrada.pgm

Toma una imagen de un archivo *.PGM (en formato P2) y la convierte en dos 
archivos *.1.PGM y *.2.PGM tales que vistos por separado sólo contienen ruido, 
pero superpuestos se restaura razonablemente la imagen original (contiene 
también algo de ruido, pero si los trazos son gruesos el cerebro humano puede 
interpretar correctamente lo que había originalmente).

Options: 

--help                           Display this help and exit. 

--copyright                      Display copyright (author, date, email and 
                                 license) and exit. 

--version                        Output version information and exit. 

-e  --aumento-pixeles-entrada    Se aumenta cada pixel de entrada a 2**N x 2**N 
                                 pixeles. Legal values: 1..20. Default=1. 

-p  --patron                     Con esta opción se selecciona la forma de 
                                 transformar cada pixel de entrada en la salida; 
                                 Con -p=I se cambia cada pixel individualmente 
                                 al azar; con -p=H se elige al azar un patrón de 
                                 lineas horizontales o verticales que se 
                                 intersectan; con -p=S se elige al azar un 
                                 patrón de lineas horizontales o verticales que 
                                 no se intersectan; y con -p=A se elige al azar 
                                 un patrón de tipo 'tablero de ajedrez' o su 
                                 complementario. Legal values: ["I", "H", "S", 
                                 "A"]. Default=I. 

-s  --aumento-pixeles-salida     Se aumenta cada pixel de salida a 2**N x 2**N 
                                 pixeles. Legal values: 0..20. Default=0. 


El algoritmo de encriptar imagen consiste en lo siguiente:
- Los pixeles del archivo de entrada se saturan a blanco o a negro, según el nivel de gris que tengan.
- Si un pixel del archivo de entrada es blanco, en el archivo de salida 1 se guarda un pixel de color elegido al azar entre blanco y gris; y en el archivo de salida 2 justo lo contrario.
- Si un pixel del archivo de entrada es negro, en el archivo de salida 1 se guarda un pixel de color elegido al azar entre blanco y gris; y en el archivo de salida 2 justo lo mismo.
- Cuando se imprimen ambos archivos sobre papel transparente o translucido, y se superponen los dos papeles, el fondo sale gris y la imagen original aparece en negro. Pero mirando cada papel por separado, sólo contiene ruido (no hay forma de restaurar absolutamente nada de la imagen original a partir de uno solo de los papeles).

