# frozen_string_literal: true

require_relative 'lib/space_stone/pdf_splitter/version'

Gem::Specification.new do |spec|
  spec.name = 'space_stone-pdf_splitter'
  spec.version = SpaceStone::PdfSplitter::VERSION
  spec.authors = ['Jeremy Friesen']
  spec.email = ['jeremy.n.friesen@gmail.com']

  spec.summary = 'A plugin for SpaceStone to handle splitting of PDFs.'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/scientist-softserv/space_stone-pdf_splitter'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency 'mini_magick'
  spec.add_dependency 'activesupport', ">= 5"
  spec.add_development_dependency 'bixby'
  spec.add_development_dependency 'rspec'
end
