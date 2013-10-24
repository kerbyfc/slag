Slag.register class SetupView extends Slag.View

  audit: true

  hide_menu_item: true

  route: "setup"

  events:
    'click .btn': 'submit'

  open: ->
    app.navigator.title "Настройка сервера", "cog"
    @render()
    @dbs = new Slag.Inputs.DbInput '.database-selector'
    @dbs.on "change", (dbm) =>
      @dbForm?.updateModel(true)
      @renderDatabaseForm dbm

  submit: =>
    @dbForm.updateModel(true)
    @dbModel.set cfghome: $('.cfghome:checked').val()
    @dbModel.save()

  renderDatabaseForm: (@dbModel) ->
    @dbForm = new Slag.Widgets.ModelFormWidget( model: @dbModel, el: '.database-form' ).buildFormByModelData
      user:
        name: "Имя и пароль пользователя"
        ln: true
      password:
        name: null
        css:
          "margin-left": "-1px"
      db:
        name: "База данныx"
        ln: true
        cls: "width-100"
        desc: """Для sqlite/h2 нужно указать абсолютный путь в системе к файлу базы данныx (без расширения).
          Если файл не существует, он будет создан. Для остальныx баз данныx указывается имя базы."""
      host:
        name: "Xост и порт СУБД"
        ln: true
      port:
        name: null
        css:
          "margin-left": "-1px"









