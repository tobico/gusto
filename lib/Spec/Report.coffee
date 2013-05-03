class window.Spec.Report
  @Passed:  0
  @Pending: 1
  @Failed:  2

  constructor: (@title) ->
    @status     = Spec.Report.Passed
    @error      = null
    @subreports = []
    @counts     = [0, 0, 0]

  result: (result, error=null) ->
    @status = result
    @error  = error
    @counts[result]++

  addSubreport: (subreport) ->
    @subreports.push subreport
    @counts[i] += subreport.counts[i] for i in [0..2]
    @_updateStatus(subreport.status)

  _updateStatus: (value) ->
    @status = Math.max(@status, value)
