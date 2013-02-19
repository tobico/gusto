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
    @received ||= expectation "to receive &ldquo;#{name}&rdquo;"
    this

  with: (expectArgs...) ->
    old = @object[@method]
    @object[@method] = =>
      old.apply @object, arguments
      correct = true
      correct = false if expectArgs.length != arguments.length
      if correct
        for i in [0..arguments.length]
          correct = false unless String(expectArgs[i]) == String(arguments[i])
      unless correct
        Spec.fail "expected ##{name} to be called with arguments &ldquo;#{expectArgs.join ', '}&rdquo;, actual arguments: &ldquo;#{args.join ', '}&rdquo;"
    this

  andReturn: (returnValue) ->
    @return = -> returnValue
    this

  andPassthrough: ->
    @return = @original
    this
