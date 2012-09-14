require File.dirname(__FILE__) + '/spec_helper.rb'
require 'tempfile'

# Time to add your specs!
# http://rspec.info/
describe "App Tester framework" do

  it "should initialize" do
    # violated "Be sure to write your specs"
    apptester = AppTester.new
    apptester.should be_a(Module)
    apptester.should respond_to(:options)
  end

  it "should set options" do
    apptester = start_app_tester

    apptester.options.environments.should be_a(Hash)
    apptester.options.environments.size.should eq(3)
    apptester.options.environments[:production].should eq("localhost://production")
    apptester.options.environments[:staging].should eq("localhost://staging")
    apptester.options.environments[:development].should eq("localhost://development")
  end

  it "should return help when asked for it" do
    apptester = start_app_tester

    apptester.define_test "my test" do |options, connection|
      # blergh!
    end

    lambda { apptester.run_test("my test", ["--help"]) }.should raise_error SystemExit
  end

  it "should define a test and run it" do
    apptester = start_app_tester

    mock_arguments "-s" => "production"

    apptester.define_test("test 1") do |options, connection|
      options.should be_a(Hash)
      connection.should be_a(Faraday::Connection)
      "1"
    end
    apptester.define_test("test 2") do |options, connection|
      options.should be_a(Hash)
      connection.should be_a(Faraday::Connection)
      "2"
    end
    apptester.tests.size.should eq(2)
    apptester.run_test("test 1").should eq("1")
    apptester.run_test("test 2").should eq("2")
  end

  it "should define a test without a default environment" do
    apptester = start_app_tester

    apptester.define_test "my test" do |options, connection|
      options[:server].should eq("localhost://production")
    end

    apptester.run_test("my test", [])
  end

  it "should define a test with a default environment" do
    apptester = start_app_tester nil, :staging

    apptester.define_test "my test" do |options, connection|
      options[:server].should eq("localhost://staging")
    end

    apptester.run_test("my test", [])
  end

  it "should define a test, set custom options and run" do
    apptester = start_app_tester

    apptester.define_test "my test" do |options, connection|
      options.should be_a(Hash)
      connection.should be_a(Faraday::Connection)
      options.size.should be(2)
      options[:server].should_not be_empty
      options[:smiles_file].should_not be_empty
    end

    apptester.set_options_for "my test" do |test_options|
      test_options.set_option(:smiles_file, "-f", "--smiles-file FILE", "File containing SMILES for query (one per line)")
    end

    mocked_arguments = mock_arguments "-s" => "development", "-f" => "../../file.txt"

    apptester.run_test("my test", mocked_arguments)
  end

  it "should define a test, set custom options, define number mandatory options and run" do
    apptester = start_app_tester

    apptester.define_test "my test" do |options, connection|

    end

    apptester.set_options_for "my test" do |test_options|
      test_options.set_option(:smiles_file, "-f", "--smiles-file FILE", "File containing SMILES for query (one per line)")
      test_options.mandatory_options = 1
    end

    mocked_arguments = mock_arguments "-s" => "development"

    lambda { apptester.run_test("my test", mocked_arguments) }.should raise_error OptionParser::MissingArgument
  end

  it "should create a connection" do
    apptester = start_app_tester :production => "http://www.google.com"

    apptester.define_test "my test" do |options, connection|
      connection.should be_a(Faraday::Connection)
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("my test", mocked_arguments)
  end

  it "should fetch contents of a connection" do
    apptester = start_app_tester :production => "https://github.com"

    apptester.define_test "my test" do |options, connection|
      response = connection.get do |req|
        req.url "/"
      end
      response.status.should eq(200)
      response.body.should include("github")
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("my test", mocked_arguments)
  end

  it "should return exception on connection failed" do
    apptester = start_app_tester :production => "http://aoisjdioasjdioasjod"

    apptester.define_test "my test" do |options, connection|
      begin
        response = connection.get do |req|
          req.url "/"
        end
      rescue Exception => e
        e.should be_a(Faraday::Error::ConnectionFailed)
      end
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("my test", mocked_arguments)
  end

  it "should check status" do
    apptester = start_app_tester :production => "https://github.com"

    apptester.define_test "my test" do |options, connection|
      response = connection.get do |req|
        req.url "/"
      end
      AppTester::Checker.status response
    end

    mocked_arguments = mock_arguments "-s" => "production"

    read_stdout do
      apptester.run_test("my test", mocked_arguments)
    end.should include("[\033[0;32mSUCCESS\033[0m] got status")
  end

  it "should log connections if asked for" do
    apptester = start_app_tester({ :production => "https://github.com" }, nil, true)

    apptester.define_test "my test" do |options, connection|
      response = connection.get do |req|
        req.url "/"
      end
    end

    mocked_arguments = mock_arguments "-s" => "production"

    read_stdout do
      apptester.run_test("my test", mocked_arguments)
    end.should include("DEBUG")
  end

  it "should output colors correctly" do
    AppTester::Utils::Colours.black("hello").should eq("\033[0;30mhello\033[0m")
    AppTester::Utils::Colours.blue("hello").should eq("\033[0;34mhello\033[0m")
    AppTester::Utils::Colours.green("hello").should eq("\033[0;32mhello\033[0m")
    AppTester::Utils::Colours.cyan("hello").should eq("\033[0;36mhello\033[0m")
    AppTester::Utils::Colours.red("hello").should eq("\033[0;31mhello\033[0m")
    AppTester::Utils::Colours.purple("hello").should eq("\033[0;35mhello\033[0m")
    AppTester::Utils::Colours.brown("hello").should eq("\033[0;33mhello\033[0m")
    AppTester::Utils::Colours.light_gray("hello").should eq("\033[0;37mhello\033[0m")
    AppTester::Utils::Colours.dark_gray("hello").should eq("\033[1;30mhello\033[0m")
    AppTester::Utils::Colours.light_blue("hello").should eq("\033[1;34mhello\033[0m")
    AppTester::Utils::Colours.light_green("hello").should eq("\033[1;32mhello\033[0m")
    AppTester::Utils::Colours.light_cyan("hello").should eq("\033[1;36mhello\033[0m")
    AppTester::Utils::Colours.light_red("hello").should eq("\033[1;31mhello\033[0m")
    AppTester::Utils::Colours.light_purple("hello").should eq("\033[1;35mhello\033[0m")
    AppTester::Utils::Colours.yellow("hello").should eq("\033[1;33mhello\033[0m")
    AppTester::Utils::Colours.white("hello").should eq("\033[1;37mhello\033[0m")
  end

  it "should throw exception on no name test" do
    apptester = start_app_tester
    lambda { apptester.define_test }.should raise_exception(AppTester::Error::NameEmptyError)
  end

  it "should throw exception on test not found" do
    apptester = start_app_tester
    apptester.define_test "hello"
    lambda { apptester.get_test "bye" }.should raise_exception(AppTester::Error::TestNotFoundError)
  end

  it "should time the execution" do
    apptester = start_app_tester

    apptester.define_test "my test" do |options, connection|
      AppTester::Timer.new("test timer") do
        sleep 1
      end
    end

    read_stdout do
      apptester.run_test("my test")
    end.should include("Time elapsed to test timer, 100")
  end

  it "should time the execution with threshold" do
    apptester = start_app_tester

    apptester.define_test "my test 400 threshold" do |options, connection|
      AppTester::Timer.new("test timer", 400) do
        sleep 0.5
      end
    end

    apptester.define_test "my test 600 threshold" do |options, connection|
      AppTester::Timer.new("test timer", 600) do
        sleep 0.5
      end
    end

    output = read_stdout do
      apptester.run_test("my test 400 threshold")
    end
    output.should include("WARNING")
    output.should include("Time elapsed to test timer, 50")
    output.should include("threshold: 400")

    output = read_stdout do
      apptester.run_test("my test 600 threshold")
    end
    output.should_not include("WARNING")
    output.should include("Time elapsed to test timer, 50")
    output.should include("threshold: 600")
  end

  def mock_arguments hash={ }
    hash.flatten
  end

  def start_app_tester(environments=nil, default_environment=nil, log_connections=nil)
    AppTester.new do |options|
      (environments || { :production => "localhost://production", :staging => "localhost://staging", :development => "localhost://development" }).each do |k, v|
        options.add_environment k => v
      end
      options.default_environment = default_environment unless default_environment.nil?
      options.log_connections = log_connections unless log_connections.nil?
    end
  end

  def read_stdout
    results = Tempfile.new('a').path
    a = STDOUT.dup
    STDOUT.reopen(results, 'w')
    yield
    STDOUT.reopen(a)
    File.read(results)
  end
end
