Slag.register class PresentationsView extends Slag.View

  menu_title: 'Презентации'
  menu_icon: 'film'

  route: 'presentations(/:id)'

  open: ->
    console.log "OPEN", arguments