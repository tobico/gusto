class window.Spec.Test
  constructor: (@title, @definition) ->
    @status         = 'passed'
    @error          = null
    @env            = {}
    @expectations   = []

  run: (root) ->
    try
      root.test = this
      @definition.call @env
      @_checkExpectations()
    catch e
      @status = 'failed'
      @error =
        message:  e.message
        stack:    printStackTrace()
    finally
      root.test = null

  pending: ->
    @status = 'pending'

  report: ->
    title:  @title
    status: @status
    error:  @error

  _checkExpectations: ->
    for expectation in @expectations
      expectation.check this
