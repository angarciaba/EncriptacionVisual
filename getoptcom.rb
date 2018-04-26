#!/usr/bin/env ruby

# Archivo: getoptcom.rb
# Autor: Angel García Baños
# Email: angarcia@univalle.edu.co
# Fecha creación: 2007-10-11
# Fecha última modificación: 2007-10-16
# Versión: 0.1
# Download: http://eisc.univalle.edu.co/~angarcia/freeware
# Copyright (C) 2007-2008, Angel García Baños
# Licencia: GPL v2 (ver ???)

########################################
# Una clase para procesar las opciones y argumentos de la línea de ejecución de un programa
########################################


class GetOptCom


  OPTIONS = [PROCESS_IMMEDIATELY_AND_EXIT_OPTION = 1, OPTIONAL_OPTION = 2, REQUIRED_OPTION = 4, ARGUMENTS_WITHOUT_OPTION = 8]
  ARGUMENTS = [NO_ARGUMENT = 1, OPTIONAL_ARGUMENT = 2, REQUIRED_ARGUMENT = 4, COULD_BE_MANY_ARGUMENTS = 8]
  ARGUMENT_TYPE = [ANY_TYPE = nil, FIXNUM_TYPE = 1, FLOAT_TYPE = 2.2, STRING_TYPE = "A"]  # and Range of Numbers and Array of Strings

  HELP = "--help"
  COPYRIGHT = "--copyright"
  VERSION = "--version"
  RIGHT_MARGIN = 80


  def initialize(args=ARGV)
    @possible_options = Array.new
    @arguments = args
    @args_already_processed = false
    @must_exit = false
    @arguments_without_option = []
    @number_of_arguments_without_option = 0
    @usage = ""
  end


  def habitual_info(usage, description, copyright, version)
    @usage = usage
    add([HELP], GetOptCom::PROCESS_IMMEDIATELY_AND_EXIT_OPTION, GetOptCom::NO_ARGUMENT, GetOptCom::ANY_TYPE, nil, "Display this help and exit", description)
    add([COPYRIGHT], GetOptCom::PROCESS_IMMEDIATELY_AND_EXIT_OPTION, GetOptCom::NO_ARGUMENT, GetOptCom::ANY_TYPE, nil, "Display copyright (author, date, email and license) and exit", copyright)
    add([VERSION], GetOptCom::PROCESS_IMMEDIATELY_AND_EXIT_OPTION, GetOptCom::NO_ARGUMENT, GetOptCom::ANY_TYPE, nil, "Output version information and exit", version)
  end


  def use
    message = @usage + "\n\n"
    search(HELP) do |option_help|
      return "" if option_help.nil?
      message += justify("#{option_help.additional_information}.", 0, RIGHT_MARGIN) + "\n\nOptions: "
    end

    left_margin = 0
    @possible_options.each do |a_complete_option|
      letters_per_option = 0
      a_complete_option.options_list.each do |an_option|
        letters_per_option += an_option.length + "  ".length
      end
      if left_margin < letters_per_option then left_margin = letters_per_option end
    end
    left_margin += "  ".length

    @possible_options.each do |a_complete_option|
      line = ""
      a_complete_option.options_list.each do |an_option|
        line += an_option + "  "
      end
      line = line.ljust(left_margin)

      message += "\n\n" + line
      line = "#{a_complete_option.comment}. "
      if not a_complete_option.valid_argument.nil? then
        line += "Legal values: "
        if a_complete_option.valid_argument.class == Array or a_complete_option.valid_argument.class == Range then
          line += "#{a_complete_option.valid_argument}. "
        else
          line += "#{a_complete_option.valid_argument.class}. "
        end
      end
      if not a_complete_option.default_argument.nil? then
        line += "Default=#{a_complete_option.default_argument}. "
      end

      message = message.ljust(left_margin) + justify(line, left_margin, RIGHT_MARGIN)
    end
    message + "\n\n\n"
  end


  def add(options_list, option_flags, argument_flags, valid_argument, default_argument, comment, additional_information="")
    raise "It is illegal setting more options after invoked GetOptCom#process!" if @args_already_processed
    # Duplicated options are forbidden:
    options_list.each { |option| raise "Duplicated options are forbidden (#{option})" if _exists?(option) }

    # Options must be begin with "-" or "--". And options begining with "-" must have only one letter:
    options_list.each { |option| raise 'Options must be begin with "-" followed by only one letter; or begin with "--" followed by any sequence of alphanumerical simbols' unless option =~ /^\-(\w|\-\w[\-\w]+)$/ }

    # Default value must be inside of range:
    if not default_argument.nil?
      if valid_argument.class == Array then
        raise "Default value #{default_argument} must be inside of array #{valid_argument}" unless valid_argument.include?(default_argument)
      elsif valid_argument.class == Range then
        raise "Default value #{default_argument} must be inside of range #{valid_argument}" unless valid_argument === default_argument
      end
    end

    @possible_options << Struct.new(:options_list, :option_flags, :argument_flags, :valid_argument, :default_argument, :comment, :additional_information, :exists_option, :argument_value).new(options_list, option_flags, argument_flags, valid_argument, default_argument, comment, additional_information, false, [])
  end


  def number_of_strings_arguments_without_option(count) # count = -1 means 'any count'
    @number_of_arguments_without_option = count
  end


  def strings_arguments_without_option
    @arguments_without_option
  end


  def exit?
    process! unless @args_already_processed
    @must_exit
  end


  def process!
    @args_already_processed = true
    @arguments.collect! { |x| x.split("=") }.flatten! # Se quitan todos los símbolos "=" sustituyéndolos por espacios en blanco. Es decir, es lo mismo -t=5 que -t 5

    option_information = nil
    @arguments.each do |token|
      if token =~ /^\-/ then    # an option
        found = false
        search(token) do |a_complete_option|
          found = true
          option_information.argument_value << option_information.default_argument if not option_information.nil? and option_information.argument_value.length == 0 and not option_information.default_argument.nil?

          option_information = a_complete_option
          option_information.argument_value = []
          option_information.exists_option = true
          option_information = nil if has_bit_true(option_information.argument_flags, NO_ARGUMENT)
        end
        raise "Unknown option #{token}" unless found
      else            # an argument
        option_information = nil if up_to_date(option_information, token)
      end
    end
    up_to_date(option_information, nil)

    message = ""
    @must_exit = true if @arguments.empty?

    @possible_options.each do |a_complete_option|
      a_complete_option.argument_value << a_complete_option.default_argument if not a_complete_option.exists_option
      if a_complete_option.exists_option and has_bit_true(a_complete_option.option_flags, PROCESS_IMMEDIATELY_AND_EXIT_OPTION)
        @must_exit = true
        if a_complete_option.options_list[0] == HELP
          message = self.use
        else
          message = "#{a_complete_option.additional_information}"
        end
      end
    end  

    @possible_options.each do |a_complete_option|
      if has_bit_true(a_complete_option.option_flags, REQUIRED_OPTION) and not a_complete_option.exists_option
        @must_exit = true
        raise "Required option #{a_complete_option.options_list[0]}" if message.empty?
      end
      if has_bit_true(a_complete_option.argument_flags, REQUIRED_ARGUMENT) and a_complete_option.exists_option and a_complete_option.argument_value.empty? then
        @must_exit = true
        a_complete_option.exists_option = false
        raise "Required argument #{a_complete_option.options_list[0]}" if message.empty?
      end
    end

    raise "Wrong number of arguments without option (it is #{@arguments_without_option.length} (#{@arguments_without_option}) but it must be #{@number_of_arguments_without_option})" if @number_of_arguments_without_option > 0 and @number_of_arguments_without_option != @arguments_without_option.length and message.empty?

    message

  end


  def [] (option)
    process! unless @args_already_processed
    ret = []
    search(option) do |a_complete_option|
      ret = a_complete_option.argument_value
      if a_complete_option.valid_argument.class == Fixnum
        ret.collect! { |x| x.to_i }
      elsif a_complete_option.valid_argument.class == Float
        ret.collect! { |x| x.to_f }
      end
    end
    if ret.length == 1
      ret[0]
    elsif ret.length == 0
      nil
    else
      ret
    end
  end


  def exists? (option)
    process! unless @args_already_processed
    ret = false
    search(option) { |a_complete_option| ret = a_complete_option.exists_option }
    ret
  end


  private


  def _exists? (option)
    ret = false
    search(option) { |x| ret = true }
    ret
  end


  def search(option)
    @possible_options.each do |a_complete_option|
      a_complete_option.options_list.each do |an_option|
        if an_option == option then
          yield(a_complete_option)
        end
      end
    end
  end


  def has_bit_true(flag, bit)
    flag & bit == bit
  end


  def up_to_date(option_information, token)
    if not option_information.nil?
      case option_information.valid_argument
      when Array
        if option_information.valid_argument.include?(token)
          option_information.argument_value << token if not token.nil?
        else
          raise "Value #{token} out of array #{option_information.valid_argument} in option #{option_information.options_list[0]}"
        end
      when Range
        if option_information.valid_argument === token.to_i
          option_information.argument_value << token.to_i if not token.nil?
        else
          raise "Value #{token} out of range #{option_information.valid_argument} in option #{option_information.options_list[0]}"
        end
      else
        option_information.argument_value << token if not token.nil?
      end
        option_information.argument_value << option_information.default_argument if not option_information.nil? and option_information.argument_value.length == 0 and not option_information.default_argument.nil?
      return true if not has_bit_true(option_information.argument_flags, COULD_BE_MANY_ARGUMENTS)
    else
      @arguments_without_option << token if not token.nil?
    end
    return false
  end


  def justify(line, left_margin, right_margin)
    result = ""
    while not line.nil? and not line.empty? do
      if line.length < right_margin - left_margin then
        result += line
        line = ""
      else
        cut_point = line.rindex(/\s/, right_margin - left_margin)
        if cut_point.nil? then
          cut_point = line.index(/\s/, right_margin - left_margin)
        end
        if cut_point.nil? then
          cut_point = line.length
        end
        result += line.slice(0..cut_point)
        line = line.slice((cut_point+1)..-1)
        if not line.nil? and not line.empty?
          result += "\n"
          left_margin.times { result += " " }
        end
      end
    end
    result
  end


end


