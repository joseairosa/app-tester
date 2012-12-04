# encoding: UTF-8

Gem::Specification.new do |s|
    s.name = 'app-tester'
    s.version = '0.1.2'

    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.date = %q{2012-09-21}
    s.summary = %q{Application Tester Framework}
    s.description = %q{Command-line Framework to run functional tests against a web application (API, Website, etc)}
    s.authors = ["Jose P. Airosa"]
    s.email = %q{me@joseairosa.com}
    s.homepage = %q{https://github.com/joseairosa/app-tester}
    s.license = 'MIT'
    s.post_install_message = "\033[0;32mThanks for installing! You're awesome! ^_^\033[0m"

    s.test_files = %w(spec/app-tester_spec.rb)

    s.files = Dir[
        "lib/**/*.rb",
        "README*",
        "Rakefile",
        "spec/**/*",
        "test/*"
    ]

    s.rubyforge_project = "app-tester"
    s.add_dependency "json", ">= 1.7.5"
    s.add_dependency "faraday", ">= 0.8.4"
    s.add_dependency "rspec", ">= 2.11.0"
    s.add_dependency "rspec-expectations", ">= 2.11.3"
    s.add_development_dependency "rake"
    s.add_development_dependency "rspec"
end