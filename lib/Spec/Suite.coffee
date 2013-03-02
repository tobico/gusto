class window.Spec.Suite
  constructor: (@parent, @title, @definition) ->
    @ul = $('<ul></ul>')
    switch Spec.Format
      when 'ul'
        @parentUl().append($("<li>#{@title}</li>").append(@ul))
      when 'terminal'
        $('.results').append(Spec.pad("#{@title}<br>", @parent.depth))
        @depth = @parentDepth() + 1
    
    @beforeFilters = []

  parentUl: ->
    if @parent
      @parent.ul
    else
      $ '.results'

  parentDepth: ->
    if @parent
      @parent.depth
    else
      0

  fullTitle: ->
    if @parent
      "#{@parent.fullTitle()} #{@title}"
    else
      @title

  load: ->
    @definition()

  runBeforeFilters: (env) ->
    @parent.runBeforeFilters(env) if @parent
    for filter in @beforeFilters
      filter.call env
