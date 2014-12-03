# -*- encoding: utf-8 -*-
VERSION = '1.0'

Gem::Specification.new do |spec|
  spec.name          = 'motion-crescentia'
  spec.version       = '0.11.4.1'
  spec.authors       = [ 'René Köcher' ]
  spec.email         = [ 'shirk@bitspin.org' ]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = ""

  files = []
  files << 'README.md'
  files.concat(Dir.glob('lib/**/*.rb'))
  files.concat(Dir.glob('lib/**/*.a'))
  spec.files         = files
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake'
end
