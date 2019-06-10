require 'behaves/version'
require 'set'

module Behaves
  def implements(*methods)
    @behaviors ||= Set.new(methods)
  end

  def behaves_like(klass)
    if block_given?
      yield

      detect_unimplemented_methods(klass) { return }
    end

    at_exit do
      detect_unimplemented_methods(klass) { exit }
    end
  end

  private

  def detect_unimplemented_methods(klass, &on_success)
    required = defined_behaviors(klass)

    implemented = Set.new(self.instance_methods - Object.instance_methods)

    unimplemented = required - implemented

    on_success.call if unimplemented.empty?

    raise NotImplementedError, "Expected `#{self}` to behave like `#{klass}`, but `#{unimplemented.to_a.join(', ')}` are not implemented."
  end

  def defined_behaviors(klass)
    if behaviors = klass.instance_variable_get("@behaviors")
      behaviors
    else
      raise NotImplementedError, "Expected `#{klass}` to define behaviors, but none found."
    end
  end
end
