class HtmlReport
  constructor: ->
    root = new Spec.Suite()
    for suite in Spec.Suites
      root.addSuite suite
    root.run()
    @report = root.report()

    @html = '<header>' +
      '<div id="total-count">' + @report.counts.total + '</div>' +
      '<div id="passed-count">' + @report.counts.passed + '</div>' +
      '<div id="pending-count">' + @report.counts.pending + '</div>' +
      '<div id="failed-count">' + @report.counts.failed + '</div>' +
      '</header>'
    @html += '<section><ul>'
    for suite in @report.suites
      @_renderSuiteReport(suite)
    @html += '</ul></section>'

  _renderSuiteReport: (report) ->
    if report.counts.total == 1
      @html += '<li class="' + report.status + '">' + 
      '<div class="title">' + report.title + ': ' +
      report.tests[0].title + '</div></li>'
    else
      @html += '<li class="suite ' + report.status + '">' + 
        '<div class="title">' + report.title + '</div> '
      if report.counts.total > 1
        @html += '<div class="count">' + report.counts.total + '</div>'
      if report.tests.length || report.suites.length
        @html += '<ul>'
        for suite in report.suites
          @_renderSuiteReport suite
        for test in report.tests
          @_renderTestReport test
        @html += '</ul>'
      @html += '</li>'

  _renderTestReport: (report) ->
    @html += '<li class="' + report.status + '">' + 
      '<div class="title">' + report.title + '</div></li>'

report = new HtmlReport()
$('body').html report.html