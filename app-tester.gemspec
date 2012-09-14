# encoding: UTF-8

Gem::Specification.new do |s|
    s.name = 'app-tester'
    s.version = '0.0.1'

    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.date = %q{2012-09-13}
    s.summary = %q{Application Tester Framework}
    s.description = %q{Framework to run functional and soak tests against a web application (API, Website, etc)}
    s.authors = ["Jose P. Airosa"]
    s.email = %q{me@joseairosa.com}
    s.homepage = %q{https://github.com/joseairosa/app-tester}

    s.files = Dir[
        "lib/**/*.rb",
        "README*",
        "LICENSE",
        "Rakefile",
        "spec/**/*",
        "test/test.conf"
    ]

    s.rubyforge_project = "app-tester"
    s.add_dependency "json", ">= 1.7.5"
    s.add_dependency "faraday", ">= 0.8.4"
end