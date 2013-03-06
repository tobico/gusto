class window.Spec.Test
  # TODO: Store all of the tests as they're defined, then
  # run them afterward so we can handle errors better
  constructor: (@suite, @title, @definition) ->
    @pending = false
    @failed = false
    @env = {}
    @expectations = []

  run: (root) ->
    try
      root.test = this
      @suite.runBeforeFilters @env
      @definition.call @env
      @_checkExpectations()

    catch e
      stack = printStackTrace()
      stack.shift() while stack[0].match /(printStackTrace)/
      @failed = true

      @_reportError
        title:    @fullTitle()
        message:  e.message
        stack:    stack

    finally
      delete root.test = null
      @_reportResult()

  fullTitle: ->
    "#{@suite.fullTitle()} #{@title}"

  result: ->
    if @pending
      'pending'
    else if @failed
      'failed'
    else
      'passed'

  _checkExpectations: ->
    for expectation in @expectations
      expectation.check this

  _reportResult: ->
    switch Spec.Format
      when 'ul'
        @suite.ul.append '<li class="' + @result() + '">' + @title + '</li>'
      when 'terminal'
        color = switch @result()
          when 'passed' then 32
          when 'failed' then 31
          when 'pending' then 33
        $('.results').append Spec.pad("&#x1b;[#{color}m#{@title}&#x1b;[0m<br>", @suite.depth)

  _reportError: (data) ->
    console.log 'error', data
