window.Spec ||= {}

# Replaces a method on an object with a stub method, a fake method which can
# be configured to return predetermined responses, as well as set
# expectations on how it is called.
#
# These are created using window#stub, window#shouldReceive and
# window#shouldNotReceive. You shouldn't need to create one manually.
class window.Spec.MethodStub
  constructor: (@object, @method) ->
    @possibleCalls = []
    @_replaceMethodOnObject()

  # Makes a new PossibleCall and adds it to the list
  possibleCall: ->
    call = new Spec.MethodStub.PossibleCall(@original)
    @possibleCalls.unshift call
    call

  # Generates a new stub method to inject into the object, and sets the
  # _stub property on it to point back to this MethodStub.
  #
  # _stub is used by window#stub to find an existing MethodStub for a method
  # and add more possible calls to it, instead of writing over it with
  # a new MethodStub.
  #
  # The code inside the stub method is the same for each MethodStub, but
  # we create a fresh copy of it so we can assign a unique _stub property.
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
