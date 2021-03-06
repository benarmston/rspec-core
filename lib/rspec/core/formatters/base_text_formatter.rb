module RSpec

  module Core

    module Formatters

      class BaseTextFormatter < BaseFormatter

        def dump_failures
          output.puts
          failed_examples.each_with_index do |failed_example, index|
            exception = failed_example.execution_result[:exception_encountered]
            padding = '    '
            if exception.is_a?(RSpec::Core::PendingExampleFixedError)
              output.puts "#{index.next}) #{failed_example} FIXED"
              output.puts "#{padding}Expected pending '#{failed_example.metadata[:execution_result][:pending_message]}' to fail. No Error was raised."
            else
              output.puts "#{index.next}) #{failed_example}"
              output.puts "#{padding}Failure/Error: #{read_failed_line(exception, failed_example).strip}"
              exception.message.split("\n").each do |line|
                output.puts "#{padding}#{colorise(line, exception)}"
              end
            end

            format_backtrace(exception.backtrace, failed_example).each do |backtrace_info|
              output.puts grey("#{padding}# #{backtrace_info}")
            end

            output.puts 
            output.flush
          end
        end

        def colorise(s, failure)
          red(s)
        end
        
        def dump_summary
          failure_count = failed_examples.size
          pending_count = pending_examples.size
          

            output.puts "\nFinished in #{format_seconds(duration)} seconds\n"

          summary = summary_line(example_count, failure_count, pending_count)

          if failure_count == 0
            if pending_count > 0
              output.puts yellow(summary)
            else
              output.puts green(summary)
            end
          else
            output.puts red(summary)
          end

          # Don't print out profiled info if there are failures, it just clutters the output
          if profile_examples? && failure_count == 0
            sorted_examples = examples.sort_by { |example| example.execution_result[:run_time] }.reverse.first(10)
            output.puts "\nTop #{sorted_examples.size} slowest examples:\n"        
            sorted_examples.each do |example|
              output.puts "  (#{format_seconds(example.execution_result[:run_time])} seconds) #{example}"
              output.puts grey("   # #{format_caller(example.metadata[:location])}")
            end
          end

          output.flush
        end

        def summary_line(example_count, failure_count, pending_count)
          summary = pluralize(example_count, "example")
          summary << ", " << pluralize(failure_count, "failure")
          summary << ", #{pending_count} pending" if pending_count > 0  
          summary
        end

        def pluralize(count, string)
          "#{count} #{string}#{'s' unless count == 1}"
        end

        def format_caller(caller_info)
          caller_info.to_s.split(':in `block').first
        end

        def dump_pending
          unless pending_examples.empty?
            output.puts
            output.puts "Pending:"
            pending_examples.each do |pending_example|
              output.puts "  #{pending_example} (#{pending_example.metadata[:execution_result][:pending_message]})"
              output.puts grey("   # #{format_caller(pending_example.metadata[:location])}")
            end
          end
          output.flush
        end

        def close
          if IO === output && output != $stdout
            output.close 
          end
        end

        protected

        def color(text, color_code)
          return text unless color_enabled?
          "#{color_code}#{text}\e[0m"
        end

        def bold(text)
          color(text, "\e[1m")
        end

        def white(text)
          color(text, "\e[37m")
        end

        def green(text)
          color(text, "\e[32m")
        end

        def red(text)
          color(text, "\e[31m")
        end

        def magenta(text)
          color(text, "\e[35m")
        end

        def yellow(text)
          color(text, "\e[33m")
        end

        def blue(text)
          color(text, "\e[34m")
        end

        def grey(text)
          color(text, "\e[90m")
        end

      end

    end

  end

end
