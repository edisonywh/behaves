require "behaves/version"

module Behaves
  def implements(*methods)
    @behaviors ||= Set.new(methods)
  end

  def behaves_like(klass)
    at_exit do
      required = klass.instance_variable_get("@behaviors")

      implemented = Set.new(self.instance_methods - Object.instance_methods)

      unimplemented = required - implemented

      exit if unimplemented.empty?

      raise NotImplementedError, "Expected `#{self}` to behave like `#{klass}`, but `#{unimplemented.to_a.join(', ')}` are not implemented."
    end
  end
end
