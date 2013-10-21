Slag.register class Utils

  capitalize: (str) ->
    str.charAt(0).toUpperCase() + str.slice(1)

  duration: (seconds = 0) ->
    d = parseInt(seconds, 10)
    h = Math.floor(d / 3600)
    m = Math.floor(d % 3600 / 60)
    s = Math.floor(d % 3600 % 60)
    return ((if h > 0 then h + ":" else "") + (if m > 0 then (if m < 10 then "0" else "") + m + ":" else "00:") + (if s < 10 then "0" else "") + "" + s)

  allowedKey: (keycode) ->
    switch keycode
      when 37, 38, 39, 40, 13
        false
      else
        true

  plural: (str) ->
    if str.slice(-1) isnt 's'
      str += 's'
    str

  singular: (str) ->
    if str.slice(-1) is 's'
      str = str.slice(0, -1)
    str
