# frozen_string_literal: true

require_relative "lib/takuya/lvm_snapshot/version"
require_relative "lib/takuya/lvm_snapshot"

Gem::Specification.new do |spec|
  spec.name          = "takuya-lvm-snapshot"
  spec.version       = Takuya::LvmSnapShot::VERSION
  spec.authors       = ["takuya"]
  spec.email         = ["55338+takuya@users.noreply.github.com"]

  spec.summary       = "wrapper of lvm snapshot for list / create / remove "
  spec.description   = "This package make use of shell command lvcreate / lvremove and mount. Taking file from lvm snapshot."
  spec.homepage      = "https://github.com/takuya/ruby-lvm-snapshot-wrapper/"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/takuya/ruby-lvm-snapshot-wrapper"
  spec.metadata["changelog_uri"] = "https://github.com/takuya/ruby-lvm-snapshot-wrapper/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
