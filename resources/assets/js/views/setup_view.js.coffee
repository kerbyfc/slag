Slag.register class SetupView extends Slag.View

  audit: true

  hide_menu_item: true

  route: "setup"

  events:
    'submit .form': @submit

  open: ->
    app.navigator.title "Настройка сервера", "cog"
    @render()
    @dbs = new Slag.Inputs.DbInput '.database-selector'

  submit: ->
    true






