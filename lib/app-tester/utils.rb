module AppTester

  load_libraries "utils/colors", "utils/strings"

  module Utils

    extend self

    include AppTester::Utils::Colours

    def file_to_array file
      lines = []
      File.open(file, "r") do |infile|
        while (line = infile.gets)
          lines.push(line.gsub("\n", "").rstrip)
        end
      end
      lines
    end
  end
end