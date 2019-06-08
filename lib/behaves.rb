require 'behaves/version'
require 'set'

module Behaves
  def implements(*methods)
    @behaviors ||= Set.new(methods)
  end

  def behaves_like(klass)
    at_exit do
      required = defined_behaviors(klass)

      implemented = Set.new(self.instance_methods - Object.instance_methods)

      unimplemented = required - implemented

      exit if unimplemented.empty?

      raise NotImplementedError, "Expected `#{self}` to behave like `#{klass}`, but `#{unimplemented.to_a.join(', ')}` are not implemented."
    end
  end

  private

  def defined_behaviors(klass)
    if behaviors = klass.instance_variable_get("@behaviors")
      behaviors
    else
      raise NotImplementedError, "Expected `#{klass}` to define behaviors, but none found."
    end
  end
end
