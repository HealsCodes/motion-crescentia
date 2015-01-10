# A module containing helper methods for installing fixture data inside the
# running application in the simulator.
module Crescentia
  # Include this in your +ApplicationDelegate+.
  module Fixtures
    # Copy a file from the Host into the simulator creating missing paths if necessary.
    # @param [Hash] file_spec A hash specifying the files location, target and
    #        target domain.
    # @option file_spec [String] :src The location on the host.
    # @option file_spec [String] :dest_path The target path inside +:dest_root+.
    # @option file_spec [Symbol] :dest_root One of the keys defined in
    #         {NSSearchPathDirectory}, if empty defaults to +:NSDocumentDirectory+.
    # @return [TrueClass] +true+, if the operation succeeded
    # @return [FalseClass] +false+, if anything went wrong
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
    # @param [Hash] file_spec A hash specifying the files location, and domain.
    # @option file_spec [String] :path The target path inside +:root+.
    # @option file_spec [Symbol] :root One of the keys defined in
    #         {NSSearchPathDirectory}, if empty defaults to +:NSDocumentDirectory+.
    def fixture_remove_file( file_spec )
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

        #puts "fixture_remove: #{file_url.absoluteString}"
        file_manager.removeItemAtURL( file_url, error: nil )
        true
      end
    end

    # Map a +Symbol+ representing a key from {NSSearchPathDirectory} to the
    # matching entry string.
    # @!visibility private
    # @param  [Symbol] root_key The requested path domain
    # @return [String] The string constant matching +root_key+
    # @return [Nil] If +root_key+ doesn't match any key in {NSSearchPathDirectory}
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

# Additional documentation for NSSearchPathDirectory
# @!parse
#   # Path domain used to determine the base directory for {fixture_install} and
#   # {fixture_remove}.
#   NSSearchPathDirectory = {
#     # Supported applications (/Applications)
#     :NSApplicationDirectory => NSApplicationDirectory,
#     # Various user-visible documentation, support, and configuration files (/Library)
#     :NSLibraryDirectory => NSLibraryDirectory,
#     # User home directories (/Users)
#     :NSUserDirectory => NSUserDirectory,
#     # Documentation
#     :NSDocumentationDirectory => NSDocumentationDirectory,
#     # Document directory
#     :NSDocumentDirectory => NSDocumentDirectory,
#     # Location of core services (System/Library/CoreServices)
#     :NSCoreServiceDirectory => NSCoreServiceDirectory,
#     # Location of user's autosaved documents (Library/Autosave Information)
#     :NSAutosavedInformationDirectory => NSAutosavedInformationDirectory,
#     # Location of user's desktop directory
#     :NSDesktopDirectory => NSDesktopDirectory,
#     # Location of discardable cache files (Library/Caches)
#     :NSCachesDirectory => NSCachesDirectory,
#     # Location of application support files (Library/Application Support)
#     :NSApplicationSupportDirectory => NSApplicationSupportDirectory,
#     # Location of the user's downloads directory
#     :NSDownloadsDirectory => NSDownloadsDirectory,
#     # Location of Input Methods (Library/Input Methods)
#     :NSInputMethodsDirectory => NSInputMethodsDirectory,
#     # Location of user's Movies directory (~/Movies)
#     :NSMoviesDirectory => NSMoviesDirectory,
#     # Location of user's Music directory (~/Music)
#     :NSMusicDirectory => NSMusicDirectory,
#     # Location of user's Pictures directory (~/Pictures)
#     :NSPicturesDirectory => NSPicturesDirectory,
#     # Location of system's PPDs directory (Library/Printers/PPDs)
#     :NSPrinterDescriptionDirectory => NSPrinterDescriptionDirectory,
#     # Location of user's Public sharing directory (~/Public)
#     :NSSharedPublicDirectory => NSSharedPublicDirectory,
#     # Location of the PreferencePanes directory for use with System Preferences (Library/PreferencePanes)
#     :NSPreferencePanesDirectory => NSPreferencePanesDirectory,
#     # For use with NSFileManager method `URLForDirectory:inDomain:approriateForURL:create:error:`
#     :NSItemReplacementDirectory => NSItemReplacementDirectory,
#     # All directories where applications can occur
#     :NSAllApplicationsDirectory => NSAllApplicationsDirectory,
#     # All directories where resources can occur
#     :NSAllLibrariesDirectory => NSAllLibrariesDirectory,
#   }
