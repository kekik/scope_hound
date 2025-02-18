# frozen_string_literal: true

require_relative "lib/scope_hound/version"

Gem::Specification.new do |spec|
  spec.name = "scope_hound"
  spec.version = ScopeHound::VERSION
  spec.authors = ["Cem Baykam"]
  spec.email = ["cem@kekik.com.tr"]

  spec.summary = "A Ruby gem providing MVC concerns for powerful, customizable data filtering."
  spec.description = <<-DESC
  Scope Hound is a gem enhancing the filtering process
  in Ruby on Rails apps. It introduces a filter proxy system, enabling
  intuitive filtering at the controller level based on input parameters.
  An efficient and secure solution for improved data handling in your
  Rails application.
  DESC
  spec.homepage = "https://github.com/kekik/scope_hound"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kekik/scope_hound"
  spec.metadata["changelog_uri"] = "https://github.com/kekik/scope_hound/blob/master/CHANGELOG.md"
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7"
  spec.add_development_dependency 'rspec-rails'
end
