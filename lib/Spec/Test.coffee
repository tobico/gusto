class window.Spec.Test
  constructor: (@title, @definition) ->

  run: (env) ->
    report =
      title:  @title
      status: 'passed'
    try
      @definition.call env
      Spec.DelayedExpectation.assert()
    catch error
      report.status   = @_errorStatus(error)
      report.error    = error.message
      report.location = error.fileName + ':' + error.lineNumber
    finally
      Spec.DelayedExpectation.reset()
      Spec.MethodStub.reset()
    report

  _errorStatus: (error) ->
    if error instanceof Spec.PendingError
      'pending'
    else
      'failed'
