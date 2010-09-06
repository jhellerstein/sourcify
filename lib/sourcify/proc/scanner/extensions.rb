curr_dir = File.dirname(__FILE__)
require File.join(curr_dir, 'heredoc')
require File.join(curr_dir, 'comment')
require File.join(curr_dir, 'dstring')
require File.join(curr_dir, 'counter')

module Sourcify
  module Proc
    module Scanner #:nodoc:all
      module Extensions

        class Escape < Exception; end

        def process(data)
          begin
            @results, @data = [], data.unpack("c*")
            reset_attributes
            execute!
          rescue Escape
            @results
          end
        end

        def push(key, ts, te)
          @tokens << [key, data_frag(ts .. te.pred)]
        end

        def data_frag(range)
          @data[range].pack('c*')
        end

        def push_dstring(ts, te)
          data = data_frag(ts .. te.pred)
          unless @dstring
            @dstring = DString.new(data[%r{^("|`|/|%(?:Q|W|r|x|)(?:\W|_))},1])
          end
          @dstring << data
          return true unless @dstring.closed?
          @tokens << [:dstring, @dstring.to_s]
          @dstring = nil
        end

        def push_comment(ts, te)
          data = data_frag(ts .. te.pred)
          @comment ||= Comment.new
          @comment << data
          return true unless @comment.closed?
          @tokens << [:comment, @comment.to_s]
          @comment = nil
        end

        def push_heredoc(ts, te)
          data = data_frag(ts .. te.pred)
          unless @heredoc
            indented, tag = data.match(/\<\<(\-?)['"]?(\w+)['"]?$/)[1..3]
            @heredoc = Heredoc.new(tag, !indented.empty?)
          end
          @heredoc << data
          return true unless @heredoc.closed?(data_frag(te .. te))
          @tokens << [:heredoc, @heredoc.to_s]
          @heredoc = nil
        end

        def push_label(data)
          # NOTE: 1.9.* supports label key, which RubyParser cannot handle, thus
          # conversion is needed.
          @tokens << [:symbol, data.sub(/^(.*)\:$/, ':\1')]
          @tokens << [:space, ' ']
          @tokens << [:assoc, '=>']
        end

        def increment_lineno
          @lineno += 1
          raise Escape unless @results.empty?
        end

        def increment_counter(type, count = 1)
          send(:"increment_#{type}_counter", count)
        end

        def decrement_counter(type, key)
          send(:"decrement_#{key}_counter")
        end

        def increment_do_end_counter(count)
          return if @brace_counter.started?
          @do_end_counter.increment(count)
        end

        def decrement_do_end_counter
          return unless @do_end_counter.started?
          @do_end_counter.decrement
          construct_result_code if @do_end_counter.balanced?
        end

        def increment_brace_counter(type)
          return if @do_end_counter.started?
          offset_attributes unless @brace_counter.started?
          @brace_counter.increment
        end

        def decrement_brace_counter
          return unless @brace_counter.started?
          @brace_counter.decrement
          construct_result_code if @brace_counter.balanced?
        end

        def fix_counter_false_start(key)
          if instance_variable_get(:"@#{key}_counter").just_started?
            reset_attributes
          end
        end

        def construct_result_code
          begin
            code = 'proc ' + @tokens.map(&:last).join
            eval(code) # TODO: is there a better way to check for SyntaxError ?
            @results << code
            raise Escape unless @lineno == 1
            reset_attributes
          rescue SyntaxError
          end
        end

        def reset_attributes
          @tokens = []
          @lineno = 1
          @heredoc, @dstring, @comment = nil
          @do_end_counter = DoEndBlockCounter.new
          @brace_counter = BraceBlockCounter.new
        end

        def offset_attributes
          @lineno = 1 # Fixing JRuby's lineno bug (see http://jira.codehaus.org/browse/JRUBY-5014)
          unless @tokens.empty?
            last = @tokens[-1]
            @tokens.clear
            @tokens << last
          end
        end

      end
    end
  end
end
