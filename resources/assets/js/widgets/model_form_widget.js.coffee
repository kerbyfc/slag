###*
 * @namespace Slag.Widgets
###
Slag.register class ModelFormWidget extends Slag.Widget

  events:
    'click': 'processFormClick'
    'submit': 'submit'

  inputTypes:
    boolean: 'checkbox'
    string: 'text'

  constructor: ->
    super

  handleClicksToSimpleInputs: ->
    @$el.bind 'click', @processFormClick

  buildFormByModelData: (options = {}) ->
    app.log @$el
    @$el.empty()
    for key, val of @model.toHASH()
      if _.has options, key
        inputType = @inputTypes[ options['as'] || val.constructor.name.toLowerCase() ]
        unless inputType
          throw Error "Unnable to build input for #{key}"
        els = @["build#{app.utils.capitalize inputType}Input"](key, val, options[key])
        if r is undefined
          r = $('<div class="content-row">')
        if options[key]['ln']
          @$el.append r if r.html().length
          r = $('<div class="content-row">')
        r.append els
    @$el.append r if r and r.html().length
    this

  buildCheckboxInput: (key, val, opts) ->
    [] # TODO

  buildTextInput: (key, val, opts) ->
    controls = [
     $('<input>').attr(type: 'text').attr(name: key).css(opts['css'] || {}).addClass(opts['cls'] || '').val(val)
    ]
    if _.has(opts, 'desc')
      controls.unshift $('<p>').text( " " + opts['desc']).addClass('i-desc glyphicon glyphicon-info-sign lh-inherit')
    if _.has(opts, 'name') and opts['name'] isnt null
      controls.unshift $('<p>').text( opts['name'] || key).addClass('i-label')
    controls

  processFormClick: (e) =>
    input = $(e.target)
    type = input.attr('type')
    if input.data('widget') is undefined and type in ['checkbox', 'radio']
      val = if type is 'checkbox' then input.is(':checked') else input.val()
      @model.change input.attr('name'), val

  updateModel: (silent = false) ->
    @model[if silent then "set" else "change"] @serialize()

  serialize: =>
    _.reduce @$el.serializeArray(), (m, o) =>
      t = {}
      t[o.name] = o.value
      _.extend m, t
    , {}

  submit: (e) =>
    e.preventDefault()
    @serialize()


