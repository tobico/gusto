# Seaweed Coffeescript spec framework
window.Spec = {
  EnvironmentInitialized: false
  
  # Adds &nbsp; indentation to a string
  Pad: (string, times) ->
    for i in [1..times]
      string = '&nbsp;' + string
    string
  
  # Escapes text for HTML
  Escape: (string) ->
    $('<div/>').text(String(string)).html()
  
  Display: (object) ->
    if object instanceof Array
      s = '['
      first = true
      for item in object
        if first
          first = false
        else
          first += ', '
        s += '&ldquo;' + @Escape(String(item)) + '&rdquo;'
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
        if object.hasOwnProperty key
          if first
            first = false
          else
            s += ", "
          s += @Escape(key) + ': &ldquo;' + @Escape(String(object[key])) + '&rdquo;'
      s + "}"
    else
      "&ldquo;#{@Escape(object)}&rdquo;"
  
  # Executes a test case
  describe: (title, definition) ->
    @initializeEnvironment() unless @EnvironmentInitialized

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
  
  # Extends the environment with test methods
  initializeEnvironment: ->
    @EnvironmentInitialized = true
    
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
    
    # Tests for a positive match
    Object.prototype.should = (matcher) ->
      if typeof matcher is 'function'
        result = matcher(this)
        Spec.fail "expected #{result[1]}" unless result[0]

    # Tests for a negative match
    Object.prototype.shouldNot = (matcher) ->
      if typeof matcher is 'function'
        result = matcher(this)
        Spec.fail "expected not #{result[1]}" if result[0]
    
    # Sets up an expectation
    window.expectation = (message) ->
      exp = {
        message:      message
        meet:         -> @met++
        met:          0
        desired:      1
        twice:        ->
          @desired = 2
          this
        exactly:      (times) ->
          @desired = times
          {times: this}
        timesString:  (times) ->
          switch times
            when 0
              'not at all'
            when 1
              'once'
            when 2
              'twice'
            else
              "#{times} times"
        check:        ->
          if @met != @desired
            Spec.fail "expected #{message} #{@timesString @desired}, actually received #{@timesString @met}"
      }
      Spec.expectations.push exp
      exp
    
    # Creates a stub method with an expectation
    Object.prototype.shouldReceive = (name) ->
      object = this

      received = expectation "to receive &ldquo;#{name}&rdquo;"

      passthrough = object[name]
      object[name] = -> received.meet()

      received.with = (expectArgs...) ->
        object[name] = (args...) ->
          received.meet()
          correct = true
          correct = false if expectArgs.length != args.length
          if correct
            for i in [0..args.length]
              correct = false unless String(expectArgs[i]) == String(args[i])
          unless correct
            Spec.fail "expected ##{name} to be called with arguments &ldquo;#{expectArgs.join ', '}&rdquo;, actual arguments: &ldquo;#{args.join ', '}&rdquo;"
        received

      received.andReturn = (returnValue) ->
        fn = object[name]
        object[name] = ->
          fn.apply this, arguments
          returnValue
        received
      
      received.andPassthrough = ->
        fn = object[name]
        object[name] = ->
          fn.apply this, arguments
          passthrough.apply this, arguments
        received

      received
    
    # Creates a stub method, with an expectation of no calls
    Object.prototype.shouldNotReceive = (name) ->
      @shouldReceive(name).exactly(0).times
    
    # Allows an assertion on a non-object value
    window.expect = (object) ->
      {
        to: (matcher) ->
          result = matcher(object)
          Spec.fail "expected #{result[1]}" unless result[0]
        notTo: (matcher) ->
          result = matcher(object)
          Spec.fail "expected not #{result[1]}" if result[0]
      }
    
    # Adds a setup step to the current test case
    window.beforeEach = (action) ->
      test = Spec.testStack[Spec.testStack.length - 1]
      test.before.push action
    
    # Prepares a sub-test of the current test case
    window.describe = window.context = (title, definition) ->
      parent = Spec.testStack[Spec.testStack.length - 1]
    
      ul = $('<ul></ul>')
      switch Spec.Format
        when 'ul'
          parent.ul.append($('<li>' + title + '</li>').append(ul))
        when 'terminal'
          $('.results').append(Spec.Pad(title, parent.ul.depth) + "<br>")
          ul.depth = parent.ul.depth + 2
    
      Spec.testStack.push {
        title:    title
        ul:       ul
        before:   []
      }
      definition()
      Spec.testStack.pop()
    
    window.reportTestResult = (status) ->
      test = Spec.testStack[Spec.testStack.length - 1]

      switch Spec.Format
        when 'ul'
          test.ul.append '<li class="' + status + '">' + Spec.testTitle + '</li>'
        when 'terminal'
          s = Spec.testTitle
          color = switch status
            when 'passed' then 32
            when 'failed' then 31
            when 'pending' then 33
          $('.results').append Spec.Pad("&#x1b;[#{color}m#{s}&#x1b;[0m<br>", test.ul.depth)

      Spec.counts[status]++
      Spec.counts.total++
    
    window.finishTest = ->
      for expectation in Spec.expectations
        expectation.check()

      reportTestResult(if Spec.passed then "passed" else "failed")

      delete Spec.expectations
      delete Spec.testTitle
      window.onerror = -> null
  
      Spec.env.sandbox.empty().remove()

    # Creates a specificaition
    window.it = (title, definition) ->
      test = Spec.testStack[Spec.testStack.length - 1]
      if definition?
        Spec.env = {sandbox: $('<div/>').appendTo document.body}
        for aTest in Spec.testStack
          for action in aTest.before
            action.call Spec.env

        Spec.expectations = []
        Spec.testTitle = title

        window.onerror = (message, url, line) ->
          Spec.fail message, "#{url.replace(document.location, '')}:#{line}"
          Spec.passed = false
          finishTest()
        
        Spec.passed = true
        definition.call Spec.env        
        finishTest()
      else
        reportTestResult "pending"
    
    # Tests if matched value is a function
    window.beAFunction = (value) ->
      [typeof value is 'function', "to have type &ldquo;function&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]

    # Tests if matched value is a string
    window.beAString = (value) ->
      [typeof value is 'string', "to have type &ldquo;string&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]
    
    # Tests if matched value is a number
    window.beANumber = (value) ->
      [typeof value is 'number', "to have type &ldquo;number&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]
    
    # Tests if matched value is a boolean
    window.beABoolean = (value) ->
      [typeof value is 'boolean', "to have type &ldquo;boolean&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]
    
    # Tests if matched value is an object
    window.beAnObject = (value) ->
      [typeof value is 'object', "to have type &ldquo;object&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]
    
    # Tests if matched value === expected value
    window.be = (expected) ->
      (value) ->
        [value is expected, "to be #{Spec.Display expected}, actual #{Spec.Display value}"]
    
    # Tests if matched value is boolean true
    window.beTrue = (value) ->
      [String(value) == 'true', "to be true, got #{Spec.Display value}"]
    
    # Tests if matched value is boolean false
    window.beFalse = (value) ->
      [String(value) == 'false', "to be false, got #{Spec.Display value}"]
    
    # Tests if matched value is an instance of class
    window.beAnInstanceOf = (klass) ->
      (value) ->
        [value instanceof klass, "to be an instance of &ldquo;#{klass}&rdquo;"]
    
    # Tests if matched value == expected value
    window.equal = (expected) ->
      (value) ->
        [String(value) == String(expected), "to equal #{Spec.Display String(expected)}, actual #{Spec.Display String(value)}"]
    
    # All-purpose inclusion matcher
    window.include = (expected) ->
      if expected instanceof Array
        (value) ->
          match = true
          for test in expected
            match = false unless (value.indexOf && value.indexOf(test) >= 0) || value[test]?
          [match, "to include #{Spec.Display expected}, actual #{Spec.Display value}"]
      else if typeof expected == 'object'
        (value) ->
          missing = {}
          match = true
          for test of expected
            if expected.hasOwnProperty test
              unless value[test] isnt undefined && String(value[test]) == String(expected[test])
                match = false
                missing[test] = expected[test]
          [match, "to include #{Spec.Display expected}, actual #{Spec.Display value}, missing #{Spec.Display missing}"]
      else
        include([expected])
  
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
  
  # Cleans test environment initialized with #initializeEnvironment
  uninitializeEnvironment: ->
    @EnvironmentInitialized = false
    
    delete Object.prototype.should
    delete Object.prototype.shouldNot
    delete window.expectation
    delete Object.prototype.shouldReceive
    delete Object.prototype.shouldNotReceive
    delete window.expect
    delete window.beforeEach
    delete window.describe
    delete window.context
    delete window.reportTestResult
    delete window.finishTest
    delete window.it
    delete window.beAFunction
    delete window.beAString
    delete window.beANumber
    delete window.beABoolean
    delete window.beAnObject
    delete window.beTrue
    delete window.beFalse
    delete window.beAnInstanceOf
    delete window.equal
    delete window.include
}