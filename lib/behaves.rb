require 'behaves/version'
require 'set'

module Behaves
  def implements(*methods)
    @behaviors ||= Set.new(methods)
  end

  def inject_behaviours (&block)
    @injected_behaviours ||= block
  end

  def behaves_like(klass)
    at_exit { check_for_unimplemented(klass) }
    add_injected_behaviours(klass)
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

  def add_injected_behaviours(klass)
    injected_behaviours = injected_behaviours(klass)
    if injected_behaviours
      self.class_eval &injected_behaviours
    end
  end

  def injected_behaviours(klass)
    if inject_behaviours = klass.instance_variable_get("@injected_behaviours")
      inject_behaviours
    end
  end
end
