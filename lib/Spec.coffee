window.Spec = {
  EnvironmentInitialized: false
  
  Pad: (string, times) ->
    for i in [1..times]
      string = '&nbsp;' + string
    string
    
  Escape: (string) ->
    $('<div/>').text(String(string)).html()
  
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
    
  finalize: ->
    summary = "#{@counts.passed} passed, #{@counts.failed} failed, #{@counts.pending} pending, #{@counts.total} total"
    switch @Format
      when 'ul'
        document.title = summary
        if @errors.length
          $('<h3>Errors</h3>').appendTo document.body
          ul = $('<ul></ul>').addClass('errors').appendTo(document.body)
          for error in @errors
            ul.append $('<li>').append($('<span>').html(error.message), ' - ', $('<span>').html(error.title))
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
    
    switch @Format
      when 'ul'
        $('body').append('<ul class="results"></ul>')
      when 'terminal'
        $('body').append('<div class="results"></div>')
    
    Object.prototype.should = (matcher) ->
      result = matcher(this)
      Spec.fail "expected #{result[1]}" unless result[0]

    Object.prototype.shouldNot = (matcher) ->
      result = matcher(this)
      Spec.fail "expected not #{result[1]}" if result[0]
      
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
      
    Object.prototype.shouldNotReceive = (name) ->
      @shouldReceive(name).exactly(0).times
    
    window.expect = (object) ->
      {
        to: (matcher) ->
          result = matcher(object)
          Spec.fail "expected #{result[1]}" unless result[0]
        notTo: (matcher) ->
          result = matcher(object)
          Spec.fail "expected not #{result[1]}" if result[0]
      }
      
    window.beforeEach = (action) ->
      test = Spec.testStack[Spec.testStack.length - 1]
      test.before.push action
    
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

    window.it = (title, definition) ->
      test = Spec.testStack[Spec.testStack.length - 1]
      status = if definition?
        env = {sandbox: $('<div/>').appendTo document.body}
        for aTest in Spec.testStack
          for action in aTest.before
            action.call env
      
        Spec.expectations = []
        Spec.testTitle = title
      
        window.onerror = (message) ->
          Spec.fail "Error: #{message}"
      
        Spec.passed = true
        try
          definition.call env
        catch e
          Spec.fail 'Error: ' + e
        
        for expectation in Spec.expectations
          expectation.check()
      
        delete Spec.expectations
        delete Spec.testTitle
        delete window.onerror
        
        env.sandbox.empty().remove()
        
        if Spec.passed then "passed"; else "failed"
      else
        "pending"

      switch Spec.Format
        when 'ul'
          li = $('<li>' + title + '</li>')
          li.addClass status

          test.ul.append li
        when 'terminal'
          s = title
          color = switch status
            when 'passed' then 32
            when 'failed' then 31
            when 'pending' then 33
          $('.results').append Spec.Pad("&#x1b;[#{color}m#{s}&#x1b;[0m<br>", test.ul.depth)
      
      Spec.counts[status]++
      Spec.counts.total++
      
    window.beAFunction = (value) ->
      [typeof value is 'function', "to have type &ldquo;function&rdquo;, actual &ldquo;#{typeof value}&rdquo;"]
    
    window.be = (expected) ->
      (value) ->
        [value is expected, "to be &ldquo;#{Spec.Escape expected}&rdquo;, actual &ldquo;#{Spec.Escape value}&rdquo;"]
          
    window.beTrue = (value) ->
      [String(value) == 'true', "to be true, got &ldquo;#{Spec.Escape value}&rdquo;"]

    window.beFalse = (value) ->
      [String(value) == 'false', "to be false, got &ldquo;#{Spec.Escape value}&rdquo;"]
          
    window.beAnInstanceOf = (klass) ->
      (value) ->
        [value instanceof klass, "to be an instance of &ldquo;#{klass}&rdquo;"]
          
    window.equal = (expected) ->
      (value) ->
        [String(value) == String(expected), "to equal &ldquo;#{Spec.Escape expected}&rdquo;, actual &ldquo;#{Spec.Escape value}&rdquo;"]
    
  fail: (message) ->
    @passed = false
    @error = message
    titles = []
    for item in @testStack
      titles.push item.title
    titles.push @testTitle
    @errors.push {
      title:    titles.join ' '
      message:  message
    }
    
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
    delete window.it
    delete window.beAFunction
    delete window.be
    delete window.beTrue
    delete window.beFalse
    delete window.beAnInstanceOf
    delete window.equal
}