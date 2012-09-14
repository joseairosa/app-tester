require "app-tester"

apptester = AppTester.new do |options|
  options.add_environment :github => "https://github.com"
  options.add_environment :google => "https://google.com"
  options.default_environment = :google
end

apptester.define_test "my test" do |options, connection|
  result = connection.get do |request|
    request.url "/"
  end
  AppTester::Checker.status result

  p AppTester::Utils.file_to_array options[:file]
end

apptester.set_options_for "my test" do |test_options|
  test_options.set_option(:file, "-f", "--file FILE", "File to load")
  test_options.mandatory_options = 1
end

apptester.run_test "my test"