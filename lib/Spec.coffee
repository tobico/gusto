#= require Spec/Util
#= require Spec/Test
#= require Spec/Suite
#= require Spec/ObjectExtensions
#= require Spec/SeaweedDSL
#= require Spec/Matchers
#= require Spec/MethodStub
#= require Spec/DelayedExpectation
#= require Spec/MockObject

# Seaweed Coffeescript spec framework

window.Spec ||= {}

class window.Spec.ExpectationError
  constructor: (@message) ->

Spec.Util.extend window.Spec,
  EnvironmentInitialized: false
  _extended: []
  
  dsl: window
  
  # Executes a test case
  describe: (title, definition) ->
    @initializeEnvironment() unless @EnvironmentInitialized
    suite = new Spec.Suite(null, title, definition)
    suite.load window
    suite.run()
    console.log suite.report()
  
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

    @Format = 'ul'
    @Format = 'terminal' if location.hash == '#terminal'

    # Add results display element to the page
    switch @Format
      when 'ul'
        $('body').append('<ul class="results"></ul>')
      when 'terminal'
        $('body').append('<div class="results"></div>')

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
