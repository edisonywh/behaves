
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "behaves/version"

Gem::Specification.new do |spec|
  spec.name          = "behaves"
  spec.version       = Behaves::VERSION
  spec.authors       = ["Edison Yap"]
  spec.email         = ["edisonywh@gmail.com"]

  spec.summary       = %q{Define behaviors and contracts between your code.}
  spec.description   = %q{Adds a way to define behaviors and contracts betweet your code at compile-time instead of at run-time, so you can be sure your code adheres to a certain behavior before it hits production.}
  spec.homepage      = "https://github.com/edisonywh/behaves"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rspec_junit_formatter' # for CircleCI
end
