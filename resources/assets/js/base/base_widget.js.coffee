###*
 * @namespace Slag
###
Slag.register class Widget extends Backbone.View

  include:
    events: true
    el_prop: true

  constructor: -> 
    super
    @on 'render', => 
      @delegateEvents()