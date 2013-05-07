class window.Spec.Suite
  constructor: (@title, @definition) ->
    @filters      = []
    @components   = []
    @loaded       = false

  load: ->
    if @definition
      window.__spec_definingSuite = this
      @definition()

      delete window.__spec_definingSuite
    @loaded = true

  add: (component) ->
    @components.push component

  filter: (name, definition) ->
    @filters.push definition

  run: (filters)->
    @load() unless @loaded
    allFilters = filters.concat(@filters)
    report = new Spec.Report(@title)
    report.status = Spec.Report.Pending unless @components.length

    for component in @components
      report.addSubreport component.run(allFilters)

    report
