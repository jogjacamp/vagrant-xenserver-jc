begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant XenServer plugin must be run within Vagrant."
end


module VagrantPlugins
  module XenServer
    class Plugin < Vagrant.plugin("2")
      name "XenServer provider"
      description <<-DESC
	This plugin installs a provider that allows Vagrant to manage
	virtual machines hosted on a XenServer.
      DESC

      config('xenserver', :provider) do
        require_relative "config"
        Config
      end

      guest_capability('linux', 'configure_resolver') do
        require_relative 'cap/configure_resolver'
        Cap::ConfigureResolver
      end

      provider('xenserver', parallel: true) do
        # Setup logging and i18n
        setup_logging
        setup_i18n

        # Return the provider
        require_relative "provider"
        Provider
      end

      # This initializes the internationalization strings.
      def self.setup_i18n
        I18n.load_path << File.expand_path('locales/en.yml',
                                           XenServer.source_root)
        I18n.reload!
       end

      # This sets up our log level to be whatever VAGRANT_LOG is.
      def self.setup_logging
        require "log4r"

        level = nil
        begin
          level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil if !level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new("vagrant_xenserver")
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end

