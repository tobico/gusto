class window.Spec.Suite
  constructor: (@parent, @title, @definition) ->
    @beforeFilters  = []
    @suites         = []
    @tests          = []
    @suiteReports   = []
    @testReports    = []
    @counts         =
      total:    0
      passed:   0
      pending:  0
      failed:   0
    @status         = 'passed'

  load: (root) ->
    root.suite = this
    @definition()
    root.suite = @parent

  addTest: (test) ->
    @tests.push test

  addSuite: (suite) ->
    @suites.push suite

  runBeforeFilters: (env) ->
    @parent.runBeforeFilters(env) if @parent
    for filter in @beforeFilters
      filter.call env

  run: ->
    for test in @tests
      @runBeforeFilters test.env
      report = test.run(window, test.env)
      @testReports.push report
      @_updateStatus report.status
      @counts.total   += 1
      @counts.passed  += 1 if report.status is 'passed'
      @counts.pending += 1 if report.status is 'pending'
      @counts.failed  += 1 if report.status is 'failed'

    for suite in @suites
      suite.run()
      @suiteReports.push suite.report()
      @_updateStatus suite.status
      @counts.total   += suite.counts.total
      @counts.passed  += suite.counts.passed
      @counts.pending += suite.counts.pending
      @counts.failed  += suite.counts.failed

  _updateStatus: (status) ->
    switch status
      when 'failed'
        @status = 'failed'
      when 'pending'
        @status = 'pending' unless @status is 'failed'

  report: ->
    title:  @title
    status: @status
    counts: @counts
    tests:  @testReports
    suites: @suiteReports
