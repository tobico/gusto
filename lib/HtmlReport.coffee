class window.HtmlReport
  constructor: (element) ->
    @element = element

  run: ->
    @report = (new Spec.RootSuite()).run()
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
    html = "<li class=\"test-results--test test-results--test--#{@testResultsStatusClass report.status}\">"
    html += "<div class=\"test-results--title\">#{report.title}</div>"
    if report.error
      html += @testResultsErrorReport(report)
      if report.status == Spec.Report.Failed
        html += @testResultsErrorDetails(report)
    if report.subreports.length
      html += @testResultsReports(report.subreports)
    html += "</li>"
    html

  testResultsErrorReport: (report) ->
    "<div class=\"test-results--error-message\">#{Spec.Util.escape report.error}</div>"

  testResultsErrorDetails: (report) ->
    details = "<div class=\"test-results--error-details\">"
    details += "<div class=\"test-results--full-error-message\">#{report.htmlMessage || Spec.Util.escape(report.error)}</div>"
    if report.stack
      details += "<pre class=\"test-results--stack-trace\">#{Spec.Util.escape report.stack}</pre>"
    details += "</div>"
    details

  testResultsStatusClass: (status) ->
    switch status
      when Spec.Report.Passed then 'passed'
      when Spec.Report.Pending then 'pending'
      when Spec.Report.Failed then 'failed'
