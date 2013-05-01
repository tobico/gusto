class window.HtmlReport
  constructor: (element) ->
    @element = element

  run: ->
    root = new Spec.Suite()
    for suite in Spec.Suites
      root.addSuite suite
    root.run()
    @report = root.report()
    @element.innerHTML = @html()

  html: ->
    @_resultSummary() + @_testResults()

  _resultSummary: ->
    html = '<header class="result-summary">'
    for count in 'total passed pending failed'.split(' ')
      html += "<div class=\"result-summary--count result-summary--#{count}\">" +
        "<span class=\"result-summary--label\">#{count.toUpperCase()}</span>" +
        "<span class=\"result-summary--number\">#{@report.counts[count]}</span>" +
        '</div>'
    html + '</header>'

  _testResults: ->
    html = '<section class="test-results"><ul class="test-results--list">'
    for suite in @report.suites
      html += @_suiteReport(suite)
    html + '</ul></section>'

  _suiteReport: (report) ->
    if report.counts.total == 1
      @_testReport report, "#{report.title}: #{report.tests[0].title}"
    else if report.counts.total > 1
      html = '<li class="test-results--suite test-results--suite--' + report.status + '">' +
        '<div class="test-results--title">' + report.title + '</div> '
      html += '<ul class="test-results--list">'
      for suite in report.suites
        html += @_suiteReport(suite)
      for test in report.tests
        html += @_testReport(test, test.title)
      html + '</ul></li>'

  _testReport: (test, title) ->
    '<li class="test-results--test test-results--test--' + test.status + '">' +
      '<div class="test-results--title">' + title + '</div>' +
      @_errorReport(test.error) + '</li>'

  _errorReport: (error) ->
    if error?
      '<div class="test-results--error-message">' + error.message + '</div>'
    else
      ''

