window.Spec ||= {}

class window.Spec.MethodStub
  constructor: (@object, @method) ->
    @original = @object[@method]
    @possibleCalls = []
    @_replaceMethodOnObject()

  call: ->
    call = new Spec.MethodStub.PossibleCall(this)
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
        call.call args

    stubMethod._stub = this
    stubMethod

  _findPossibleCall: (args) ->
    for call in @possibleCalls
      break if call.matchesArguments(arguments)
    call

  _replaceMethodOnObject: ->
    @object[@method] = @_stubMethod()

class window.Spec.MethodStub.PossibleCall
  constructor: (@methodStub) ->

  with: (args...) ->
    @arguments = args
    this

  andReturn: (returnValue) ->
    @return = -> returnValue
    this

  andPassthrough: ->
    @return = @methodStub.original

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

  call: (args) ->
    if @matchesArguments(args)
      @expectation.meet() if expectation
      @return.apply @methodStub.object, args if @return
    else
      @_failOnInvalidArguments args
      null
  
  _failOnInvalidArguments: (args) ->
    Spec.fail "expected ##{@method} to be called#{@_argumentsString()}, actual arguments: &ldquo;#{args.join ', '}&rdquo;"

  _argumentsString: ->
    if @arguments
      " with arguments &ldquo;#{@arguments.join ', '}&rdquo;"
    else
      ''
