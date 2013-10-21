###*
 * @namespace Slag
###
Slag.register class Layout extends Backbone.View

  ###*
   * заголовок в меню, если false - не отображается в меню
   * @type {String}
  ###
  menu_title: false

  include:
    el_prop: true
    events: true
    loader: true

  ###*
   * проводить ли аудит данного объекта через консоль
   * @type {Boolean}
  ###

  open: -> false
  close: -> false

  constructor: ->
    @setEl ".#{@constructor.name}-layout"
    super

  initialize: ->
    @render()

  render: (data = @) ->
    @undelegateEvents()
    @$el.html( Slag.template 'layouts/' + @constructor.name.replace(/Layout$/, '').toLowerCase(), data )
    @delegateEvents()
    this