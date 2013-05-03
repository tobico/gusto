class window.Spec.Suite
  constructor: (@parent, @title, @definition) ->
    @filters      = []
    @components   = []

  load: (root) ->
    temp = root.suite
    root.suite = this
    @definition()
    root.suite = temp

  add: (component) ->
    @components.push component

  filter: (name, definition) ->
    @filters.push definition

  runBeforeFilters: (env) ->
    @parent.runBeforeFilters(env) if @parent
    for filter in @beforeFilters
      filter.call env

  run: (filters)->
    allFilters = filters.concat(@filters)
    report = new Spec.Report(@title)

    for component in @components
      report.addSubreport component.run(allFilters)

    report
