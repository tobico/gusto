class HtmlReport
  constructor: ->
    root = new Spec.Suite()
    for suite in Spec.Suites
      root.addSuite suite
    root.run()
    @report = root.report()

    @html = '<header class="result-summary">'
    
    for count in 'total passed pending failed'.split(' ')
      @html += "<div class=\"result-summary--count result-summary--#{count}\">" +
        "<span class=\"result-summary--label\">#{count.toUpperCase()}</span>" +
        "<span class=\"result-summary--number\">#{@report.counts[count]}</span>" +
        '</div>'

    @html += '</header><section><ul>'
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