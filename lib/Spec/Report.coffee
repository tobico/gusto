class window.Spec.Report
  @Passed:  0
  @Pending: 1
  @Failed:  2

  constructor: (@title) ->
    @status     = Spec.Passed
    @counts     = [0, 0, 0]
    @subreports = []
    @result     = null
    @error      = null

  setResult: (result, error=null) ->
    throw "can't set result twice" if @result?
    @result = result
    @error  = error
    @counts[result]++
    @_updateStatus(result)

  addSubreport: (report) ->
    @subreports.push report
    @counts[i] += report.counts[i] for i in [0..2]
    @_updateStatus(report.status)

  _updateStatus: (value) ->
    @status = value if value > @status
