require File.dirname(__FILE__) + '/spec_helper.rb'

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
    apptester = AppTester.new do |options|
      options.add_environment :production => "localhost://production"
      options.add_environment :staging => "localhost://staging"
      options.add_environment :development => "localhost://development"
    end
    apptester.options.environments.should be_a(Hash)
    apptester.options.environments.size.should eq(3)
    apptester.options.environments[:production].should eq("localhost://production")
    apptester.options.environments[:staging].should eq("localhost://staging")
    apptester.options.environments[:development].should eq("localhost://development")
  end

  it "should return help when asked for it" do
    apptester = AppTester.new do |options|
      options.add_environment :production => "localhost://production"
      options.add_environment :staging => "localhost://staging"
      options.add_environment :development => "localhost://development"
    end

    apptester.define_test "test arguments" do |this_test|
      # blergh!
    end

    lambda {
      apptester.run_test("test arguments", ["--help"])
    }.should raise_error SystemExit
  end

  it "should define a test and run it" do
    apptester = AppTester.new do |options|
      options.add_environment :production => "localhost://production"
    end

    mock_arguments "-s" => "production"

    apptester.define_test("test 1") do |this_test|
      this_test.should be_a(AppTester::Test)
      "1"
    end
    apptester.define_test("test 2") do |this_test|
      this_test.should be_a(AppTester::Test)
      "2"
    end
    apptester.tests.size.should eq(2)
    apptester.run_test("test 1").should eq("1")
    apptester.run_test("test 2").should eq("2")
  end

  it "should define a test without a default environment" do
    apptester = AppTester.new do |options|
      options.add_environment :production => "localhost://production"
      options.add_environment :staging => "localhost://staging"
      options.add_environment :development => "localhost://development"
    end

    apptester.define_test "test arguments" do |this_test|
      this_test.parser.options[:server].should eq("localhost://production")
    end

    apptester.run_test("test arguments", [])
  end

  it "should define a test with a default environment" do
    apptester = AppTester.new do |options|
      options.add_environment :production => "localhost://production"
      options.add_environment :staging => "localhost://staging"
      options.add_environment :development => "localhost://development"
      options.default_environment = :staging
    end

    apptester.define_test "test arguments" do |this_test|
      this_test.parser.options[:server].should eq("localhost://staging")
    end

    apptester.run_test("test arguments", [])
  end

  it "should define a test, set custom options and run" do
    apptester = AppTester.new do |options|
      options.add_environment :production => "localhost://production"
      options.add_environment :staging => "localhost://staging"
      options.add_environment :development => "localhost://development"
      options.default_environment = :staging
    end
    apptester.define_test "test arguments" do |this_test|
      this_test.should be_a(AppTester::Test)
      this_test.parser.options.size.should be(2)
      this_test.parser.options[:server].should_not be_empty
      this_test.parser.options[:smiles_file].should_not be_empty
    end
    apptester.set_options_for "test arguments" do |test_options|
      test_options.set_option(:smiles_file, "-f", "--smiles-file FILE", "File containing SMILES for query (one per line)")
    end

    mocked_arguments = mock_arguments "-s" => "development", "-f" => "../../file.txt"

    apptester.run_test("test arguments", mocked_arguments)
  end

  it "should create a connection" do
    apptester = AppTester.new do |options|
      options.add_environment :production => "http://www.google.com"
    end

    apptester.define_test "test arguments" do |this_test|
      this_test.connection.should be_a(AppTester::Connection)
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("test arguments", mocked_arguments)
  end

  it "should fetch contents of a connection" do
    apptester = AppTester.new do |options|
      options.add_environment :production => "https://github.com"
    end

    apptester.define_test "test arguments" do |this_test|
      response = this_test.connection.get do |req|
        req.url "/"
      end
      response.status.should eq(200)
      response.body.should include("github")
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("test arguments", mocked_arguments)
  end

  it "should return exception on connection failed" do
    apptester = AppTester.new do |options|
      options.add_environment :production => "http://aoisjdioasjdioasjod"
    end

    apptester.define_test "test arguments" do |this_test|
      response = this_test.connection.get do |req|
        req.url "/"
      end
      response.should raise_error Faraday::Error::ConnectionFailed
    end

    mocked_arguments = mock_arguments "-s" => "production"

    apptester.run_test("test arguments", mocked_arguments)
  end

  def mock_arguments hash={ }
    hash.flatten
  end
end
