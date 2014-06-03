require 'rubygems'
require 'modularity'


module Helpers
  module DoesLogging
    include Modularity::AsTrait
    as_trait do |opts = {}|
      define_method('log_options') do
        opts
      end
      def log
        if not @log
          @log = Logger.new(STDOUT)
          @log.sev_threshold = log_options[:level] || Logger::INFO
        end
        @log
      end

      def log_name
        "#{self.class.to_s}(#{self.__id__})"
      end

      %w[debug info warn error fatal].each do |lvl|
        define_method("log_#{lvl}") do |&blk|
          log.send lvl.to_sym, log_name, &blk
        end
      end
    end
  end
end
