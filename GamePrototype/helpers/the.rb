class <<Singleton
  def included_with_reset(klass)
    included_without_reset(klass)
    class <<klass
      def reset_instance
        Singleton.send :__init__, self
        self
      end
    end
  end
  alias_method :included_without_reset, :included
  alias_method :included, :included_with_reset
end
def the cl
  return cl.instance if cl.respond_to? :instance
  return cl.the if cl.respond_to? :the
end
