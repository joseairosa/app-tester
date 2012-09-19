require "app-tester"

apptester = AppTester.new do |options|
  options.add_environment :github => "https://github.com"
  options.add_environment :google => "https://google.com"
  options.default_environment = :google
end

apptester.define_test "my test" do
  result = get "/"

  AppTester::Checker.status result

  my_file = AppTester::Utils.file_to_array arguments[:file]

  my_file.should be_a(Hash)

  my_file.each do |line|
    # do awesome stuff with line
  end
end

apptester.set_options_for "my test" do |options_parser|
  options_parser.set_option(:file, "-f", "--file FILE", "File to load")
  options_parser.mandatory_options = 1
end

apptester.run_test "my test"