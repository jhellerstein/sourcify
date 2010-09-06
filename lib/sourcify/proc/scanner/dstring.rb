module Sourcify
  module Proc
    module Scanner #:nodoc:all
      class DString < Struct.new(:tag)

        def <<(content)
          (@contents ||= []) << content
        end

        def to_s
          @contents.join
        end

        def closed?
          begin
            instance_eval(safe_contents) if evaluable?
          rescue SyntaxError
            false
          end
        end

        private

          CLOSING_TAGS = {'(' => ')', '[' => ']', '<' => '>', '{' => '}'}

          def evaluable?
            @contents[-1][-1].chr == end_tag
          end

          def safe_contents
            # NOTE: %x & ` strings are dangerous to eval cos they execute shell commands,
            # thus we convert them to normal strings 1st
            contents = @contents.join
            if contents.start_with?('%x')
              contents.sub!('%x','%Q')
            elsif contents.start_with?('`')
              contents.sub!(/^\`/,'%Q`')
            end
            contents
          end

          def start_tag
            @start_tag ||= tag[-1].chr
          end

          def end_tag
            @end_tag ||= (CLOSING_TAGS[start_tag] || start_tag)
          end

      end
    end
  end
end
