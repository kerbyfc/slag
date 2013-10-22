Slag.register class IndexView extends Slag.View

  audit: true

  hide_menu_item: true

  route: "setup"

  open: ->
    app.navigator.title "Настройка системы", "cog"




