module Gusto
  class CliRenderer
    PASSED = 0
    PENDING = 1
    FAILED = 2

    attr :root_report

    def initialize(root_report)
      @root_report = root_report
    end

    def render
      [body, stack_traces, footer].compact.reject(&:empty?).join("\n\n")
    end

    private

    def body
      root_report['subreports'].map do |subreport|
        report_and_subreport_results subreport
      end.flatten.join "\n"
    end

    def report_and_subreport_results(report)
      [report_result(report)] + report['subreports'].map do |subreport|
        indented_report_and_subreport_results(subreport)
      end.flatten
    end

    def indented_report_and_subreport_results(report)
      report_and_subreport_results(report).map do |result|
        "  #{result}"
      end
    end

    def report_result(report)
      result_color report['status'], report['title']
    end

    def stack_traces
      reports = failures_with_stack_traces(root_report['subreports'])
      reports.each_with_index.map do |report, i|
        result_color(report['status'], "#{i+1}. #{report['title']}") +
          "\n\n" + report['stack']
      end.join("\n\n")
    end

    def failures_with_stack_traces(reports)
      collected = []
      reports.each do |report|
        collected << report if report['status'] == FAILED && report['stack']
        if report['subreports']
          collected += failures_with_stack_traces(report['subreports'])
        end
      end
      collected
    end

    def footer
      result_color root_report['status'], "#{total} total, #{passed} passed, #{pending} pending, #{failed} failed"
    end

    def total
      root_report['counts'].inject(0, &:+)
    end

    def passed
      root_report['counts'][PASSED]
    end

    def pending
      root_report['counts'][PENDING]
    end

    def failed
      root_report['counts'][FAILED]
    end

    def result_color(result, string)
      case result
        when PASSED
          "\e[32m#{string}\e[0m"
        when PENDING
          "\e[33m#{string}\e[0m"
        when FAILED
          "\e[31m#{string}\e[0m"
        else
          string
      end
    end
  end
end
