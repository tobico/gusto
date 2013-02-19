#= require Spec/ObjectExtensions
#= require Spec/WindowExtensions
#= require Spec/MethodStub

# Seaweed Coffeescript spec framework

window.Spec ||= {}

$.extend window.Spec,
  EnvironmentInitialized: false
  _extended: []

  # Executes a test case
  describe: (title, definition) ->
    @initializeEnvironment() unless @EnvironmentInitialized

    if definition?
      ul = $('<ul></ul>')
      switch @Format
        when 'ul'
          $('.results').append($('<li>' + title + '</li>').append(ul))
        when 'terminal'
          $('.results').append "#{title}<br>"
          ul.depth = 2
      
      @testStack = [{
        title:    title
        ul:       ul
        before:   []
      }]
      
      definition()
    else
      @reportTestResult "pending"
  
  # Tries to format definition source code as readable test description
  descriptionize: (definition) ->
    # Get function source code
    definition = String definition
    
    # Remove function boilerplate from beginning
    definition = definition.replace(/^\s*function\s*\([^\)]*\)\s*\{\s*(return\s*)?/, '')
    
    # Remove function boilerplate from end
    definition = definition.replace(/\s*;\s*\}\s*$/, '')
    
    # Replace symbols with whitespace
    definition = definition.replace(/[\s\(\)_\-\.'"]+/g, ' ')
    
    # Split camelCased terms into seperate words
    definition = definition.replace(/([a-z])([A-Z])/g, (s, a, b) -> "#{a} #{b.toLowerCase()}")
    
    definition
  
  # Escapes text for HTML
  escape: (string) ->
    $('<div/>').text(String(string)).html()
  
  # Extends a one or more classes with test methods
  extend: () ->
    for klass in arguments
      @_extended.push klass
      $.extend klass, @ObjectExtensions
      $.extend klass.prototype, @ObjectExtensions if klass.prototype
  
  # Fails test, with an error message
  fail: (message, location) ->
    @passed = false
    @error = message
    titles = []
    for item in @testStack
      titles.push item.title
    titles.push @testTitle
    @errors.push {
      title:    titles.join ' '
      message:  message
      location: location
    }
  
  # Displays a summary of error rate at the end of testing
  finalize: ->
    summary = "#{@counts.passed} passed, #{@counts.failed} failed, #{@counts.pending} pending, #{@counts.total} total"
    switch @Format
      when 'ul'
        document.title = summary
        if @errors.length
          $('<h3>Errors</h3>').appendTo document.body

          html = ['<table class="errors"><thead><tr><th>Error</th><th>Location</th><th>Test</th></tr></thead><tbody>']
          for error in @errors
            html.push '<tr><td>', error.message, '</td><td>', error.location, '</td><td>', error.title, '</td></tr>'
          html.push '</tbody></table>'
          $(document.body).append html.join('')
      when 'terminal'
        $('.results').append "<br>"
        for error in @errors
          $('.results').append "&#x1b;[31m#{error.message}&#x1b;[0m #{error.title}<br>"
        color = if @counts.failed > 0
          31
        else if @counts.pending > 0
          33
        else
          32
        $('.results').append "&#x1b;[1m&#x1b;[#{color}m#{summary}&#x1b;[0m<br>"
  
  # Finds a matcher specified by a string, or passes through a matcher
  # specified directly.
  findMatcher: (value) ->
    if typeof value is 'string'
      if found = value.match(/^be([A-Z]\w*)$/)
        beAttribute found[1].replace(/^[A-Z]/, (s) -> s.toLowerCase())
      else if window[value]
        window[value]
      else
        null
    else
      value
  
  # Extends the environment with test methods
  initializeEnvironment: ->
    @EnvironmentInitialized = true

    $.extend window, @WindowExtensions, @ObjectExtensions

    @errors = []
    @counts = {
      passed:   0
      failed:   0
      pending:  0
      total:    0
    }

    @Format = 'ul'
    @Format = 'terminal' if location.hash == '#terminal'

    # Add results display element to the page
    switch @Format
      when 'ul'
        $('body').append('<ul class="results"></ul>')
      when 'terminal'
        $('body').append('<div class="results"></div>')

    @extend Array, Boolean, Date, Element, Function, jQuery, Number, RegExp,
      SpecObject, String
  
  # Returns an HTML representation of any kind of object
  inspect: (object) ->
    if object instanceof Array
      s = '['
      first = true
      for item in object
        if first
          first = false
        else
          first += ', '
        s += '&ldquo;' + @escape(String(item)) + '&rdquo;'
      s + ']'
    else if object is null
      'null'
    else if object is undefined
      'undefined'
    else if object is true
      'true'
    else if object is false
      'false'
    else if typeof object == 'object'
      s = "{"
      first = true
      for key of object
        # Access hasOwnProperty through Object.prototype to work around bug
        # in IE6/7/8 when calling hasOwnProperty on a DOM element
        if Object.prototype.hasOwnProperty.call(object, key)
          if first
            first = false
          else
            s += ", "
          s += @escape(key) + ': &ldquo;' + @escape(String(object[key])) + '&rdquo;'
      s + "}"
    else
      "&ldquo;#{@escape(object)}&rdquo;"
  
  # Adds &nbsp; indentation to a string
  pad: (string, times) ->
    for i in [1..times]
      string = '&nbsp;' + string
    string
    
  # Cleans test environment initialized with #initializeEnvironment
  uninitializeEnvironment: ->
    @EnvironmentInitialized = false
    
    for klass in @_extended
      for key of @ObjectExtensions
        delete klass[key]
        delete klass.prototype[key] if klass.prototype
    
    @_extended.length = 0
    
    for key of @WindowExtensions
      delete window[key]

    for key of @ObjectExtensions
        delete window[key]

  reportTestResult: (status) ->
    test = @testStack[@testStack.length - 1]

    switch @Format
      when 'ul'
        test.ul.append '<li class="' + status + '">' + @testTitle + '</li>'
      when 'terminal'
        s = @testTitle
        color = switch status
          when 'passed' then 32
          when 'failed' then 31
          when 'pending' then 33
        $('.results').append @pad("&#x1b;[#{color}m#{s}&#x1b;[0m<br>", test.ul.depth)

    @counts[status]++
    @counts.total++
