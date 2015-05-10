# -*- encoding: utf-8 -*-
VERSION = '1.0'

Gem::Specification.new do |spec|
  spec.name          = 'motion-crescentia'
  spec.version       = '0.12.0.1'
  spec.authors       = [ 'René Köcher' ]
  spec.email         = [ 'shirk@bitspin.org' ]
  spec.description   = %q{RubyMotion wrapper for the Calabash BDD framework}
  spec.summary       = %q{motion-crescentia is an unofficial wrapper around calabash-ios and calabash-cucumber.
                          It is designed to work with calabash-ios >= 0.11.4 and requires XCode 6.1 or better.}
  spec.homepage      = 'https://github.com/Shirk/motion-crescentia'
  spec.license       = 'MIT'

  files = []
  files << 'README.md'
  files.concat(Dir.glob('lib/**/*.rb'))
  files.concat(Dir.glob('lib/**/*.a'))

  spec.files         = files
  spec.require_paths = ['lib']

  spec.add_dependency( 'calabash-cucumber', '0.14.1' )
  spec.add_development_dependency 'rake'
end
