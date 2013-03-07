class window.Spec.Suite
  constructor: (@parent, @title, @definition) ->
    @beforeFilters  = []
    @suites         = []
    @suiteReports   = []
    @tests          = []
    @testReports    = []
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
      test.run window
      @testReports.push test.report()
      @_updateStatus test.status

    for suite in @suites
      suite.run()
      @suiteReports.push suite.report()
      @_updateStatus suite.status

  _updateStatus: (status) ->
    switch status
      when 'failed'
        @status = 'failed'
      when 'pending'
        @status = 'pending' unless @status is 'failed'

  report: ->
    title:  @title
    status: @status
    tests:  @testReports
    suites: @suiteReports
