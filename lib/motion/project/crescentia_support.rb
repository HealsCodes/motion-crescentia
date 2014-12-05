# Some extra sugar for your Cucumber features
# For these to work you have to +include Crescentia::Fixtures+ in your ApplicationDelegate.

# Copy the file or directory at +local_path+ to +target_path+ inside the Simulator
# (does not work on empty directories for now).
# @param [String] local_path The path to the source file.
# @param [String] target_path The destination path on the Simulator (may contain directory parts).
# @param [Symbol] target_root The root path for the file (see #NSSearchPathDirectory).
def fixture_install( local_path, target_path, target_root )
  return false unless File.exists? local_path

  if File.directory? local_path
    Dir.glob( File.join( local_path, '**' ) ) do |entry|
      if File.file? entry
        file_target_path = entry.gsub( /^#{local_path}/, target_path )
        backdoor( 'fixture_copy_file:', { :src => entry, :dest_path => file_target_path, :dest_root => target_root } )
      end
    end
  else
    backdoor( 'fixture_copy_file:', { :src => local_path, :dest_path => target_path, :dest_root => target_root } )
  end
end

# Remove the file or directory at `path` from the Simulator.
# @param [String] path The path to the file or directory on the Simulator.
# @param [Symbol] root The root path for the file (see #NSSearchPathDirectory).
def fixture_remove( path, root )
  backdoor( 'fixture_remove_file:', { :path => path, :root => root } )
end
