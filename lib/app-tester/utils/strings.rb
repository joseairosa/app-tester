module AppTester
  module Utils
    module Strings
      SUCCESS="[#{AppTester::Utils::Colours.green "SUCCESS"}]"
      OK="[#{AppTester::Utils::Colours.blue "OK"}]"
      DONE="[#{AppTester::Utils::Colours.green "OK"}]"
      FAILED="[#{AppTester::Utils::Colours.red "FAILED"}]"
      WARNING="[#{AppTester::Utils::Colours.yellow "WARNING"}]"
      TEST_HEADING="[#{AppTester::Utils::Colours.purple "TEST"}]"
    end
  end
end