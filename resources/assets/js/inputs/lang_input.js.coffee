###*
 * @namespace Slag.Widgets
###
Slag.register class LangInput extends Slag.Input

  langs: null

  options:
    all: true

  audit: true

  events: ->
    'click .btn': @change

  constructor: ->
    super

    @langs ?= app.storage.factory('langs')
    @input ?= @$el
    @setEl @input.parent()

    @once 'render', =>
      console.log "HERE"
      @model.on 'change:lang', (m) ->
        @setValue m.get('lang')

    @on 'render', =>
      unless @checkAvailability()
        @disable()

    unless @langs.length
      @langs.fetch @options, success: @render
    else
      @render()

  change: (e) =>
    console.log this
    console.log "CHANGE", @model.id, @val()

  getValue: ->
    @$('.active > input').val() || @input.val()

  setValue: (value) ->
    @$('.label').removeClass 'active'
    @$("input[value=\"#{value}\"]").parent().addClass 'active'
    @input.val(value)

  render: =>
    @input.after Slag.template 'widgets/lang',
      langs: @langs.toJSON(),
      active: @model.get('attrs.lang'),
      translations: @model.translations

  checkAvailability: ->
    @model.get('attrs.lang') isnt undefined

  disable: =>
    @$('.btn').attr('disabled', true)

  enable: =>
    @$('.btn').removeAttr('disabled')
