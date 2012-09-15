# Application Tester (app-tester)

* http://github.com/joseairosa/app-tester

## DESCRIPTION:

This Gem will provide a framework to build command line functional tests against a web application (API, Website, etc)

## FEATURES/PROBLEMS:

* Easily create functional tests with just a few lines of code
* Since tests are built as command line tools they can be easily integrated with automatic tools
* Specify command line options in both short (-s, -f, etc...) and long (--server, --file, etc...) definition
* Add colors to make your tests more readable and easier to understand
* Use pre-built tools to analyse your output or build your own

## SYNOPSIS:

```ruby
require "app-tester"

# Initialize framework with test environments
apptester = AppTester.new do |options|
  options.add_environment :github => "https://github.com"
  options.add_environment :google => "https://google.com"
  options.default_environment = :google # A default environment can be specified
end

# Define your tests
apptester.define_test "my test" do |options, connection|
  result = connection.get do |request|
    request.url "/"
  end
  # Check if we have a 200 OK or not
  AppTester::Checker.status result

  # Convert a file to an array
  AppTester::Utils.file_to_array options[:file]
end

apptester.set_options_for "my test" do |test_options|
  test_options.set_option(:file, "-f", "--file FILE", "File to load")
  test_options.mandatory_options = 1
end

apptester.run_test "my test"
```

## REQUIREMENTS:

* json >= 1.7.5
* faraday >= 0.8.4
* optparse

## INSTALL:

It's very easy to install.

```
gem install app-tester
```

Done! :)
 
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

  [jruby]:     http://jruby.org/
  [rubinius]:  http://rubini.us/