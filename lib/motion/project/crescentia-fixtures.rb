
module Crescentia
  # A module containing helper methods for installing fixture data inside the running application in the simulator.
  module Fixtures
    # Copy a file from the Host into the simulator creating missing paths if necessary.
    # @param file_spec [{ :src, :dest_path, :dest_root }] A hash specifying the files location, target and target domain.
    #   `:src` - the location on the host;
    #   `:dest_path` - the target path inside `:dest_root`
    #   `:dest_root` - one of the keys defined in {NSSearchPathDirectory}, if empty defaults to :NSDocumentDirectory
    def fixture_copy_file( file_spec )
      file_manager = NSFileManager.defaultManager

      if file_spec.has_key? :src
        host_path = file_spec[:src]
        file_path = file_spec[:dest_path].split( '/' ).last
        file_root = file_spec[:dest_root] || :NSDocumentDirectory

        base_url = file_manager.URLForDirectory( _fixture_resolve_root( file_root ),
                                                 inDomain: NSUserDomainMask, appropriateForURL: nil,
                                                 create: true, error: nil )

        if file_spec[:dest_path].include? '/'
          base_path = file_spec[:dest_path].gsub( /(.*)\/.*$/, '\1' )
          base_url = base_url.URLByAppendingPathComponent( base_path )
          file_manager.createDirectoryAtURL( base_url, withIntermediateDirectories: true, attributes: nil, error: nil)
        end

        host_url = NSURL.fileURLWithPath( host_path )
        file_url = base_url.URLByAppendingPathComponent( file_path, isDirectory: false )

        file_manager.copyItemAtURL( host_url, toURL: file_url, error: nil )
        true
      end
    end

    # Remove a file or directory from the simulator.
    # @param file_spec [{ :path, :root }] A hash specifying the files location, and domain.
    #   `:path` - the target path inside `:root`
    #   `:root` - one of the keys defined in {NSSearchPathDirectory}, if empty defaults to :NSDocumentDirectory
    def fixture_remove_file( file_spec )
      NSLog 'Entry'
      file_manager = NSFileManager.defaultManager

      if file_spec.has_key? :path
        file_path = file_spec[:path].split( '/' ).last
        file_root = file_spec[:root] || :NSDocumentDirectory

        base_url = file_manager.URLForDirectory( _fixture_resolve_root( file_root ),
                                                 inDomain: NSUserDomainMask, appropriateForURL: nil,
                                                 create: false, error: nil )

        if file_spec[:path].include? '/'
          base_path = file_spec[:path].gsub( /(.*)\/.*$/, '\1' )
          base_url = base_url.URLByAppendingPathComponent( base_path )
        end

        file_url = base_url.URLByAppendingPathComponent( file_path, isDirectory: false )

        puts "fixture_remove: #{file_url.absoluteString}"
        file_manager.removeItemAtURL( file_url, error: nil )
        true
      end
    end

    # Map a {Symbol} representing a NSSearchPathDirectory entry to the matching entry string
    # @private
    # @return [String] The string constant matching `root_key`
    # @return [Nil] If `root_key`doesn't match any key in {NSSearchPathDirectory}
    def _fixture_resolve_root( root_key )
      {
          :NSApplicationDirectory => NSApplicationDirectory,
          :NSDemoApplicationDirectory => NSDemoApplicationDirectory,
          :NSDeveloperApplicationDirectory => NSDeveloperApplicationDirectory,
          :NSAdminApplicationDirectory => NSAdminApplicationDirectory,
          :NSLibraryDirectory => NSLibraryDirectory,
          :NSDeveloperDirectory => NSDeveloperDirectory,
          :NSUserDirectory => NSUserDirectory,
          :NSDocumentationDirectory => NSDocumentationDirectory,
          :NSDocumentDirectory => NSDocumentDirectory,
          :NSCoreServiceDirectory => NSCoreServiceDirectory,
          :NSAutosavedInformationDirectory => NSAutosavedInformationDirectory,
          :NSDesktopDirectory => NSDesktopDirectory,
          :NSCachesDirectory => NSCachesDirectory,
          :NSApplicationSupportDirectory => NSApplicationSupportDirectory,
          :NSDownloadsDirectory => NSDownloadsDirectory,
          :NSInputMethodsDirectory => NSInputMethodsDirectory,
          :NSMoviesDirectory => NSMoviesDirectory,
          :NSMusicDirectory => NSMusicDirectory,
          :NSPicturesDirectory => NSPicturesDirectory,
          :NSPrinterDescriptionDirectory => NSPrinterDescriptionDirectory,
          :NSSharedPublicDirectory => NSSharedPublicDirectory,
          :NSPreferencePanesDirectory => NSPreferencePanesDirectory,
          :NSItemReplacementDirectory => NSItemReplacementDirectory,
          :NSAllApplicationsDirectory => NSAllApplicationsDirectory,
          :NSAllLibrariesDirectory => NSAllLibrariesDirectory,
      }[root_key.to_sym] || NSDocumentDirectory
    end
  end
end
