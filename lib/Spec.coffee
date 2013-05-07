#= require Spec/Util
#= require Spec/Test
#= require Spec/Suite
#= require Spec/Report
#= require Spec/ObjectDSL
#= require Spec/DSL
#= require Spec/Matchers
#= require Spec/MethodStub
#= require Spec/MethodStub/PossibleCall
#= require Spec/DelayedExpectation
#= require Spec/MockObject

# Seaweed Coffeescript spec framework

window.Spec ||= {}

class window.Spec.ExpectationError
  constructor: (@message) ->

class window.Spec.PendingError
  constructor: (@message) ->
    @status = Spec.Report.Pending

Spec.Util.extend window.Spec,
  environmentExtended:  false
  suites:               []
  root:                 window

  # Executes a test case
  describe: (title, definition) ->
    @extendEnvironment() unless @environmentExtended
    suite = new Spec.Suite(title, definition)
    suite.load window
    @suites.push suite

  # Extends a class or instance with object DSL
  extend: (objects...) ->
    for object in objects
      Spec.Util.extend object, Spec.ObjectDSL
      Spec.Util.extend object.prototype, Spec.ObjectDSL if object.prototype

  # Extends the environment with test methods
  extendEnvironment: ->
    @environmentExtended = true
    Spec.Util.extend(@root,
      Spec.DSL,
      Spec.Matchers
    )
    @extend(
      Array,
      Boolean,
      Date,
      Function,
      Number,
      RegExp,
      String,
      Element,
      jQuery,
      Spec.MockObject
    )
