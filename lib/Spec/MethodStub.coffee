window.Spec ||= {}

class window.Spec.MethodStub
  constructor: (@test, @object, @method) ->
    @possibleCalls = []
    @_replaceMethodOnObject()

  possibleCall: ->
    call = new Spec.MethodStub.PossibleCall(@test, @original)
    @possibleCalls.unshift call
    call

  _stubMethod: ->
    method = @method
    stubMethod = (args...) ->
      if call = arguments.callee._stub._findPossibleCall(args)
        call.call this, method, args

    stubMethod._stub = this
    stubMethod

  _findPossibleCall: (args) ->
    for call in @possibleCalls
      break if call.matchesArguments(arguments)
    call

  _replaceMethodOnObject: ->
    @original = @object[@method]
    @object[@method] = @_stubMethod()

class window.Spec.MethodStub.PossibleCall
  constructor: (@test, @original) ->

  with: (args...) ->
    @arguments = args
    this

  andReturn: (returnValue) ->
    @return = -> returnValue
    this

  andPassthrough: ->
    @return = @original

  expect: ->
    # TODO: Make this description better, possibly with name of
    # the method that should have been called
    @expectation ||= expectation 'get called'
    this

  twice: ->
    @expectation.twice()
    this

  exactly: (times) ->
    @expectation.exactly times
    {times: this}

  matchesArguments: (args) ->
    if !@arguments
      true
    else if @arguments.length isnt args.length
      false
    else
      @_arraysMatch @arguments, args

  call: (object, method, args) ->
    if @matchesArguments(args)
      @expectation.meet() if @expectation
      @return.apply object, args if @return
    else
      @_failOnInvalidArguments method, args
      null
  
  _arraysMatch: (a, b) ->
    for i in [0..a.length]
      return false if String(a[i]) isnt String(b[i])
    true

  _failOnInvalidArguments: (method, args) ->
    @test.fail "expected ##{method} to be called#{@_argumentsString()}, actual arguments: &ldquo;#{args.join ', '}&rdquo;"

  _argumentsString: ->
    if @arguments
      " with arguments &ldquo;#{@arguments.join ', '}&rdquo;"
    else
      ''
