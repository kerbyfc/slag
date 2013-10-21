###*
 * @namespace Slag.Widgets
###
Slag.register class Input extends Slag.Widget

  constructor: (el, @model, @attr) ->
    super()
    @setEl(el)

    @on 'render', =>
      unless @checkAvailability()
        @disable()

  val: (value) ->
    @["#{unless value then 'get' else 'set'}Value"](value)

  # getter and setter
  setValue: -> false
  getValue: -> true

  render: -> false
  checkAvailability: -> true
  disable: -> false
  enable: -> true
