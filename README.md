# Application Tester (app-tester)

* This page: http://github.com/joseairosa/app-tester
* Rubygems: http://rubygems.org/gems/app-tester
* Documentation: http://i.am.joseairosa.com/gems/app-tester/

[![Build Status](https://secure.travis-ci.org/joseairosa/app-tester.png)](http://travis-ci.org/joseairosa/app-tester)

## Description

This Gem will provide a framework to build command line functional tests against a web application (API, Website, etc)

## Features

* Easily create functional tests with just a few lines of code
* Since tests are built as command line tools they can be easily integrated with automatic tools
* Specify command line options in both short (-s, -f, etc...) and long (--server, --file, etc...) definition
* Add colors to make your tests more readable and easier to understand
* Use pre-built tools to analyse your output or build your own

## Introduction

```ruby
require "app-tester"

# Initialize framework with test environments
apptester = AppTester.new do |options|
  options.add_environment :github => "https://github.com"
  options.add_environment :google => "https://google.com"
  options.default_environment = :google # A default environment can be specified
end

# Define your tests
apptester.define_test "my test" do |arguments, connection|
  # Perform a get request to "/"
  result1 = get "/"
  # Perform a post request to "/" with token as parameter
  result2 = get "/", :token => "hello"
  # Perform a post request to "/"
  result3 = post "/"
  # Perform a post request to "/" with token as parameter
  result4 = post "/", :token => "hello"

  # Check if we have a 200 OK or not
  AppTester::Checker.status result1

  # Convert a file to an array
  p AppTester::Utils.file_to_array arguments[:file] unless arguments[:file].nil?
end

apptester.set_options_for "my test" do |options_parser|
  options_parser.set_option(:file, "-f", "--file FILE", "File to load")
  options_parser.mandatory_options = 1
end

apptester.run_test "my test"
```

Assuming that this is in a file called my_test.rb, you can run it, via command line:

```
$ ruby my_test.rb --help
```

Will output:

```
my test

    -s, --server OPT                 Server to connect. Default: google
    -f, --file FILE                  File to load
    -h, --help                       Show this message
```

Or you can run the test itself:

```
$ ruby my_test.rb -s github
```

Will output:

```
Connecting to https://github.com...
[SUCCESS] got status 200
```

## Requirements

* json >= 1.7.5
* faraday >= 0.8.4
* optparse

## Install

It's very easy to install.

```
gem install app-tester
```

Done! :)

## Dealing with expectations

One of the really nice features of this gem is that resembles a lot how RSpec works in terms of expectations.

So lets assume that you want to test some kind of expectation:

```ruby
require "app-tester"

apptester = AppTester.new do |options|
  options.add_environment :github => "https://github.com"
  options.add_environment :google => "https://google.com"
  options.default_environment = :google
end

apptester.define_test "my test to fail" do
  var = true

  var.should be_nil
end

apptester.run_test "my test to fail"
```

When you run this test you'll get the following output:

```
$ ruby examples/expectations.rb
Connecting to https://google.com...
[FAILED] expected: nil
     got: true on line 12
```

Take a loot at [RSpec::Matches][] for more information on which matchers you can use

## Adding colours to your tests

AppTester has a useful helper class that enables anyone to add colours to the tests.
Lets take the example where we want to output "Hello World" in 2 different colours.

```ruby
require "app-tester"

# Initialize framework with test environments
apptester = AppTester.new do |options|
  options.add_environment :github => "https://github.com"
  options.default_environment = :github # A default environment can be specified
end

# Define your tests
apptester.define_test "my test" do |arguments, connection|
  result = get "/"

  puts "#{AppTester::Utils::Colours.red("Hello")} #{AppTester::Utils::Colours.green("World")}"
end

apptester.run_test "my test"
```

Available colours are:

* black
* blue
* green
* cyan
* red
* purple
* brown
* light_gray
* dark_gray
* light_blue
* light_green
* light_cyan
* light_red
* light_purple
* yellow
* white

## Benchmarking

You can benchmark your test. This is very useful to understand if anything is underperforming.
Tests can be nested inside each other.

```ruby
require "app-tester"

# Initialize framework with test environments
apptester = AppTester.new do |options|
  options.add_environment :github => "https://github.com"
  options.default_environment = :github # A default environment can be specified
end

# Define your tests
apptester.define_test "my test" do |arguments, connection|
  result = get "/"

  AppTester::Timer.new("test timer 1") do
    sleep 1
  end

  AppTester::Timer.new("test timer 2") do
    sleep 1
    AppTester::Timer.new("test timer 2.1") do
      sleep 1
    end
  end
end

apptester.run_test "my test"
```

This will output:

```
$ ruby examples/benchmark.rb
Connecting to https://github.com...
   Time elapsed to test timer 1, 1001.086 milliseconds
   Time elapsed to test timer 2.1, 1000.12 milliseconds
   Time elapsed to test timer 2, 2001.204 milliseconds
```

## Reading from a file

File are extremely usefull tools.
We can have, for example, a functional test to an API where we want to run 100 strings against an end-point. For this you only need to create a new plain text file, write 1 string per line and use this gem to read them.

Here is an example:

```ruby
require "app-tester"

apptester = AppTester.new do |options|
  options.add_environment :github => "https://github.com"
  options.add_environment :google => "https://google.com"
  options.default_environment = :google
end

apptester.define_test "my test" do |arguments, connection|
  result = get "/"

  AppTester::Checker.status result

  my_file = AppTester::Utils.file_to_array arguments[:file]

  my_file.each do |line|
    # do awesome stuff with line
  end
end

apptester.set_options_for "my test" do |options_parser|
  options_parser.set_option(:file, "-f", "--file FILE", "File to load")
  options_parser.mandatory_options = 1
end

apptester.run_test "my test"
```
 
## Supported Ruby versions

This library aims to support and is tested against the following Ruby
implementations:

* MRI 1.8.7
* MRI 1.9.2
* MRI 1.9.3
* [JRuby][]
* [Rubinius][]

If something doesn't work on one of these interpreters, it should be considered
a bug.

## LICENSE:

(The MIT License)

Copyright (c) 2012 José P. Airosa

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  [rspec_matches]:  http://rubydoc.info/gems/rspec-expectations/2.4.0/RSpec/Matchers
  [jruby]:          http://jruby.org/
  [rubinius]:       http://rubini.us/