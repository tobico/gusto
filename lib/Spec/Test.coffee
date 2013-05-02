class window.Spec.Test
  constructor: (@title, @definition) ->

  run: (root, env) ->
    report =
      title:  @title
      status: 'passed'
    try
      root.test = this
      @definition.call env
      Spec.DelayedExpectation.assert()
    catch error
      report.status   = @_errorStatus(error)
      report.error    = error.message
      report.location = error.fileName + ':' + error.lineNumber
    report

  _errorStatus: (error) ->
    if error instanceof Spec.PendingError
      'pending'
    else
      'failed'
