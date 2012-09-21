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