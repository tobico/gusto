window.Spec ||= {}

# A delayed expectation keeps track of an event that is expected to
# occur during the course of a test.
#
# To set a delayed expectation use window.expectation
class window.Spec.DelayedExpectation
  constructor: (@message) ->
    @met = 0
    @desired = 1

  # Specifies that this expectation must be met twice to count
  # as a success.
  twice: ->
    @desired = 2
    this

  # Specifies how many times this expectation should be run to
  # count as a success.
  #
  # Always use this with the format `.exactly(x).times` for better
  # readability.
  exactly: (count) ->
    @desired = count
    {times: this}

  # Call when this expectation has been met.
  meet: ->
    @met += 1

  # Checks if this expecation has been met, and fails the given test
  # unless it's been met the right number of times.
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
