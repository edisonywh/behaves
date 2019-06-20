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

  def check_for_unimplemented(klass, scope)
    required = defined_behaviors(klass, scope)

    unimplemented = required - implemented(scope)

    return if unimplemented.empty?


    # basic "unimplemented method" error message

    err = <<~ERR
      \n\n  Expected `#{self}` to behave like `#{klass}`, but the following #{scope} methods are unimplemented:\n
      #{unimplemented.to_a.map{|method| "    * `#{method}`"}.join("\n")}\n
    ERR


    # add "wrong scope" message

    other_scopes            = (scope == :public) ? [:private] : [:public]
    methods_in_other_scopes = Set.new( other_scopes.map{|s| implemented(s)}.map(&:to_a).flatten.compact )
    methods_in_wrong_scope  = unimplemented && methods_in_other_scopes

    if !methods_in_wrong_scope.empty?
      err += <<~ERR
        \n  The following methods appear to be defined, but in the wrong scope:\n
        #{methods_in_wrong_scope.to_a.map{|method| "    * `#{method}`"}.join("\n")}\n\n
      ERR
    end


    raise NotImplementedError, err
  end

  def implemented(scope)
    lookups = {
      public:           :instance_methods,
      private:  :private_instance_methods,
    }

    method_lookup_sym = lookups.fetch(scope) do
      raise ArgumentError.new <<~ERR

        Invalid `scope`: #{scope}
        Valid `scope`s include: #{lookups.keys.map{|sym| "`#{sym.inspect}`"}.join(', ')}
      ERR
    end

    methods = self.send(method_lookup_sym, false)

    Set.new(methods)
  end

  def defined_behaviors(klass, scope)
    if behaviors = klass.instance_variable_get(:"@_#{scope}_behaviors")
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
