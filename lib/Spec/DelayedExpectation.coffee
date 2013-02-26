window.Spec ||= {}

class window.Spec.DelayedExpectation
  constructor: (@message) ->
    @met = 0
    @desired = 1

  twice: ->
    @desired = 2
    this

  exactly: (count) ->
    @desired = count
    {times: this}

  meet: ->
    @met += 1

  check: (test) ->
    unless @met is @desired
      test.fail "expected to #{@message} #{@_timesString @desired}, actually happened #{@_timesString @met}"

  _timesString: (times) ->
    switch times
      when 0
        'not at all'
      when 1
        'once'
      when 2
        'twice'
      else
        "#{times} times"
