require "app-tester"

# Initialize framework with test environments
apptester = AppTester.new do |options|
  options.add_environment :github => "https://github.com"
  options.default_environment = :github # A default environment can be specified
end

# Define your tests
apptester.define_test "my test" do |cmd_options, connection|
  result = connection.get do |request|
    request.url "/"
  end

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