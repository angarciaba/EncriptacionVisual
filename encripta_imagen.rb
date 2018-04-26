#!/usr/bin/env ruby

# Archivo: encripta_imagen.rb
# Autor: Angel García Baños
# Email: angarcia@univalle.edu.co
# Fecha creación: 2007-10-08
# Fecha última modificación: 2018-04-26
# Versión: 0.2
# Download: http://eisc.univalle.edu.co/~angarcia/freeware
# Copyright (C) 2007-2008, Angel García Baños
# Licencia: GPL v2 (ver ???)

########################################
# El algoritmo de encriptar imagen consiste en lo siguiente:
# - Los pixeles del archivo de entrada se saturan a blanco o a negro, según el nivel de gris que tengan.
# - Si un pixel del archivo de entrada es blanco, en el archivo de salida 1 se guarda un pixel de color elegido al azar entre blanco y gris;
# y en el archivo de salida 2 justo lo contrario.
# - Si un pixel del archivo de entrada es negro, en el archivo de salida 1 se guarda un pixel de color elegido al azar entre blanco y gris;
# y en el archivo de salida 2 justo lo mismo.
# - Cuando se imprimen ambos archivos sobre papel transparente o translucido, y se superponen los dos papeles, el fondo sale gris y la imagen
# original aparece en negro. Pero mirando cada papel por separado, sólo contiene ruido (no hay forma de restaurar absolutamente nada de la
# imagen original a partir de uno solo de los papeles).
########################################



require_relative 'getoptcom'


class EncriptarImagen


  # Constantes:
  VERSION = 0.2
  EXTENSION_OBLIGATORIA = "PGM"
  FORMATO_SOPORTADO = "P2"
  AMPLIACION_ENTRADA = (1..20)
  AMPLIACION_SALIDA = (0..20)
  PATRONES_DISPONIBLES = ['I','H','S','A']


  def initialize(nombre_archivo_entrada, exponente_pixeles_aumento_entrada, patron, exponente_pixeles_aumento_salida)
    raise "El exponente para aumentar los pixeles de entrada debe ser #{AMPLIACION_ENTRADA}" if not AMPLIACION_ENTRADA === exponente_pixeles_aumento_entrada
    raise "El exponente para aumentar los pixeles de salida debe ser #{AMPLIACION_SALIDA}" if not AMPLIACION_SALIDA === exponente_pixeles_aumento_salida
 
    case patron
    when PATRONES_DISPONIBLES[0]  # patrón de pixeles individuales (por defecto)
      @matriz =["rrrr", "cccc"]  # r es un número aleatorio y "c" es su complementario
    when PATRONES_DISPONIBLES[1]  # patrón de líneas horizontales y verticales con intersecciones
      @matriz =["1100", "1010"]
    when PATRONES_DISPONIBLES[2]  # patrón de líneas horizontales y verticales sin intersecciones
      @matriz =["1010", "0101"]
    when PATRONES_DISPONIBLES[3]  # patrón de cuadrícula similar a tablero de ajedrez
      @matriz =["1001", "0110"]
    else
      raise "Patrón inexistente"
    end

    @nombre_archivo_entrada = nombre_archivo_entrada
    @pixeles_aumento_entrada = 2**(exponente_pixeles_aumento_entrada-1)
    @pixeles_aumento_salida = 2**exponente_pixeles_aumento_salida
    @recordar_numeros_aleatorios = []
    @guardando_numeros_aleatorios = true

    # Nombres de archivos a usar:
    raise "El archivo #{@nombre_archivo_entrada} debería tener extensión #{EXTENSION_OBLIGATORIA}" unless @nombre_archivo_entrada =~ Regexp.new("\\." + EXTENSION_OBLIGATORIA + "$", Regexp::IGNORECASE)
    @nombre_archivo_salida1 = quitar_extension(@nombre_archivo_entrada) + ".1.#{EXTENSION_OBLIGATORIA}"
    @nombre_archivo_salida2 = quitar_extension(@nombre_archivo_entrada) + ".2.#{EXTENSION_OBLIGATORIA}"
  end


  def quitar_extension(nombre_archivo)
    path_y_nombre = File.split(nombre_archivo)
    indice_del_punto = path_y_nombre[1].rindex(".")
    raise "Nombre de archivo incorrecto #{path_y_nombre[1]}" if indice_del_punto.nil? or path_y_nombre[1].length == 0 or path_y_nombre[1] == "." or path_y_nombre[1] == ".." or path_y_nombre[1] == "/"
    File.join(path_y_nombre[0], path_y_nombre[1].slice(0...indice_del_punto))
  end


  def encriptar
    begin
      @salida1 = File.open(@nombre_archivo_salida1, "w")
      @salida2 = File.open(@nombre_archivo_salida2, "w")
      @numero_de_linea = 0
      @numero_de_pixel = 0
      @linea1_salida1 = ""
      @linea2_salida1 = ""
      @linea1_salida2 = ""
      @linea2_salida2 = ""
      entrada = File.open(@nombre_archivo_entrada, "r").each do |linea|
        linea.chomp!
        @numero_de_linea += 1
        procesar_cabecera(linea)
        if not cabecera? then
          procesar_el_resto(linea)
        end
      end

    rescue
      raise
    ensure
      @salida1.close unless @salida1.nil?
      @salida2.close unless @salida2.nil?
      entrada.close unless entrada.nil?
    end
  end


  def procesar_cabecera(linea)
    if linea =~ /^\s*#/ then           # Los comentarios se escriben en ambos archivos
      @numero_de_linea -=1             # Los comentarios no se cuentan como líneas de datos
      @salida1.puts linea
      @salida2.puts linea
    elsif @numero_de_linea==1 then     # La primera línea indica el formato de la imagen, que debe de ser @@FORMATO_SOPORTADO y debe escribirse en ambos archivos de salida
      raise "El formato del archivo de imagen debe de ser #{FORMATO_SOPORTADO} (y no #{linea})" unless linea == FORMATO_SOPORTADO
      @salida1.puts linea
      @salida2.puts linea
    elsif @numero_de_linea==2 then    # La segunda linea es la resolución, que hay que escribirla en ambos archivos
      @pixeles_horizontales = linea.split[0].to_i
      @pixeles_verticales= linea.split[1].to_i
      @salida1.puts "#{@pixeles_horizontales*2*@pixeles_aumento_entrada*@pixeles_aumento_salida} #{@pixeles_verticales*2*@pixeles_aumento_entrada*@pixeles_aumento_salida}\n"
      @salida2.puts "#{@pixeles_horizontales*2*@pixeles_aumento_entrada*@pixeles_aumento_salida} #{@pixeles_verticales*2*@pixeles_aumento_entrada*@pixeles_aumento_salida}\n"
    elsif @numero_de_linea==3 then    # La tercera linea es el color blanco, que hay que escribirlo en ambos archivos
      @@BLANCO = linea.to_i
      @@NEGRO = 0
      @@GRIS = (@@BLANCO + @@NEGRO)/2
      @salida1.puts linea
      @salida2.puts linea
    end
  end


  def cabecera?
    @numero_de_linea<=3
  end


  def procesar_el_resto(linea)       # Las demás líneas son de datos (pixeles). En cada línea puede haber varios datos, separados por espacios
    linea.split.each do |valor|
      @numero_de_pixel += 1
      if(valor.to_i >= @@GRIS) then
        if rand < 0.5 then
          pintar(@matriz[0], @matriz[1])
        else
          pintar(@matriz[1], @matriz[0])
        end
      else
        if rand < 0.5 then
          pintar(@matriz[0], @matriz[0])
        else
          pintar(@matriz[1], @matriz[1])
        end
      end

      if @numero_de_pixel == @pixeles_horizontales then
        @pixeles_aumento_entrada.times { @pixeles_aumento_salida.times { @salida1.puts @linea1_salida1 } ; @pixeles_aumento_salida.times { @salida1.puts @linea2_salida1 } }
        @pixeles_aumento_entrada.times { @pixeles_aumento_salida.times { @salida2.puts @linea1_salida2 } ; @pixeles_aumento_salida.times { @salida2.puts @linea2_salida2 } }
        @numero_de_pixel = 0
        @linea1_salida1 = ""
        @linea2_salida1 = ""
        @linea1_salida2 = ""
        @linea2_salida2 = ""
      end
    end
  end


  def pintar(matriz1, matriz2)
      @pixeles_aumento_entrada.times do
        @pixeles_aumento_salida.times { @linea1_salida1 += "#{convertir(matriz1[0])}\n" }
        @pixeles_aumento_salida.times { @linea1_salida1 += "#{convertir(matriz1[1])}\n" }
      end
      @pixeles_aumento_entrada.times do
        @pixeles_aumento_salida.times { @linea2_salida1 += "#{convertir(matriz1[2])}\n" }
        @pixeles_aumento_salida.times { @linea2_salida1 += "#{convertir(matriz1[3])}\n" }
      end

      @pixeles_aumento_entrada.times do
        @pixeles_aumento_salida.times { @linea1_salida2 += "#{convertir(matriz2[0])}\n" }
        @pixeles_aumento_salida.times { @linea1_salida2 += "#{convertir(matriz2[1])}\n" }
      end
      @pixeles_aumento_entrada.times do
        @pixeles_aumento_salida.times { @linea2_salida2 += "#{convertir(matriz2[2])}\n" }
        @pixeles_aumento_salida.times { @linea2_salida2 += "#{convertir(matriz2[3])}\n" }
      end
  end


  def convertir(valor)
    raise "INTERNO 3 (#{valor}). Códigos válidos = '01rc'" unless "01rc".include?(valor)
    return @@BLANCO if valor == ?0
    return @@NEGRO if valor == ?1
    if rand < 0.5 then x = @@NEGRO else x = @@BLANCO end
    if @recordar_numeros_aleatorios.length == 4*@pixeles_aumento_entrada*@pixeles_aumento_salida then @guardando_numeros_aleatorios = false end
    if @guardando_numeros_aleatorios then @recordar_numeros_aleatorios << x else x = @recordar_numeros_aleatorios.shift end
    if @recordar_numeros_aleatorios.length == 0 then @guardando_numeros_aleatorios = true end

    if valor == ?r then
      return x
    else
      return @@BLANCO - x   # El color complementario
    end
  end


end





class EncriptarImagenConArgumentosDeLineaDeEjecucion < EncriptarImagen

  def initialize
    # Opciones posibles:
    opciones = GetOptCom.new
    opciones.habitual_info("Uso: encripta_imagen archivo_entrada", "Toma una imagen de un archivo *.#{EXTENSION_OBLIGATORIA} (en formato #{FORMATO_SOPORTADO}) y la convierte en dos archivos *.1.#{EXTENSION_OBLIGATORIA} y *.2.#{EXTENSION_OBLIGATORIA} tales que vistos por separado sólo contienen ruido, pero superpuestos se restaura razonablemente la imagen original (contiene también algo de ruido, pero si los trazos son gruesos el cerebro humano puede interpretar correctamente lo que había originalmente)", "2007-2008, Angel García Baños (angarcia@univalle.edu.co, http://eisc.univalle.edu.co/~angarcia/freeware), licencia GPL v2", "#{VERSION}")

    opciones.add(["-e", "--aumento-pixeles-entrada"], GetOptCom::OPTIONAL_OPTION, GetOptCom::REQUIRED_ARGUMENT, AMPLIACION_ENTRADA, 1, "Se aumenta cada pixel de entrada a 2**N x 2**N pixeles")
    opciones.add(["-p", "--patron"], GetOptCom::OPTIONAL_OPTION, GetOptCom::REQUIRED_ARGUMENT, PATRONES_DISPONIBLES, "I", "Con esta opción se selecciona la forma de transformar cada pixel de entrada en la salida; Con -p=I se cambia cada pixel individualmente al azar; con -p=H se elige al azar un patrón de lineas horizontales o verticales que se intersectan; con -p=S se elige al azar un patrón de lineas horizontales o verticales que no se intersectan; y con -p=A se elige al azar un patrón de tipo 'tablero de ajedrez' o su complementario")
    opciones.add(["-s", "--aumento-pixeles-salida"], GetOptCom::OPTIONAL_OPTION, GetOptCom::REQUIRED_ARGUMENT, AMPLIACION_SALIDA, 0, "Se aumenta cada pixel de salida a 2**N x 2**N pixeles")

    opciones.number_of_strings_arguments_without_option(1)  # Aqui debe venir el nombre del archivo

    puts opciones.process!
    exit if opciones.exit?

    super(opciones.strings_arguments_without_option[0], opciones["-e"], opciones["-p"], opciones["-s"])
  end

end





if $0 == __FILE__ then
  begin
    imagen = EncriptarImagenConArgumentosDeLineaDeEjecucion.new
    imagen.encriptar
  rescue StandardError => excepcion
    puts "PROBLEMA: #{excepcion}"
  end
end

