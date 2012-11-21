module GeneratorSpec
  module Matcher
    class File
      def initialize(name, &block)
        @contents = []
        @omit_contents = []
        @name = name

        if block_given?
          instance_eval(&block)
        end
      end
      
      def omits(text)
        @omit_contents << text
      end

      protected

      def check_contents(file)
        contents = ::File.read(file)

        @contents.each do |string|
          unless contents.include?(string)
            throw :failure, [file, string, contents]
          end
        end

        @omit_contents.each do |string|
          if contents.include?(string)
            throw :failure, [:not, "the contents '#{string}' in #{file}"]
          end
        end
      end
    end
  end
end


