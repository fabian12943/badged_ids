require_relative "lib/badged_ids/version"

Gem::Specification.new do |spec|
  spec.name = "badged_ids"
  spec.version = BadgedIds::VERSION
  spec.authors = [ "Fabian Schwarz" ]
  spec.email = [ "fabian12943@gmail.com" ]
  spec.homepage = "https://github.com/fabian12943/badged_ids"
  spec.summary = "Badged-IDs generates and persists unguessable IDs with friendly prefixes for your models"
  spec.description = "Badged-IDs generates and persists unguessable IDs with friendly prefixes for your models"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fabian12943/badged_ids"
  spec.metadata["changelog_uri"] = "https://github.com/fabian12943/badged_ids/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 2.7.0"

  spec.add_dependency "rails", ">= 6.0.0"
end
