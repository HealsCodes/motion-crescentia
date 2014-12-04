# encoding: utf-8

unless defined?(Motion::Project::Config)
  raise 'This file must be required within a RubyMotion project Rakefile.'
end

lib_directory = File.expand_path( File.join( File.dirname( __FILE__ ), '..', '..' ) )

Motion::Project::App.setup do |app|
  app.development do
    # Inject calabash-combined.a into all development builds
    app.vendor_project( File.join( lib_directory, 'vendor', 'calabash-ios-server' ), :static )
    # Inject fixture_* helpers module
    app.files << File.join( lib_directory, 'motion', 'project', 'crescentia-fixtures.rb' )
  end

  app.release do
    # Inject fixture stub-module so release builds won't fail
    app.files << File.join( lib_directory, 'motion', 'project', 'crescentia-fixtures-stub.rb' )
  end
end

namespace :crescentia do

  def setup_env_args( args )
    # Calabash >= 0.11 expects the following environment variables for the simulator:
    # DEVICE_TARGET    -> instruments -s devices
    # BUNDLE_ID        -> Motion::Project::App.config.variables['identifier']
    # APP_BUNDLE_PATH  -> path to .app

    env = {}
    env['DEVICE_TARGET'] = args[:target] || ARGV[1] || ask_target_name
    env['BUNDLE_ID'] = Motion::Project::App.config.variables['identifier']

    unless env['DEVICE_TARGET'] == 'device'
      # locate the .app bundle
      bundle_path = Dir.glob( 'build/*Simulator-*/**/*.app' ).first
      if bundle_path.nil?
        App.fail 'No Simulator build available, please run rake build:simulator first!'
      else
        env['APP_BUNDLE_PATH'] = bundle_path
      end
    end

    env
  end

  def ask_target_name
    App.info( '---', 'No target name given, please choose one:' )
    devices = `instruments -s devices`.split( /\n/ ).grep( /\[[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}\]/ )
    devices.map! { |d| d.gsub!( /\s*\[.*/, '' ) }

    devices.each_with_index do |device, index|
      App.info( "[#{index}]","- #{device}" )
    end

    while ( choice = $stdin.readline.to_i ) > devices.length
    end

    devices[choice]
  end

  desc 'Setup features directory for this project.'
  task :setup do
    App.info( 'Run', 'Creating Calabash-iOS directories..' )
    sh 'echo | calabash-ios gen >/dev/null', :verbose => false

    App.info( 'Run', 'Copying Crescentia additions..' )
    cp( File.join( lib_directory, 'motion', 'project', 'crescentia_support.rb' ),
        File.join( 'features', 'support', '03_crescentia_support.rb' ), :verbose => false )

    App.info( 'Run', 'run crescentia:run to test your setup' )
  end

  desc 'Run Calabash Cucumber tests.'
  task :run, [:target] do |t, args|

    cucumber_env  = setup_env_args( args )
    cucumber_args = ( ENV['args'] || '' ).split( /\s/ )

    App.info( 'Run', "calabash-env: #{cucumber_env}" )
    App.info( 'Run', "cucumber #{cucumber_args.to_s}" )

    exec( cucumber_env, 'cucumber', *cucumber_args )
  end

  desc 'Launch the calabash irb console'
  task :repl, [:target] do |t, args|
    console_env = setup_env_args( args )
    App.info( 'Run', "console_env: #{console_env}" )
    App.info( 'Run', "calabash-ios console" )

    exec( console_env, 'calabash-ios', 'console' )
  end
end
