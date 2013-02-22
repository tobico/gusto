window.Spec ||= {}

class window.Spec.MockObject
  constructor: (@name, stubs) ->
    for name, value of stubs
      @stub(name).andReturn(value)
