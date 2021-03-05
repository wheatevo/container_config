# frozen_string_literal: true

require_relative "lib/container_config_loader/version"

Gem::Specification.new do |spec|
  spec.name          = "container_config_loader"
  spec.version       = ContainerConfigLoader::VERSION
  spec.authors       = ["Matthew Newell"]
  spec.email         = ["matthewtnewell@gmail.com"]

  spec.summary       = "Loads values from environment variables, secrets, and application credentials."
  spec.description   = "Loads values from environment variables, secrets, and application credentials."
  spec.homepage      = "https://github.com/wheatevo/container_config_loader"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/wheatevo/container_config_loader"
  spec.metadata["changelog_uri"] = "https://github.com/wheatevo/container_config_loader/blob/master/CHANGELOG.md"

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
end
