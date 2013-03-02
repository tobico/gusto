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
