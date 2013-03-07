window.Spec ||= {}

window.Spec.Util =
  extend: (object, extensions...) ->
    for extension in extensions
      for key, value of extension
        object[key] = value

  unextend: (object, extensions...) ->
    for extension in extensions
      for key, value of extension
        delete object[key]

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
    if object instanceof Array
      s = '['
      first = true
      for item in object
        if first
          first = false
        else
          first += ', '
        s += "“#{@escape(String(item))}”"
      s + ']'
    else if object is null
      'null'
    else if object is undefined
      'undefined'
    else if object is true
      'true'
    else if object is false
      'false'
    else if typeof object == 'object'
      s = "{"
      first = true
      for key of object
        # Access hasOwnProperty through Object.prototype to work around bug
        # in IE6/7/8 when calling hasOwnProperty on a DOM element
        if Object.prototype.hasOwnProperty.call(object, key)
          if first
            first = false
          else
            s += ", "
          s += @escape(key) + ': “' + @escape(String(object[key])) + '”'
      s + "}"
    else
      "“#{@escape(object)}”"

  # Escapes text for HTML
  escape: (string) ->
    $('<div/>').text(String(string)).html()