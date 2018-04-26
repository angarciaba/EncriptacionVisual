#!/usr/bin/env ruby

# Archivo: tc_getoptcom.rb
# Autor: Angel García Baños
# Email: angarcia@univalle.edu.co
# Fecha creación: 2007-10-14
# Fecha última modificación: 2007-10-16
# Versión: 0.1
# Download: http://eisc.univalle.edu.co/~angarcia/freeware
# Copyright (C) 2007-2008, Angel García Baños
# Licencia: GPL v2 (ver ???)

########################################
# Una clase de test para GetOptCom
########################################
$:.unshift File.join(File.dirname(__FILE__), "..")

require 'getoptcom'
require 'test/unit'



class Test_GetOptCom < Test::Unit::TestCase
  USO = "Uso: prueba"
  DESCRIPCION = "Descripción"
  COPYRIGHT = "2007-2008, Angel García Baños (angarcia@univalle.edu.co, http://eisc.univalle.edu.co/~angarcia/freeware), licencia GPL v2"
  VERSION = 0.1
  TEST = [
           [["-a", "--a-opcion-larga"], GetOptCom::OPTIONAL_OPTION, GetOptCom::NO_ARGUMENT, nil, nil, "Comentario a -a"],
           [["-b", "--b-opcion-larga", "--b-opcion-muy-larga"], GetOptCom::OPTIONAL_OPTION, GetOptCom::OPTIONAL_ARGUMENT | GetOptCom::COULD_BE_MANY_ARGUMENTS, GetOptCom::STRING_TYPE, "B_opcional", "Comentario a -b"],
           [["-e", "--e-opcion-larga"], GetOptCom::OPTIONAL_OPTION, GetOptCom::REQUIRED_ARGUMENT, (0..20), nil, "Comentario a -e"],
           [["-p", "--p-opcion-larga"], GetOptCom::REQUIRED_OPTION, GetOptCom::OPTIONAL_ARGUMENT, ['I','H','D','A'], "I", "Comentario a -p. Por defecto -p=I"],
           [["-s", "--s-opcion-larga"], GetOptCom::OPTIONAL_OPTION, GetOptCom::OPTIONAL_ARGUMENT, GetOptCom::FLOAT_TYPE, -1.5, "Comentario a -s. Por defecto -s=-1.5"],
         ]

  def test_basico_1
    opciones = GetOptCom.new(%w{-e 2 --p-opcion-larga A -s=3.5 archivo0.txt archivo1.txt})
    opciones.habitual_info(USO, DESCRIPCION, COPYRIGHT, VERSION)
    TEST.each do |options_list, option_flags, argument_flags, valid_argument, default_argument, comment|
      opciones.add(options_list, option_flags, argument_flags, valid_argument, default_argument, comment)
    end
    opciones.number_of_strings_arguments_without_option(2)
    assert_raise(RuntimeError) {opciones.add(["-a"], GetOptCom::OPTIONAL_OPTION, GetOptCom::REQUIRED_ARGUMENT, GetOptCom::STRING_TYPE, nil,"cc")}
    assert_raise(RuntimeError) {opciones.add(["x"], GetOptCom::OPTIONAL_OPTION, GetOptCom::REQUIRED_ARGUMENT, GetOptCom::STRING_TYPE, nil, "cc")}
    assert_raise(RuntimeError) {opciones.add(["-x=h"], GetOptCom::OPTIONAL_OPTION, GetOptCom::REQUIRED_ARGUMENT, GetOptCom::STRING_TYPE, nil, "cc")}
    assert_raise(RuntimeError) {opciones.add(["-xx"], GetOptCom::OPTIONAL_OPTION, GetOptCom::REQUIRED_ARGUMENT, GetOptCom::STRING_TYPE, nil, "cc")}
    assert_raise(RuntimeError) {opciones.add(["-m"], GetOptCom::OPTIONAL_OPTION, GetOptCom::REQUIRED_ARGUMENT, (1..4), 5, "cc")}
    assert_nothing_raised(RuntimeError) {opciones.process!}
    assert((not opciones.exit?))
    assert_raise(RuntimeError) {opciones.add(["-x"], GetOptCom::OPTIONAL_OPTION, GetOptCom::REQUIRED_ARGUMENT, GetOptCom::STRING_TYPE, nil, "cc")}

    assert_equal(opciones.exists?("-a"), false)
    assert_equal(opciones.exists?("--a-opcion-larga"), false)
    assert_equal(opciones.exists?("-b"), false)
    assert_equal(opciones.exists?("--b-opcion-larga"), false)
    assert_equal(opciones.exists?("-e"), true)
    assert_equal(opciones.exists?("--e-opcion-larga"), true)
    assert_equal(opciones.exists?("-p"), true)
    assert_equal(opciones.exists?("--p-opcion-larga"), true)
    assert_equal(opciones.exists?("-s"), true)
    assert_equal(opciones.exists?("--s-opcion-larga"), true)

    assert_equal(opciones.exists?("-a"), false)
    assert_equal(opciones.exists?("-b"), false)
    assert_equal(opciones["-e"], 2)
    assert_equal(opciones["--e-opcion-larga"], 2)
    assert_equal(opciones["-p"], "A")
    assert_equal(opciones["--p-opcion-larga"], "A")
    assert_equal(opciones["-s"], 3.5)
    assert_equal(opciones["--s-opcion-larga"], 3.5)

    assert_equal(opciones.strings_arguments_without_option.length, 2)
    assert_equal(opciones.strings_arguments_without_option[0], "archivo0.txt")
    assert_equal(opciones.strings_arguments_without_option[1], "archivo1.txt")
  end


  def test_basico_2
    opciones = GetOptCom.new(%w{-b arg1 arg2 -e 20 --p-opcion-larga -s -a archivo0.txt archivo1.txt})
    opciones.habitual_info(USO, DESCRIPCION, COPYRIGHT, VERSION)
    TEST.each do |options_list, option_flags, argument_flags, valid_argument, default_argument, comment|
      opciones.add(options_list, option_flags, argument_flags, valid_argument, default_argument, comment)
    end
    opciones.number_of_strings_arguments_without_option(2)
    assert_nothing_raised(RuntimeError) {opciones.process!}
    assert_equal(opciones.exit?, false)

    assert_equal(opciones.exists?("-a"), true)
    assert_equal(opciones.exists?("--a-opcion-larga"), true)
    assert_equal(opciones.exists?("-b"), true)
    assert_equal(opciones.exists?("--b-opcion-larga"), true)
    assert_equal(opciones.exists?("-e"), true)
    assert_equal(opciones.exists?("--e-opcion-larga"), true)
    assert_equal(opciones.exists?("-p"), true)
    assert_equal(opciones.exists?("--p-opcion-larga"), true)
    assert_equal(opciones.exists?("-s"), true)
    assert_equal(opciones.exists?("--s-opcion-larga"), true)

    assert_nil(opciones["-a"])
    assert_nil(opciones["--a-opcion-larga"])
    assert_equal(opciones["-b"], ["arg1", "arg2"])
    assert_equal(opciones["--b-opcion-larga"], ["arg1", "arg2"])
    assert_equal(opciones["-e"], 20)
    assert_equal(opciones["--e-opcion-larga"], 20)
    assert_equal(opciones["-p"], "I")
    assert_equal(opciones["--p-opcion-larga"], "I")
    assert_equal(opciones["-s"], -1.5)
    assert_equal(opciones["--s-opcion-larga"], -1.5)
  end


  def test_opcion_inexistente
    opciones = GetOptCom.new(%w{-G 21})
    opciones.habitual_info(USO, DESCRIPCION, COPYRIGHT, VERSION)
    TEST.each do |options_list, option_flags, argument_flags, valid_argument, default_argument, comment|
      opciones.add(options_list, option_flags, argument_flags, valid_argument, default_argument, comment)
    end
    assert_raise(RuntimeError) {opciones.process!}
  end


  def test_argumentos_fuera_de_rango_1
    opciones = GetOptCom.new(%w{-e 21})
    opciones.habitual_info(USO, DESCRIPCION, COPYRIGHT, VERSION)
    TEST.each do |options_list, option_flags, argument_flags, valid_argument, default_argument, comment|
      opciones.add(options_list, option_flags, argument_flags, valid_argument, default_argument, comment)
    end
    assert_raise(RuntimeError) {opciones.process!}
  end


  def test_argumentos_fuera_de_rango_2
    opciones = GetOptCom.new(%w{-p F})
    opciones.habitual_info(USO, DESCRIPCION, COPYRIGHT, VERSION)
    TEST.each do |options_list, option_flags, argument_flags, valid_argument, default_argument, comment|
      opciones.add(options_list, option_flags, argument_flags, valid_argument, default_argument, comment)
    end
    assert_raise(RuntimeError) {opciones.process!}
  end


  def test_argumentos_sin_opciones_fuera_de_rango_1
    opciones = GetOptCom.new(%w{-p I -a archivo1.txtw})
    opciones.habitual_info(USO, DESCRIPCION, COPYRIGHT, VERSION)
    TEST.each do |options_list, option_flags, argument_flags, valid_argument, default_argument, comment|
      opciones.add(options_list, option_flags, argument_flags, valid_argument, default_argument, comment)
    end
    opciones.number_of_strings_arguments_without_option(2)
    assert_raise(RuntimeError) {opciones.process!}
  end
  

  def test_argumentos_sin_opciones_fuera_de_rango_2
    opciones = GetOptCom.new(%w{-p I -a archivo1.txt archivo2.txt archivo3.txt})
    opciones.habitual_info(USO, DESCRIPCION, COPYRIGHT, VERSION)
    TEST.each do |options_list, option_flags, argument_flags, valid_argument, default_argument, comment|
      opciones.add(options_list, option_flags, argument_flags, valid_argument, default_argument, comment)
    end
    opciones.number_of_strings_arguments_without_option(2)
    assert_raise(RuntimeError) {opciones.process!}
  end
  

  def test_defaults
    opciones = GetOptCom.new(%w{-b -e --p-opcion-larga -s -a archivo0.txt archivo1.txt})
    opciones.habitual_info(USO, DESCRIPCION, COPYRIGHT, VERSION)
    TEST.each do |options_list, option_flags, argument_flags, valid_argument, default_argument, comment|
      opciones.add(options_list, option_flags, argument_flags, valid_argument, default_argument, comment)
    end
    opciones.number_of_strings_arguments_without_option(2)
    assert_raise(RuntimeError) {opciones.process!}  # Debido a la falta de argumento en -e
    assert_equal(opciones.exit?, true)

    assert_equal(opciones.exists?("-a"), true)
    assert_equal(opciones.exists?("--a-opcion-larga"), true)
    assert_equal(opciones.exists?("-b"), true)
    assert_equal(opciones.exists?("--b-opcion-larga"), true)
    assert_equal(opciones.exists?("-e"), false)
    assert_equal(opciones.exists?("--e-opcion-larga"), false)
    assert_equal(opciones.exists?("-p"), true)
    assert_equal(opciones.exists?("--p-opcion-larga"), true)
    assert_equal(opciones.exists?("-s"), true)
    assert_equal(opciones.exists?("--s-opcion-larga"), true)

    assert_nil(opciones["-a"])
    assert_nil(opciones["--a-opcion-larga"])
    assert_equal(opciones["-b"], "B_opcional")
    assert_equal(opciones["--b-opcion-larga"], "B_opcional")
    assert_nil(opciones["-e"])
    assert_nil(opciones["--e-opcion-larga"])
    assert_equal(opciones["-p"], "I")
    assert_equal(opciones["--p-opcion-larga"], "I")
    assert_equal(opciones["-s"], -1.5)
    assert_equal(opciones["--s-opcion-larga"], -1.5)
  end


  def test_help
    opciones = GetOptCom.new(%w{--help})
    opciones.habitual_info(USO, DESCRIPCION, COPYRIGHT, VERSION)
    TEST.each do |options_list, option_flags, argument_flags, valid_argument, default_argument, comment|
      opciones.add(options_list, option_flags, argument_flags, valid_argument, default_argument, comment)
    end
    opciones.number_of_strings_arguments_without_option(2)
    assert_nothing_raised() {opciones.process!}
    assert_equal(opciones.exit?, true)

    assert_equal(opciones.exists?("-a"), false)
    assert_equal(opciones.exists?("--a-opcion-larga"), false)
    assert_equal(opciones.exists?("-b"), false)
    assert_equal(opciones.exists?("--b-opcion-larga"), false)
    assert_equal(opciones.exists?("-e"), false)
    assert_equal(opciones.exists?("--e-opcion-larga"), false)
    assert_equal(opciones.exists?("-p"), false)
    assert_equal(opciones.exists?("--p-opcion-larga"), false)
    assert_equal(opciones.exists?("-s"), false)
    assert_equal(opciones.exists?("--s-opcion-larga"), false)

    assert_nil(opciones["-a"])
    assert_nil(opciones["--a-opcion-larga"])
    assert_equal(opciones["-b"], "B_opcional")                     # Aunque la opción no existe, si existe su valor por defecto
    assert_equal(opciones["--b-opcion-larga"], "B_opcional")       # Aunque la opción no existe, si existe su valor por defecto
    assert_nil(opciones["-e"])
    assert_nil(opciones["--e-opcion-larga"])
    assert_equal(opciones["-p"], "I")                              # Aunque la opción no existe, si existe su valor por defecto
    assert_equal(opciones["--p-opcion-larga"], "I")                # Aunque la opción no existe, si existe su valor por defecto
    assert_equal(opciones["-s"], -1.5)                             # Aunque la opción no existe, si existe su valor por defecto
    assert_equal(opciones["--s-opcion-larga"], -1.5)               # Aunque la opción no existe, si existe su valor por defecto
  end
end





