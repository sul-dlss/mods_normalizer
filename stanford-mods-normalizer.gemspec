
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stanford/mods/normalizer/version'

Gem::Specification.new do |spec|
  spec.name          = 'stanford-mods-normalizer'
  spec.version       = Stanford::Mods::Normalizer::VERSION
  spec.authors       = ['Justin Coyne']
  spec.email         = ['jcoyne@justincoyne.com']

  spec.summary       = 'Provides methods to normalize MODS XML according to the Stanford guidelines '
  spec.homepage      = 'https://github.com/sul-dlss/mods_normalizer'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '~> 1.8'
  spec.add_development_dependency 'rubocop', '~> 0.53'
  spec.add_development_dependency 'rubocop-rspec', '~> 0.18'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'equivalent-xml', '>= 0.6.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
