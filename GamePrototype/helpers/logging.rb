require 'rubygems'
require 'modularity'
module Helpers
  module LoggingTrait
    include Modularity::AsTrait
    as_trait do |opts = {}|
      @@log = Logger.new(STDOUT)
      @@log.sev_threshold = opts[:level] || Logger::INFO

      def log; @@log; end

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
