module AppTester

  load_libraries "utils/colors", "utils/strings"

  # @abstract Helper utilities module
  module Utils

    extend self

    include AppTester::Utils::Colours

    # Convert a file to an array
    #
    # @param file [String] path to the file
    #
    # @return [Array] each entry on the array corresponds to each line on the file
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