window.Spec ||= {}

class window.Spec.MethodStub
  constructor: (@object, @method) ->
    @original = @object[@method]
    @possibleCalls = []
    @_replaceMethodOnObject()

  call: ->
    call = new Spec.MethodStub.PossibleCall()
    @possibleCalls.push call
    call

  exactly: (args...) ->
    @received.exactly args...

  with: (args...) ->
    @call().with args...

  andReturn: (result) ->
    @call().andReturn result

  _stubMethod: ->
    stubMethod = (args...) =>
      if call = @_findPossibleCall(args)
        result = call.call args
        if result is Spec.MethodStub.PossibleCall.PASSTHROUGH
          @original args
        else
          result
      else if @possibleCalls.length
        Spec.fail "expected ##{@method} to be called#{@possibleCalls[0].argumentsString()}, actual arguments: &ldquo;#{args.join ', '}&rdquo;"
        null

    stubMethod._stub = this
    stubMethod

  _findPossibleCall: (args) ->
    for call in @possibleCalls
      if call.matchesArguments(arguments)
        return call
    false

  _replaceMethodOnObject: ->
    @object[@method] = @_stubMethod()

class window.Spec.MethodStub.PossibleCall
  PASSTHROUGH: {}

  with: (args...) ->
    @arguments = args
    this

  andReturn: (returnValue) ->
    @return = returnValue
    this

  andPassthrough: ->
    @return = Spec.MethodStub.PossibleCall.PASSTHROUGH
    this

  expect: ->
    # TODO: Make this description better, possibly with name of
    # the method that should have been called
    @expectation ||= expectation 'called'
    this

  twice: ->
    @expectation.twice()
    this

  exactly: (times) ->
    @expectation.exactly times
    {times: this}

  matchesArguments: (args) ->
    if @arguments
      if @arguments.length isnt args.length
        false
      else
        for i in [0..args.length]
          return false unless String(args[i]) == String(@arguments[i])
    else
      true

  argumentsString: ->
    if @arguments
      " with arguments &ldquo;#{@arguments.join ', '}&rdquo;"
    else
      ''

  call: (args) ->
    @expectation.meet() if expectation
    @return
