![CircleCI Badge](https://img.shields.io/circleci/build/github/edisonywh/behaves.svg)
![RubyGems Badge](https://img.shields.io/gem/v/behaves.svg)
![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/edisonywh/behaves.svg)

# Behaves

Behaves is a gem that helps you define behaviors between classes. **Say goodbye to runtime error when defining behaviors.**

Behaves is especially useful for dealing with adapter patterns by making sure that all of your adapters define the required behaviors. See [usage below](https://github.com/edisonywh/behaves#usage) for more examples.

*Detailed explanations in the sections below.*

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'behaves'
```

## Usage

This is how you define behaviors with `behaves`.

First, define required methods on the `Behavior Object` with the `implements` method, which take a list of methods.
```ruby
class Animal
  extend Behaves

  implements :speak, :eat
end
```

Then, you can turn any object (the `Behaving Object`) to behave like the `Behavior Object` by using the `behaves_like` method, which takes a `Behavior Object`.
```ruby
class Dog
  extend Behaves

  behaves_like Animal
end
```

Voilà, that's all it takes to define behaviors! Now if `Dog` does not implement `speak` and `eat`, your code will then throw error **on file load**, instead of **at runtime**.

```diff
- NotImplementedError: Expected `Dog` to behave like `Animal`, but `speak, eat` are not implemented.
```

This is in stark contrast to defining behaviors with inheritance. Let's take a look.

### Inheritance-based behaviors

```ruby
# Inheritance - potential runtime error.
class Animal
  def speak
    raise NotImplementedError, "Animals need to be able to speak!"
  end

  def eat
    raise NotImplementedError, "Animals need to be able to eat!"
  end
end

class Dog < Animal
  def speak
    "woof"
  end
end
```

1) It is unclear that `Dog` has a certain set of behaviors to adhere to.

2) Notice how `Dog` does not implement `#eat`? Inheritance-based behaviors have no guarantee that `Dog` adheres to a certain set of behaviors, which means you can run into runtime errors like this.

```ruby
corgi = Dog.new
corgi.eat
# => NotImplementedError, "Animals need to be able to eat!"
```

3) Another problem is you have now defined `Animal#speak` and `Animal#eat`, two stub methods of which they do nothing but raise an undesirable `NotImplementedError`.

The power of `Behaves` does not stop here either.

## Features

### Multi-behaviors

`Behaves` allow you to define multiple behavior for a single behaving object. **This is not possible with inheritance**.

```ruby
class Predator
  extend Behaves

  implements :hunt
end

class Prey
  extend Behaves

  implements :run, :hide
end

class Shark
  extend Behaves

  # Shark is both a `Predator` and a `Prey`
  behaves_like Predator
  behaves_like Prey
end
```

### Inject Behaviors

When someone decides to use `behaves` to define behaviors, they in turn lose the ability to utilize some other aspect of inheritance, one of it being inheriting methods.

So, `Behaves` now ship with a feature called `inject_behaviors` for that need!

```ruby
class Dad
  extend Behaves

  implements :speak, :eat

  inject_behaviors do
    def traits; "Dad's traits!"; end
  end
end

class Child
  extend Behaves

  behaves_like Dad

  def speak; "BABA"; end
  def eat; "NOM NOM"; end
end

# Child.new.traits #=> "Dad's traits!"
```

This extends to more than just method implementation too, you can do anything you want! That's because the code inside `inject_behaviors` run in the context of the `Behaving Object`, also `self` inside `injected_behaviors` refers to the `Behaving Object`.

*Do note that if you use this extensively, you might be better off using inheritance, since this will create more `Method` objects than inheritance.*

### Private Behaviors

Private behaviors can be defined like so:

```ruby
class Interface
  extend Behaves

  implements :foo
  implements :bar, private: true
end

class Implementor
  extend Behaves

  behaves_like Interface

  def foo
    123
  end

  private

  def bar
    456
  end
end
```

## Tips
If you do not want to type `extend Behaves` every time, you can monkey patch `Behaves` onto `Object` class, like so:

> Object.send(:extend, Behaves)

## Thoughts

The idea for `Behaves` stemmed from my research into [adapter pattern in Ruby](https://www.sitepoint.com/using-and-testing-the-adapter-design-pattern/) and José Valim's article on [Mocks and explicit contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/).

I found that the current idiom to achieve `behaviors` in Ruby is through inheritence, and then subsequently defining 'required' methods, which does nothing except raising a `NotImplementedError`. This approach is fragile, as it **does not guarantee behaviors**, runs the **risk of runtime errors**, and has an **opaque implementation**.

Thus with this comes the birth of `Behaves`.

Also referring to the article by José Valim, I really liked the idea of being able to use Mock as a noun. However, while the idea sounds good, you've now introduced a new problem in your codebase -- your Mock and your original Object might deviate from their implementation later on. Not a good design if it breaks. Elixir has `@behaviors` & `@callback` built in to keep them in sync. `Behaves` is inspired by that.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/edisonywh/behaves. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
