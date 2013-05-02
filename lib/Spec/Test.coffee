class window.Spec.Test
  constructor: (@title, @definition) ->

  run: (env) ->
    report = new Spec.Report(@title)
    try
      @definition.call env
      Spec.DelayedExpectation.assert()
    catch error
      report.setResult(
        error.status || Spec.Report.Failed,
        error.message
      )
      # report.location = error.fileName + ':' + error.lineNumber
    finally
      Spec.DelayedExpectation.reset()
      Spec.MethodStub.reset()
    report.setResult(Spec.Report.Passed) unless report.result
    report
