require 'behaves/version'
require 'set'

module Behaves
  def implements(*methods)
    @behaviors ||= Set.new(methods)
  end

  def inject_behaviors (&block)
    @inject_behaviors ||= block
  end

  def behaves_like(klass)
    add_injected_behaviors(klass)
    at_exit { check_for_unimplemented(klass) }
  end

  private

  def check_for_unimplemented(klass)
    required = defined_behaviors(klass)

    implemented = Set.new(self.instance_methods - Object.instance_methods)

    unimplemented = required - implemented

    return if unimplemented.empty?

    raise NotImplementedError, "Expected `#{self}` to behave like `#{klass}`, but `#{unimplemented.to_a.join(', ')}` are not implemented."
  end

  def defined_behaviors(klass)
    if behaviors = klass.instance_variable_get("@behaviors")
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

  def injected_behaviors(klass)
    if injected_behaviors = klass.instance_variable_get("@inject_behaviors")
      injected_behaviors
    end
  end
end
