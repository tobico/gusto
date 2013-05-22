window.Spec ||= {}

window.Spec.Util =
  # Extends one object with all properties from one or more other objects.
  # This differs from extend methods in frameworks like jQuery and Underscore
  # in that it will not overwrite properties that already exist
  extend: (object, extensions...) ->
    for extension in extensions
      for key, value of extension
        object[key] ||= value
    object

  reference: (value) ->
    if typeof value is 'function'
      value
    else
      -> value

  dereference: (value, context) ->
    if typeof value is 'function'
      value.call context
    else
      value

  # Tries to format definition source code as readable test description
  descriptionize: (definition) ->
    # Get function source code
    definition = String definition

    # Remove function boilerplate from beginning
    definition = definition.replace(/^\s*function\s*\([^\)]*\)\s*\{\s*(return\s*)?/, '')

    # Remove function boilerplate from end
    definition = definition.replace(/\s*;\s*\}\s*$/, '')

    # Replace symbols with whitespace
    definition = definition.replace(/[\s\(\)\{\}_\-\.'";]+/g, ' ')

    # Split camelCased terms into seperate words
    definition = definition.replace(/([a-z])([A-Z])/g, (s, a, b) -> "#{a} #{b.toLowerCase()}")

    # Replace the word return with "it" (only for functions that are more complex than a simple return)
    definition = definition.replace ' return ', ' it '

    $.trim definition

  # Returns an HTML representation of any kind of object
  inspect: (object) ->
    if object is null
      'null'
    else if object is undefined
      'undefined'
    else if object is true
      'true'
    else if object is false
      'false'
    else if object instanceof Array
      items = for item in object
        Spec.Util.inspect item
      "[#{items.join ', '}]"
    else if typeof object == 'object'
      properties = []
      for key, value of object
        # Access hasOwnProperty through Object.prototype to work around bug
        # in IE6/7/8 when calling hasOwnProperty on a DOM element
        if Object.prototype.hasOwnProperty.call(object, key)
          properties.push Spec.Util.escape(key) + ': ' + Spec.Util.inspect(value)
      "{#{properties.join ', '}}"
    else
      "“#{Spec.Util.escape(object)}”"

  # Gets the class name of an object using JavaScript magic
  inspectClass: (object) ->
    Object.prototype.toString.call(object).match(/^\[object\s(.*)\]$/)[1]

  # Escapes text for HTML
  escape: (string) ->
    $('<div/>').text(String(string)).html()
