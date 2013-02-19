window.Spec ||= {}

class window.Spec.MethodStub
  constructor: (@object, @method) ->
    @original = @object[@method]
    @return = null
    @object[@method] = =>
      @received.meet() if @received
      @return.call this, arguments if @return
    @object[@method]._stub = this

  expectCalled: ->
    @received ||= expectation "receive &ldquo;#{name}&rdquo;"
    this

  exactly: (args...) ->
    @received.exactly args...

  with: (expectArgs...) ->
    old = @object[@method]
    @object[@method] = (args...) =>
      old.apply @object, args
      correct = true
      correct = false if expectArgs.length != args.length
      if correct
        for i in [0..args.length]
          correct = false unless String(expectArgs[i]) == String(args[i])
      unless correct
        Spec.fail "expected ##{name} to be called with args &ldquo;#{expectArgs.join ', '}&rdquo;, actual args: &ldquo;#{args.join ', '}&rdquo;"
    this

  andReturn: (returnValue) ->
    @return = -> returnValue
    this

  andPassthrough: ->
    @return = @original
    this
