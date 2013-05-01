class window.Spec.Test
  constructor: (@title, @definition) ->

  run: (root, env) ->
    report =
      title:  @title
      status: 'passed'
    try
      @expectations = []
      root.test = this
      @definition.call env
      @_assertExpectations()
    catch error
      report.status = @_errorStatus(error)
      report.error  = error.message
      # report.stack  = printStackTrace()
    report

  _assertExpectations: ->
    for expectation in @expectations
      expectation.assert()

  _errorStatus: (error) ->
    if error instanceof Spec.PendingError
      'pending'
    else
      'failed'
