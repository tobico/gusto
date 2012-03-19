window.Spec ||= {}
window.Spec.ObjectExtensions = {
  # Tests for a positive match
  should: (matcher) ->
    if typeof matcher is 'function'
      result = matcher(this)
      Spec.fail "expected #{result[1]}" unless result[0]

  # Tests for a negative match
  shouldNot: (matcher) ->
    if typeof matcher is 'function'
      result = matcher(this)
      Spec.fail "expected not #{result[1]}" if result[0]

  # Creates a stub method, with an expectation of no calls
  shouldNotReceive: (name) ->
    @shouldReceive(name).exactly(0).times

  # Creates a stub method with an expectation
  shouldReceive: (name) ->
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
}
