require 'behaves/version'
require 'set'

module Behaves
  def implements(*methods, **opts)
    @_Behaves_public_behaviors  ||= Set.new
    @_Behaves_private_behaviors ||= Set.new

    if opts[:private] == true
      @_Behaves_private_behaviors += Set.new(methods)
    else
      @_Behaves_public_behaviors  += Set.new(methods)
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
    implemented = Set.new(
      case type
      when :public  then         instance_methods(false)
      when :private then private_instance_methods(false)
      else
        raise ArgumentError.new("Invalid `type`: #{type}")
      end
    )
  end

  def defined_behaviors(klass, type)
    if behaviors = klass.instance_variable_get(:"@_Behaves_#{type}_behaviors")
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
