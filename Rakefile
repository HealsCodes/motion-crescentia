# -*- coding: utf-8 -*-

require 'bundler'
require 'rake/clean'

Bundler::GemHelper::install_tasks

VENDOR_LIBS = [
    'lib/vendor/calabash-ios-server/calabash-combined.a'
]

CLEAN << VENDOR_LIBS
task :build => VENDOR_LIBS

file 'lib/vendor/calabash-ios-server/calabash-combined.a' do |t|
  puts 'Building calabash-ios-server libraries..'

  Dir.chdir( File.dirname( File.absolute_path( __FILE__ ) ) ) do
    unless File.exists? './vendor/calabash-ios-server/Makefile'
      sh 'git submodule init'
      sh 'git submodule update'
    end

    Dir.chdir( './vendor/calabash-ios-server' ) do
      unless File.exists? './calabash-js/README'
        sh 'git submodule init'
        sh 'git submodule update'
      end

      sh 'make clean >/dev/null', :verbose => false
      sh 'make framework >/dev/null', :verbose => false
    end

    cp './vendor/calabash-ios-server/build/Debug-combined/calabash-combined.a', t.name
  end
end
