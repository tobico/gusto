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

Spec.Util.extend window.Spec,
  EnvironmentInitialized: false
  _extended: []
  
  dsl: window
  
  # Executes a test case
  describe: (title, definition) ->
    @initializeEnvironment() unless @EnvironmentInitialized

    @dsl.describe title, definition
  
  # Extends one or more classes with test methods
  extend: ->
    for klass in arguments
      @_extended.push klass
      Spec.Util.extend klass, @ObjectExtensions
      Spec.Util.extend klass.prototype, @ObjectExtensions if klass.prototype

  # TODO: Refactor this into a test reporter
  #  
  # Displays a summary of error rate at the end of testing
  #
  # finalize: ->
  #   summary = "#{@counts.passed} passed, #{@counts.failed} failed, #{@counts.pending} pending, #{@counts.total} total"
  #   switch @Format
  #     when 'ul'
  #       document.title = summary
  #       if @errors.length
  #         $('<h3>Errors</h3>').appendTo document.body
  #         html = ['<table class="errors"><thead><tr><th>Error</th><th>Location</th><th>Test</th></tr></thead><tbody>']
  #         for error in @errors
  #           html.push '<tr><td>', error.message, '</td><td>', error.location, '</td><td>', error.title, '</td></tr>'
  #         html.push '</tbody></table>'
  #         $(document.body).append html.join('')
  #     when 'terminal'
  #       $('.results').append "<br>"
  #       for error in @errors
  #         message = error.message
  #         message = message.replace '<ins>', '&#x1b;[4;32m'
  #         message = message.replace '</ins>', '&#x1b;[0;31m'
  #         message = message.replace '<del>', '&#x1b;[7m'
  #         message = message.replace '</del>', '&#x1b;[0m'
  #         $('.results').append "&#x1b;[31m#{message}&#x1b;[0m #{error.title}<br>"
  #       color = if @counts.failed > 0
  #         31
  #       else if @counts.pending > 0
  #         33
  #       else
  #         32
  #       $('.results').append "&#x1b;[1m&#x1b;[#{color}m#{summary}&#x1b;[0m<br>"
  
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
