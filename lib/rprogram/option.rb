module RProgram
  class Option

    # Flag of the option
    attr_reader :flag

    # Is the option in equals format
    attr_reader :equals

    # Can the option be specified multiple times
    attr_reader :multiple

    # Argument separator
    attr_reader :separator

    # Does the option contain sub-options
    attr_reader :sub_options

    #
    # Creates a new Option object with the specified _options_. If a _block_
    # is given it will be used for the custom formating of the option. If a
    # _block_ is not given, the option will use the default_format when
    # generating the arguments.
    #
    # _options_ must contain the following key:
    # <tt>:flag</tt>:: The command-line flag to use.
    #
    # _options_ may also contain the following keys:
    # <tt>:equals</tt>:: Implies the option maybe formated as
    #                    <tt>"--flag=value"</tt>. Defaults to +falue+, if
    #                    not given.
    # <tt>:multuple</tt>:: Specifies the option maybe given an Array of
    #                      values. Defaults to +false+, if not given.
    # <tt>:separator</tt>:: The separator to use for formating multiple
    #                       arguments into one +String+. Cannot be used
    #                       with <tt>:multiple</tt>.
    # <tt>:sub_options</tt>:: Specifies that the option contains
    #                         sub-options. Defaults to false, if not given.
    #
    #
    def initialize(options={},&block)
      @flag = options[:flag]

      @equals = (options[:equals] || false)
      @multiple = (options[:multiple] || false)
      @separator = if options[:separator]
                     options[:separator]
                   elsif options[:equals]
                     ' '
                   end
      @sub_options = (options[:sub_options] || false)

      @formatter = if block
        block
      else
        Proc.new do |opt,value|
          if opt.equals
            ["#{opt.flag}=#{value.first}"]
          else
            [opt.flag] + value
          end
        end
      end
    end

    #
    # Returns an +Array+ of the arguments for the option with the specified
    # _value_.
    #
    def arguments(value)
      return [@flag] if value == true
      return [] unless value

      value = value.arguments if value.respond_to?(:arguments)

      if value.kind_of?(Hash)
        value = value.map { |key,sub_value|
          if sub_value == true
            key.to_s
          elsif sub_value
            "#{key}=#{sub_value}"
          end
        }
      end

      value = [value] unless value.kind_of?(Array)
      value = value.flatten.compact

      if @multiple
        return value.inject([]) do |args,value|
          args + @formatter.call(self,[value])
        end
      else
        value = [value.join(@separator)] if @separator

        return @formatter.call(self,value)
      end
    end

  end
end
