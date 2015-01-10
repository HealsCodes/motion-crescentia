# Some extra sugar for your Specifications
# For these to work you have to +include Crescentia::Fixtures+ in your ApplicationDelegate.

# Get the an absolute path to the applications source directory outside the simulator.
# This value is determined at compile time and stored in the +SPEC_HOST_PATH+ inside the
# applications Info.plist.
def fixture_host_path( *args )
  base_path = NSBundle.mainBundle.objectForInfoDictionaryKey( 'SPEC_HOST_PATH' )
  unless base_path.nil?
    File.absolute_path( File.join( base_path, *args ) )
  end
end

# Copy the file or directory at +local_path+ to +target_path+ inside the Simulator
# (does not work on empty directories for now).
# @param [String] local_path The path to the source file.
# @param [String] target_path The destination path on the Simulator (may contain directory parts).
# @param [Symbol] target_root The root path for the file (see #NSSearchPathDirectory).
def fixture_install( local_path, target_path, target_root )
  return false unless File.exists? local_path

  app = UIApplication.sharedApplication
  unless app.delegate.respond_to? 'fixture_copy_file:'
    raise 'Your ApplicationDelegate needs to include Crescentia::Fixtures for this to work!'
  end

  if File.directory? local_path
    Dir.glob( File.join( local_path, '**', '*' ) ) do |entry|
      if File.file? entry
        file_target_path = entry.gsub( /^#{local_path}/, target_path )
        app.delegate.fixture_copy_file( { :src => entry, :dest_path => file_target_path, :dest_root => target_root } )
      end
    end
  else
    app.delegate.fixture_copy_file( { :src => local_path, :dest_path => target_path, :dest_root => target_root } )
  end
end

# Remove the file or directory at `path` from the Simulator.
# @param [String] path The path to the file or directory on the Simulator.
# @param [Symbol] root The root path for the file (see #NSSearchPathDirectory).
def fixture_remove( path, root )
  app = UIApplication.sharedApplication
  unless app.delegate.respond_to? 'fixture_copy_file:'
    raise 'Your ApplicationDelegate needs to include Crescentia::Fixtures for this to work!'
  end

  app.delegate.fixture_remove_file( { :path => path, :root => root } )
end
