class window.Spec.Suite
  constructor: (@parent, @title, @definition) ->
    @beforeFilters  = []
    @suites         = []
    @tests          = []

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
    report = new Spec.Report(@title)

    for test in @tests
      @runBeforeFilters test.env
      report.addSubreport test.run(test.env)

    for suite in @suites
      report.addSubreport suite.run()
    report
