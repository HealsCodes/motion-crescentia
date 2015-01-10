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
        env['APP_BUNDLE_PATH'] = File.join( File.absolute_path( Dir.pwd ), bundle_path )
      end
    end

    env
  end

  # Let the user choose from the available simulator targets.
  # @return [String] The selected simulator target
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

  # Lookup the UUID matching the specified device name
  def lookup_uuid( device_name )
    App.info( 'Run', "Fetching the UUID for '#{device_name}'" )
    `instruments -s devices`.split( /\n/ ).grep( /\[[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}\]/ ).each do |device|
      name, uuid = device.split( /[\[\]]/ ).map{ |n| n.strip }
      if device_name == name
        return uuid
      end
    end
    return nil
  end

  # Use +simctl+ to deploy the application on the simulator.
  # @param [String] target The device_name for the simulator target.
  # @param [String] app_bundle Path to the .app-bundle.
  # @param [String] bundle_id The bundle-id used by the application.
  # @param [Integer] clean If 1 uninstall the application first
  def push_app( target, app_bundle, bundle_id, clean=0 )
    simctl = File.join( Motion::Project::App.config.xcode_dir, 'Platforms/iPhoneSimulator.platform/Developer/usr/bin/simctl' )
    uuid = lookup_uuid( target )

    App.fail( "Unable to lookup the UUID for #{target}!" ) if uuid.nil?

    sh( "#{simctl} shutdown #{uuid} &>/dev/null || true", :verbose => false )
    sh( "#{simctl} boot     #{uuid} &>/dev/null || true", :verbose => false )

    if clean == 1
      App.info( 'Run', "Uninstalling #{bundle_id}.." )
      sh( "#{simctl} uninstall #{uuid} #{bundle_id} &>/dev/null || true", :verbose => false )
    end

    App.info( 'Run', "Installing #{bundle_id} on #{target}.." )
    sh( "#{simctl} install #{uuid} #{app_bundle}", :verbose => false )
    sh( "#{simctl} shutdown #{uuid} &>/dev/null || true", :verbose => false )
  end

  desc 'Push the app-bundle to the simulator.'
  task :push, [:target,:clean] do |t, args|
    env   = setup_env_args( args )
    clean = ( args[:clean] || ENV['clean'] || 0 ).to_i

    App.fail( ':push is only supported for simulator targets !' ) if env['DEVICE_TARGET'] == 'device'
    push_app( env['DEVICE_TARGET'], env['APP_BUNDLE_PATH'], env['BUNDLE_ID'], clean )
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

    if ENV['CUCUMBER_FORMAT']
      cucumber_args.unshift( '--format', ENV['CUCUMBER_FORMAT'] )
    end

    unless cucumber_env['DEVICE_TARGET'] == 'device'
      push_app( cucumber_env['DEVICE_TARGET'], cucumber_env['APP_BUNDLE_PATH'], cucumber_env['BUNDLE_ID'], 1 )
    end

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
