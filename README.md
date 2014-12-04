# motion-crescentia



An easy way to integrate Calabash iOS into RubyMotion projects.
It was conceived as an alternative to `motion-calabash` since I felt the need for a more recent version of calabash-ios and also since the gem on GitHub didn't receive a lot of love lately.

In addition to providing an alternative wrapper crescentia also adds some new features like easy support for the installation and removal of fixture data inside the running simulator.

For more information about Calabash see: http://calaba.sh
For more information about the official motion-calabsh see: [https://github.com/calabash/motion-calabash

## Requirements

* RubyMotion 1.0 or newer (see http://www.rubymotion.com)
* XCode 6.1 or newer (available from the Mac AppStore)

## Installation

Add this line to your application's Gemfile:

    gem 'motion-crescentia'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motion-crescentia

## Usage

### rake tasks

After following the installation steps there will be three new rake tasks available:

#### crescentia:setup

This will create the initial cucumber `features` directory and populate it with the files required by calabash as well as the fixture additions provided by crescentia.

#### crescentia:run\[:target\]

Execute cucumber to run the acceptance tests defined in your `features` directory.
This task expects a target on which the tests should be run (either as rake argument or as the first parameter).

Possible values include any target supported by the iPhoneSimulator or `device` to execute on a connected iOS device.
For a list of available simulator targets run:

    $ instruments -s devices

If no target is specified a list of possible targets will be provided to choose from.

**NOTE:** Any additional arguments for `cucumber` can be passed by setting the `args` environment variable.

#### crescentia:repl\[:target\]

Start the interactive calabash irb console.
This task too requires a target specification, see *crescentia:run* for details on that.

### providing fixture data

To easily add and remove fixture data in your acceptance tests crescentia provides two functions which can be called from cucumber steps:

    # Copy the file or directory at `local_path` to `target_path` inside the Simulator (does not work on empty directories for now).
    # @param local_path [String] The path to the source file.
    # @param target_path [String] The destination path on the Simulator (may contain directory parts).
    # @param target_root [Symbol] The root path for the file (see #NSSearchPathDirectory).
    def fixture_install( local_path, target_path, target_root )
      ...
    end

    # Remove the file or directory at `path` from the Simulator.
    # @param path [String] The path to the file or directory on the Simulator.
    # @param root [Symbol] The root path for the file (see #NSSearchPathDirectory)
    def fixture_remove( path, root )
      ...
    end

These functions make use of the `backdoor()`-API provided by Calabash.
As the backdoor needs matching methods to call the following line needs to be added to your `ApplicationDelegate`:

    include Crescentia::Fixtures

This will provide the required fixture callbacks in development builds and resolve to an empty stub-module in release builds.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
