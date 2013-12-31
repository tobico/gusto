Spec.extend Spec.Report

Spec.describe 'Spec.Report', ->
  subject 'report', -> new Spec.Report()

  describe 'a new report', ->
    it 'has status of passed', ->
      expect(@report.status).to equal Spec.Report.Passed

    it 'has null error', ->
      expect(@report.error).to be null

    it 'has no subreports', ->
      expect(@report.subreports).to equal []

    it 'has all counts at 0', ->
      expect(@report.counts).to equal [0, 0, 0]

  describe '#result', ->
    given 'status',  -> Spec.Report.Failed
    given 'message', -> 'too silly'

    before ->
      @report.result @status, @message

    it 'records result as status', ->
      expect(@report.status).to equal Spec.Report.Failed

    it 'stores error message', ->
      @report.error.should equal @message

    it 'increments count for status', ->
      expect(@report.counts[@status]).to equal 1

  describe '#addSubreport', ->
    given 'subreport', -> new Spec.Report
    given 'status',  -> Spec.Report.Pending
    before ->
      @subreport.result @status
      @report.addSubreport @subreport

    it 'adds subreport to list', ->
      @report.subreports.should equal [@subreport]

    it 'adds subreport counts to report counts', ->
      expect(@report.counts[@status]).to equal 1

    it 'upgrades status to subreport status', ->
      expect(@report.status).to equal @status

