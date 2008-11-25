require 'logger'

module RuGUI
  #
  # A simple log support for registering problems, infos and debugs.
  #
  module LogSupport
    #
    # Allows initialize the log support, setting up the class name that invokes the logger,
    # output, level and the format of the message.
    #
    def initialize_logger(classname = nil, output = RuGUI.configuration.logger[:output], level = RuGUI.configuration.logger[:level], format = RuGUI.configuration.logger[:format])
      @logger = setup_logger(classname, output, level, format)
    end

    #
    # Invokes the log support object
    #
    def logger
      @logger || setup_logger
    end
    
    protected
      #
      # Setup a new log support object. If a problem occurs a logger is setted up
      # to warn level.
      #
      def setup_logger(classname = nil, output = nil, level = nil, format = nil)
        begin
          logr = Logger.new(defined_output(output))
          logr.formatter = RuGUI::LogSupport::Formatter.new(defined_classname(classname))
          logr.level = defined_level(level)
        rescue StandardError => e
          logr = Logger.new(OUTPUTS[:stderr])
          logr.level = LEVELS[:warn]
          logr.datetime_format = defined_format(format)
          logr.warn "Log support problems: The log level has been raised to WARN and the output directed to STDERR until the problem is fixed."
          logr.error "#{e} #{e.backtrace.join("\n")}"
        end
        logr
      end

      #
      # Defines a output based on params informed by user, params setted up in
      # the configuration file, or default values.
      #
      def defined_output(output)
        unless output
          output = DEFAULT_OUTPUT
        else
          output = output.is_a?(String) ? File.join(RuGUI.root, 'log', output) : OUTPUTS[output]
        end
        output
      end

      #
      # Defines a level based on params informed by user, params setted up in
      # the configuration file, or default values.
      #
      def defined_level(level)
        unless level
          level = DEFAULT_LEVEL
        else
          level = LEVELS[level]
        end
        level
      end

      #
      # Defines a format based on params informed by user, params setted up in
      # the configuration file, or default values.
      #
      def defined_format(format)
        format = DEFAULT_FORMAT unless format
        format
      end

      def defined_classname(classname)
        classname || self.class.name
      end

    private
      #
      # Default values to levels
      #
      LEVELS = {
        :debug => Logger::DEBUG,
        :info => Logger::INFO,
        :warn => Logger::WARN,
        :error => Logger::ERROR,
        :fatal => Logger::FATAL
      }

      #
      # Default values to outputs
      #
      OUTPUTS = {
        :stdout => STDOUT,
        :stderr => STDERR,
        :file => ''
      }

      #
      # Default values to the log support object - aka logger
      #
      DEFAULT_OUTPUT = OUTPUTS[:stdout]
      DEFAULT_LEVEL = LEVELS[:debug]
      DEFAULT_FORMAT = "%Y-%m-%d %H:%M:%S"
      
      class Formatter
        def initialize(classname = nil)
          @classname = classname
        end

        def call(severity, timestamp, progname, msg)
          timestamp = timestamp.strftime(RuGUI.configuration.logger[:format] || "%Y-%m-%d %H:%M:%S")
          "#{timestamp} (#{severity}) (#{@classname}) #{msg}\n"
        end
      end
  end
end