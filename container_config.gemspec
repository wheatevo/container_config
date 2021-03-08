# frozen_string_literal: true

require_relative "lib/container_config/version"

Gem::Specification.new do |spec|
  spec.name          = "container_config"
  spec.version       = ContainerConfig::VERSION
  spec.authors       = ["Matthew Newell"]
  spec.email         = ["matthewtnewell@gmail.com"]

  spec.summary       = "Loads container configuration values from environment variables, secrets, and credentials."
  spec.description   = "Loads container configuration values from environment variables, secrets, and credentials."
  spec.homepage      = "https://github.com/wheatevo/container_config"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/wheatevo/container_config"
  spec.metadata["changelog_uri"] = "https://github.com/wheatevo/container_config/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.7"
  spec.add_development_dependency "rubocop-rake", "~> 0.5"
  spec.add_development_dependency "rubocop-rspec", "~> 2.2"
  spec.add_development_dependency "yard", "~> 0.9"
end
