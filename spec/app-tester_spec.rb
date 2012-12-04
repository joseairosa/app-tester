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

  describe "when setting a default option" do
    before do
      apptester = AppTester.new do |options|
        options.add_default_option(:something, '-a', '--something SOMETHING', 'Say something')
      end
      @test = apptester.define_test 'my test'
    end
    let(:received_options) { @test.options.default_options }
    let(:option) { received_options[0] }

    it { received_options.size.should == 1 }
    it { option[:symbol].should eq(:something) }
    it { option[:opts].should eq(['-a','--something SOMETHING','Say something']) }
    it { option[:block].should be_nil }
  end

  it "should exit if a mandatory arguemnt is missing" do
    apptester = start_app_tester

    apptester.define_test "my test"

    apptester.set_options_for "my test" do |test_options|
      test_options.set_option(:smiles_file, "-f", "--smiles-file FILE", "File containing SMILES for query (one per line)", true)
    end

    STDOUT.should_receive(:puts).with("Please supply -f / --smiles-file FILE")
    lambda { apptester.run_test("my test") }.should raise_error(SystemExit)
  end

  it "should return help when asked for it" do
    apptester = start_app_tester

    apptester.define_test "my test"

    lambda { apptester.run_test("my test", ["--help"]) }.should raise_error SystemExit
  end

  it "should define a test and run it" do
    apptester = start_app_tester

    mock_arguments "-s" => "production"
    test = apptester.define_test "test 1"

    apptester.tests.size.should eq(1)
    apptester.run_test("test 1").should be_a(AppTester::Test)
    test.arguments.should be_a(Hash)
    test.connection.should be_a(Faraday::Connection)
  end

  it "should define a test without a default environment" do
    apptester = start_app_tester
    test = apptester.define_test "my test"
    apptester.run_test("my test", [])
    test.arguments[:server].should eq("localhost://production")
  end

  it "should define a test with a default environment" do
    apptester = start_app_tester nil, :staging
    test = apptester.define_test "my test"
    apptester.run_test("my test", [])
    test.arguments[:server].should eq("localhost://staging")
  end

  it "should define a test, set custom options and run" do
    apptester = start_app_tester
    test = apptester.define_test "my test"
    apptester.set_options_for "my test" do |test_options|
      test_options.set_option(:smiles_file, "-f", "--smiles-file FILE", "File containing SMILES for query (one per line)")
    end
    mocked_arguments = mock_arguments "-s" => "development", "-f" => "../../file.txt"
    apptester.run_test("my test", mocked_arguments)

    test.arguments.should be_a(Hash)
    test.connection.should be_a(Faraday::Connection)
    test.arguments.size.should be(2)
    test.arguments[:server].should_not be_empty
    test.arguments[:smiles_file].should_not be_empty
  end

  it "should create a connection" do
    apptester = start_app_tester :production => "http://www.google.com"

    test = apptester.define_test "my test"

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("my test", mocked_arguments)
    test.connection.should be_a(Faraday::Connection)
  end
  
  # this should be in a unit test
  xit "should fetch contents of a connection" do
    apptester = start_app_tester :production => "https://github.com"

    test = apptester.define_test "my test" do
      response = get "/"
      response.status.should eq(200)
      response.body.should include("github")
      response = post "/"
      response.status.should eq(403)
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("my test", mocked_arguments)
  end
  
  # this should be in a unit test
  xit "should return exception on connection failed" do
    apptester = start_app_tester :production => "http://aoisjdioasjdioasjod"

    apptester.define_test "my test" do
      begin
        response = get "/"
      rescue Exception => e
        e.should be_a(Faraday::Error::ConnectionFailed)
      end
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("my test", mocked_arguments)
  end

  it "should check status" do
    apptester = start_app_tester :production => "https://github.com"

    apptester.define_test "my test" do
      response = get "/"
      AppTester::Checker.status response
    end

    mocked_arguments = mock_arguments "-s" => "production"

    read_stdout do
      apptester.run_test("my test", mocked_arguments)
    end.should include("[\033[0;32mSUCCESS\033[0m] got status")
  end

  it "should log connections if asked for" do
    apptester = start_app_tester({ :production => "https://github.com" }, nil, true)

    apptester.define_test "my test" do
      response = get "/"
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

    apptester.define_test "my test" do
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

    apptester.define_test "my test 400 threshold" do
      AppTester::Timer.new("test timer", 400) do
        sleep 0.5
      end
    end

    apptester.define_test "my test 600 threshold" do
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
