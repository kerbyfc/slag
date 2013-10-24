###*
 * @namespace Slag.Widgets
###
Slag.register class DbInput extends Slag.Input

  val: null

  options:
    all: true

  events:
    'change':'change'

  constructor: ->
    super

    @dbs ?= app.storage.factory('databases')
    @input ?= @$el

    unless @dbs.length
      @dbs.fetch @options, success: @render
    else
      @render()

  render: =>
    for db in @dbs.getModels()
      @$el.append $("<option value='#{db.get 'name'}'>#{db.get 'name'}</option>")
    @change()

  change: =>
    @val = @$el.find('option:selected').val()
    @dbs.findWhere name: @val
