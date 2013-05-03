#= require Spec/Util
#= require Spec/Test
#= require Spec/Suite
#= require Spec/Report
#= require Spec/ObjectExtensions
#= require Spec/SeaweedDSL
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
  EnvironmentInitialized: false
  Suites:                 []
  _extended:              []
  dsl:                    window

  # Executes a test case
  describe: (title, definition) ->
    @initializeEnvironment() unless @EnvironmentInitialized
    suite = new Spec.Suite(title, definition)
    suite.load window
    @Suites.push suite

  # Extends one or more classes with test methods
  extend: ->
    for klass in arguments
      @_extended.push klass
      Spec.Util.extend klass, @ObjectExtensions
      Spec.Util.extend klass.prototype, @ObjectExtensions if klass.prototype

  # Extends the environment with test methods
  initializeEnvironment: ->
    @EnvironmentInitialized = true
    Spec.Util.extend window, @ObjectExtensions, @Matchers, @SeaweedDSL
    @extend Array, Boolean, Date, Element, Function, jQuery, Number, RegExp,
      Spec.MockObject, String

  # Adds &nbsp; indentation to a string
  pad: (string, times) ->
    for i in [1..times]
      string = '&nbsp;' + string
    string

  # Cleans test environment initialized with #initializeEnvironment
  uninitializeEnvironment: ->
    @EnvironmentInitialized = false

    for klass in @_extended
      Spec.Util.unextend klass, @ObjectExtensions

    @_extended.length = 0

    Spec.Util.unextend window, @ObjectExtensions, @Matchers, @SeaweedDSL
