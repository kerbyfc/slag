Slag.register class QuotationsView extends Slag.View

  layout: 'QuotationsLayout'

  # audit: true

  routes:
    'quotations/my': 'Мои цитаты'
    'quotations/all': 'Все цитаты'

  menu_icons:
    'Все цитаты': 'asterisk',
    'Мои цитаты': 'star-empty'

  my: ->


  initialize: (el, type, filter) ->
    super

    @render
      type: type

    collection = unless type is 'all'
      app.storage.getCollection "quotations(/my)", condition: @[type]
    else
      app.storage.get 'quotations'

    @collectionWidget = Slag.factory 'CollectionWidget', fname: 'QuotationsCollectionWidget', protected_methods: ['handleScroll'],
      el: ".#{type}-quotations-collection-widget"
      collection: collection

  open: (type, filter) ->
    @collectionWidget.render()






