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

    apptester.define_test "test arguments" do |options, connection|
      # blergh!
    end

    lambda {
      apptester.run_test("test arguments", ["--help"])
    }.should raise_error SystemExit
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

    apptester.define_test "test arguments" do |options, connection|
      options[:server].should eq("localhost://production")
    end

    apptester.run_test("test arguments", [])
  end

  it "should define a test with a default environment" do
    apptester = start_app_tester nil, :staging

    apptester.define_test "test arguments" do |options, connection|
      options[:server].should eq("localhost://staging")
    end

    apptester.run_test("test arguments", [])
  end

  it "should define a test, set custom options and run" do
    apptester = start_app_tester

    apptester.define_test "test arguments" do |options, connection|
      options.should be_a(Hash)
      connection.should be_a(Faraday::Connection)
      options.size.should be(2)
      options[:server].should_not be_empty
      options[:smiles_file].should_not be_empty
    end

    apptester.set_options_for "test arguments" do |test_options|
      test_options.set_option(:smiles_file, "-f", "--smiles-file FILE", "File containing SMILES for query (one per line)")
    end

    mocked_arguments = mock_arguments "-s" => "development", "-f" => "../../file.txt"

    apptester.run_test("test arguments", mocked_arguments)
  end

  it "should create a connection" do
    apptester = start_app_tester :production => "http://www.google.com"

    apptester.define_test "test arguments" do |options, connection|
      connection.should be_a(Faraday::Connection)
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("test arguments", mocked_arguments)
  end

  it "should fetch contents of a connection" do
    apptester = start_app_tester :production => "https://github.com"

    apptester.define_test "test arguments" do |options, connection|
      response = connection.get do |req|
        req.url "/"
      end
      response.status.should eq(200)
      response.body.should include("github")
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("test arguments", mocked_arguments)
  end

  it "should return exception on connection failed" do
    apptester = start_app_tester :production => "http://aoisjdioasjdioasjod"

    apptester.define_test "test arguments" do |options, connection|
      begin
        response = connection.get do |req|
          req.url "/"
        end
      rescue Exception => e
        e.should be_a(Faraday::Error::ConnectionFailed)
      end
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("test arguments", mocked_arguments)
  end

  it "should log connections if asked for" do
    apptester = start_app_tester({ :production => "https://github.com" }, nil, true)

    apptester.define_test "test arguments" do |options, connection|
      response = connection.get do |req|
        req.url "/"
      end
    end

    mocked_arguments = mock_arguments "-s" => "production"

    read_stdout do
      apptester.run_test("test arguments", mocked_arguments)
    end.should include("DEBUG")
  end
  # it should retry connection if failed and specified number of retries
  # it should output colors correctly
  # it should throw exception on no name test
  # it should throw exception on test not found
  # it should time the execution
  # it should time the execution with threshold

  def mock_arguments hash={ }
    hash.flatten
  end

  def start_app_tester(environments=nil, default_environment=nil, log_connections=nil, connection_retries=nil)
    AppTester.new do |options|
      (environments || { :production => "localhost://production", :staging => "localhost://staging", :development => "localhost://development" }).each do |k, v|
        options.add_environment k => v
      end
      options.default_environment = default_environment unless default_environment.nil?
      options.log_connections = log_connections unless log_connections.nil?
      options.connection_retries = connection_retries unless connection_retries.nil?
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
