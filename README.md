# motion-crescentia

[![Gem Version](https://badge.fury.io/rb/motion-crescentia.svg)](http://badge.fury.io/rb/motion-crescentia)

An easy way to integrate Calabash iOS into RubyMotion projects.
It was conceived as an alternative to `motion-calabash` since I felt the need for a more recent version of calabash-ios and also since the gem on GitHub didn't receive a lot of love lately.

In addition to providing an alternative wrapper crescentia also adds some new features like easy support for the installation and removal of fixture data inside the running simulator.

* For more information about Calabash see: http://calaba.sh
* For more information about the official motion-calabsh see: https://github.com/calabash/motion-calabash


## Requirements

* RubyMotion 1.0 or newer (see http://www.rubymotion.com)
* XCode 6.1 or newer (available from the Mac AppStore)

## Installation

Add this line to your application's Gemfile:

```ruby
    gem 'motion-crescentia'
```

And then execute:

```bash
    $ bundle
```

Or install it yourself as:

```bash
    $ gem install motion-crescentia
```

## Usage

### rake tasks

After following the installation steps there will be four new rake tasks available:

#### crescentia:setup

This will create the initial cucumber `features` directory and populate it with the files required by calabash as well as the fixture additions provided by crescentia.

#### crescentia:run &#91;:target&#93;

Execute cucumber to run the acceptance tests defined in your `features` directory.
This task expects a target on which the tests should be run (either as rake argument or as the first parameter).

Possible values include any target supported by the iPhoneSimulator or `device` to execute on a connected iOS device.
For a list of available simulator targets run:

```bash
    $ instruments -s devices
```

If no target is specified a list of possible targets will be provided to choose from.

**NOTE:** Any additional arguments for `cucumber` can be passed by setting the `args` environment variable.

#### crescentia:push &#91;:target, :clean&#93;

Install the application bundle in the simulator.
If `:clean` is set to 1 (or passed via clean=1 ) the application will be removed and then reinstalled.
For details on `:target` see *crescentia:run*.

**NOTE:** `:run` does an implicit `:push` if the target is a simulator.

#### crescentia:repl &#91;:target&#93;

Start the interactive calabash irb console.
This task too requires a target specification, see *crescentia:run* for details on that.

### providing fixture data

Crescentia provides support for copying fixture data at runtime.
To enable this feature following line needs to be added to your `ApplicationDelegate`:

```ruby
    include Crescentia::Fixtures
```

This will provide the required fixture callbacks in development builds and resolve to an empty stub-module in release builds.

#### Call from inside your Cucumber features / Spec files

To easily add and remove fixture data in your acceptance tests crescentia provides two functions which can be called from cucumber
features or spec files:

```ruby

# Copy the file or directory at `local_path` to `target_path` inside the 
# Simulator (does not work on empty directories for now).
# @param [String] local_path  The path to the source file.
# @param [String] target_path The destination path on the Simulator (may contain directory parts).
# @param [Symbol] target_root The root path for the file (see {NSSearchPathDirectory}).
def fixture_install( local_path, target_path, target_root )
  #...
end

# Remove the file or directory at `path` from the Simulator.
# @param [String] path The path to the file or directory on the Simulator.
# @param [Symbol] root The root path for the file (see {NSSearchPathDirectory})
def fixture_remove( path, root )
    #...
end
```

For Cucumber tests these functions make use of the `backdoor()`-API provided by Calabash.
For Spec runs (only supported in the simulator) a direct call without `backdoor()` is performed.

##### sample step definition (Cucumber)

```ruby

Given /^I have some data available$/ do
  # Copy recursively the folder 'fixture-data' to the simulator under the name 'files'
  fixture_install( "#{Dir.pwd}/fixture-data", 'files', :NSDocumentDirectory )
end

Given /^There is some deeply nested picture file/ do
  # Copy 'sample.png' to 'Pictures/Stuff/sample.png' inside the :NSDocumentDirectory.
  fixture_install( "#{Dir.pwd}/sample.png", 'Pictures/Stuff/sample.png', :NSDocumentDirectory )
end

Given /^I work an a clean slate$/ do
  # Remove the 'files' directory and all it's contents.
  fixture_remove( 'files', :NSDocumentDirectory )
end
```

##### sample step definition (RSpec)

```ruby

describe 'My sample view controller' do
  context 'when there is data available' do
    before do
      # Copy recursively the folder 'spec/data/fixture-data' to the simulator under the name 'files'
      fixture_install( fixture_host_path( 'spec', 'data', 'fixture-data' ), 'files', :NSDocumentDirectory )
    end

    after do
      # Remove the 'files' directory and all it's contents.
      fixture_remove( 'files', :NSDocumentDirectory )
    end
  end
end

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
