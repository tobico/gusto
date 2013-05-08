window.Spec ||= {}

class window.Spec.Mock
  constructor: (@name, stubs) ->
    for name, value of stubs
      @stub(name).andReturn(value)

  toString: ->
    "[#{@name} Mock]"
