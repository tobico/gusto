class window.Spec.Suite
  constructor: (@parent, @title, @definition) ->
    @beforeFilters  = []
    @components     = []

  load: (root) ->
    root.suite = this
    @definition()
    root.suite = @parent

  add: (component) ->
    @components.push component

  runBeforeFilters: (env) ->
    @parent.runBeforeFilters(env) if @parent
    for filter in @beforeFilters
      filter.call env

  run: ->
    report = new Spec.Report(@title)

    for component in @components
      if component instanceof Spec.Test
        env = {}
        @runBeforeFilters env
        report.addSubreport component.run(env)
      else
        report.addSubreport component.run()

    report
