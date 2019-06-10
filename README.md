![CircleCI Badge](https://img.shields.io/circleci/build/github/edisonywh/behaves.svg)
![RubyGems Badge](https://img.shields.io/gem/v/behaves.svg)
![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/edisonywh/behaves.svg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'behaves'
```


# Behaves

Behaves is a gem that helps you maintain contracts between different classes. This is especially useful for dealing for adapter patterns by making sure that all of your adapters define the required behaviors.

For example, you can specify that class `Dog` and class `Cat` should both behave the same as `Animal`, or that your `ApiClientMock` should behave the same as the original `ApiClient` (more explanation below)

The idea for `Behaves` stemmed from my research into [adapter pattern in Ruby](https://www.sitepoint.com/using-and-testing-the-adapter-design-pattern/) and José Valim's article on [Mocks and explicit contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/).

I found that the current idiom to achieve `behaviors` in Ruby is through `Inheritence`, and then subsequently defining a "required" (I put quotation marks around it, because it's not exactly `required` until you run it) method, which does nothing except raising a `NotImplementedError`. While I don't necessarily think it's *bad*, I do think that there could be an alternative that's **more explicit**, **less boilerplate**, **cleaner ancestors hierachy**, thus the birth of `Behaves`.

## Cons of inheritance

Let's dive into the cons of implementing behaviors through `Inheritance`

First, I think this is a very opaque implementation - at a quick glance, there's no real way to know if there are any behaviors required. The only way to be sure is to dive into the parent class and look for any methods that does nothing but raises a `NotImplementedError`. This gets cascadingly worse if you have multiple hierachy of inheritance.

Secondly, with inheritance, the behavioral contract is dependent upon the method lookup chain - this poses a few issues:

1) `Unused code` - You now have a stub method on your parent class that does nothing but raise an error, and it won't be used any longer after it's your behaviors are adhered to.

2) `Fragile implementation` - You are reliant on the ancestor chain not being intercepted. For example, if someone else on your team defines a method that has the same name as your behavior, but sits higher up the chain (through `prepending` for example), your stub method is now useless and won't ever catch if a behavior is not implemented.

3) `Runtime errors` - There are possibility for runtime errors. If a child did not adhere to the required behaviors, your code won't actually know that until it tries to call the method on child class. Error on production? Not good.

## How does `Behaves` solve this problem?

Behaves aim to solve this problem by being **explicit** and **upfront**:

- A very clear `behaves_like Animal` that indicates that this class has a certain behaviors to adhere to, as implemented by `Animal`.

- Guarantee to catch implementation deviation regardless of the ancestor chains.

- With the way Behaves is written, your code will fail to even load if you don't adhere to the behaviors upfront - **no more runtime errors in production**.

- No need to define a stub method that does nothing - behaviors checking are done through symbols, as defined in `implements` by the behaviorial class.

See below for more examples about how `Behaves` work.

## Usage

Let's take a look how to define behaviors using `Inheritance`.

```ruby
# Inheritance Behaviors
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

  def eat
    "chomp"
  end
end
```

You have now defined `Animal#speak` and `Animal#eat` which are not useful at all, along with all the issues I pointed out earlier.

Now let's take a look at how `Behaves` work.

```ruby
class Animal
  extend Behaves

  implements :speak, :eat
end

class Dog
  extend Behaves

  behaves_like Animal

  def speak
    "woof"
  end

  def eat
    "chomp"
  end
end
```

With `Behaves`, it is immediately obvious that Dog should behave like a certain class -> `Animal`, and you do not have to implement stub methods on `Animal`.

## Thoughts

Referring to the article by José Valim, I really liked the idea of being able to use Mock as a noun. However, while the idea sounds good, you've now introduced a new problem in your codebase -- your Mock and your original Object might deviate from their implementation later on. Not a good design if it breaks. Elixir has `@behaviors` & `@callback` built in to keep them in sync. `Behaves` is inspired by that.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/edisonywh/behaves. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Behaves project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/behaves/blob/master/CODE_OF_CONDUCT.md).
