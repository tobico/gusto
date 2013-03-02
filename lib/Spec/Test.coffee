class window.Spec.Test
  # TODO: Store all of the tests as they're defined, then
  # run them afterward so we can handle errors better
  constructor: (@suite, @title, @definition) ->
    @pending = false
    @failed = false
    @env = {}
    @expectations = []

  run: ->
    # Start error catching; we do this on window instead of using
    # JS error handling because it catches the error on more browsers
    # and gives better debug information
    window.onerror = (message, url, line) =>
      @fail message, "#{url.replace(document.location, '')}:#{line}"
      @finish()

    window.test = this
    @suite.runBeforeFilters @env
    @definition.call @env
    @finish()

  fail: (message, location) ->
    @failed = true

    @reportError
      title:    @fullTitle()
      message:  message
      location: location

  fullTitle: ->
    "#{@suite.fullTitle()} #{@title}"

  result: ->
    if @pending
      'pending'
    else if @failed
      'failed'
    else
      'passed'

  finish: ->
    for expectation in @expectations
      expectation.check this

    window.onerror = -> null
    window.test = null

    @reportResult()

  reportResult: ->
    switch Spec.Format
      when 'ul'
        @suite.ul.append '<li class="' + @result() + '">' + @title + '</li>'
      when 'terminal'
        color = switch @result()
          when 'passed' then 32
          when 'failed' then 31
          when 'pending' then 33
        $('.results').append Spec.pad("&#x1b;[#{color}m#{@title}&#x1b;[0m<br>", @suite.depth)

  reportError: (data) ->
    console.log 'error', data
