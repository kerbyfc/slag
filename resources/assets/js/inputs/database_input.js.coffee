###*
 * @namespace Slag.Widgets
###
Slag.register class DbInput extends Slag.Input

  langs: null

  options:
    all: true

  constructor: ->
    super

    @dbs ?= app.storage.factory('databases')
    @input ?= @$el

    unless @dbs.length
      @dbs.fetch @options, success: @render
    else
      @render()

  render: =>
    app.log @$el
    for db in @dbs.getModels()
      app.log "+ ", db.get('name')
      @$el.append $("<option value='#{db.get 'name'}'>#{db.get 'name'}</option>")
