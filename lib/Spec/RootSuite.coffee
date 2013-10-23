class window.Spec.RootSuite extends window.Spec.Suite
  constructor: ->
    super()
    for suite in Spec.suites
      @add suite
  
  run: ->
    super []
