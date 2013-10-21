###*
 * @namespace Slag
###
Slag.register class View extends Backbone.View

  template: ''
  model: null

  layout: false
  menu_title: false

  include:
    el_prop: true
    events: true
    loader: true

  options: {}
  defaults: {}

  data: ->
    @

  open: -> false
  close: -> false

  title: (html) ->
    app.navigator.title html

  constructor: ->
    super
    @on 'render', =>
      @delegateEvents()

  initialize: (el) ->
    super()
    @setEl(el)

  render: (data = @) =>
    @$el.html( Slag.template 'views/' + @constructor.name.replace(/View$/, '').toLowerCase(), data )
    @trigger 'render'
    this
