class window.Spec.Test
  constructor: (@title, @definition) ->

  run: (env) ->
    report = new Spec.Report(@title)
    try
      @definition.call env
      Spec.DelayedExpectation.assert()
      report.result Spec.Report.Passed
    catch error
      report.result(
        error.status || Spec.Report.Failed,
        error.message
      )
      report.location = error.fileName + ':' + error.lineNumber
    finally
      Spec.DelayedExpectation.reset()
      Spec.MethodStub.reset()
    report
