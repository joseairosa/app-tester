module AppTester
  module Utils
    module Colours

      extend self

      def black message=""
        _build_message("0;30", message)
      end
      def blue message=""
        _build_message("0;34", message)
      end
      def green message=""
        _build_message("0;32", message)
      end
      def cyan message=""
        _build_message("0;36", message)
      end
      def red message=""
        _build_message("0;31", message)
      end
      def purple message=""
        _build_message("0;35", message)
      end
      def brown message=""
        _build_message("0;33", message)
      end
      def light_gray message=""
        _build_message("0;37", message)
      end
      def dark_gray message=""
        _build_message("1;30", message)
      end
      def light_blue message=""
        _build_message("1;34", message)
      end
      def light_green message=""
        _build_message("1;32", message)
      end
      def light_cyan message=""
        _build_message("1;36", message)
      end
      def light_red message=""
        _build_message("1;31", message)
      end
      def light_purple message=""
        _build_message("1;35", message)
      end
      def yellow message=""
        _build_message("1;33", message)
      end
      def white message=""
        _build_message("1;37", message)
      end
      private
      def _build_message(color, message)
        "\033[#{color}m#{message}\033[0m"
      end
    end
  end
end