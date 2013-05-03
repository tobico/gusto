class window.HtmlReport
  constructor: (element) ->
    @element = element

  run: ->
    root = new Spec.Suite()
    for suite in Spec.Suites
      root.addSuite suite

    @report = root.run()
    @element.innerHTML = @html()

  html: ->
    @resultSummary(@report) + @testResults(@report)

  resultSummary: (report) ->
    "
      <div class=\"result-summary\">
        #{@resultSummaryCount 'total',    report.counts[0] + report.counts[1] + report.counts[2]}
        #{@resultSummaryCount 'passed',   report.counts[0]}
        #{@resultSummaryCount 'pending',  report.counts[1]}
        #{@resultSummaryCount 'failed',   report.counts[2]}
      </div>
    "

  resultSummaryCount: (name, count) ->
    "
      <div class=\"result-summary--count result-summary--#{name}\">
        <span class=\"result-summary--label\">#{name.toUpperCase()}</span>
        <span class=\"result-summary--number\">#{count}</span>
      </div>
    "

  testResults: (report) ->
    "
      <div class=\"test-results\">
        #{@testResultsReports report.subreports}
      </div>
    "

  testResultsReports: (reports) ->
    html = '<ul class=\"test-results--list\">'
    for report in reports
      html += @testResultsReport report
    html + '</ul>'

  testResultsReport: (report) ->
    "
      <li class=\"test-results--test test-results--test--#{@testResultsStatusClass report.status}\">
        <div class=\"test-results--title\">#{report.title}</div>
        #{if report.error then @testResultsErrorReport(report) else ''}
        #{if report.subreports.length then @testResultsReports(report.subreports) else ''}
      </li>
    "

  testResultsErrorReport: (report) ->
    "<div class=\"test-results--error-message\">#{report.error}</div>"

  testResultsStatusClass: (status) ->
    switch status
      when Spec.Report.Passed then 'passed'
      when Spec.Report.Pending then 'pending'
      when Spec.Report.Failed then 'failed'
