require 'behaves/version'
require 'set'

module Behaves
  def implements(*methods, **opts)
    @_public_behaviors  ||= Set.new
    @_private_behaviors ||= Set.new

    if opts[:private] == true
      @_private_behaviors += Set.new(methods)
    else
      @_public_behaviors  += Set.new(methods)
    end
  end

  def inject_behaviors (&block)
    @inject_behaviors ||= block
  end

  def behaves_like(klass)
    add_injected_behaviors(klass)
    at_exit {
      check_for_unimplemented(klass, :public)
      check_for_unimplemented(klass, :private)
    }
  end

  private

  def check_for_unimplemented(klass, type = :public)
    required = defined_behaviors(klass, type)

    unimplemented = required - implemented(type)

    return if unimplemented.empty?

    raise NotImplementedError, "Expected `#{self}` to behave like `#{klass}`, but #{type} methods `#{unimplemented.to_a.join(', ')}` are not implemented."
  end

  def implemented(type)
    lookups = {
      public:           :instance_methods,
      private:  :private_instance_methods,
    }

    method_lookup_sym = lookups.fetch(type) do
      raise ArgumentError.new <<~ERR

        Invalid `type`: #{type}
        Valid `type`s include: #{types.keys.map{|sym| "`#{sym.inspect}`"}.join(', ')}
      ERR
    end

    methods = self.send(method_lookup_sym, false)

    Set.new(methods)
  end

  def defined_behaviors(klass, type)
    if behaviors = klass.instance_variable_get(:"@_#{type}_behaviors")
      behaviors
    else
      raise NotImplementedError, "Expected `#{klass}` to define behaviors, but none found."
    end
  end

  def add_injected_behaviors(klass)
    injected_behaviors = klass.instance_variable_get("@inject_behaviors")
    if injected_behaviors
      self.class_eval &injected_behaviors
    end
  end
end
