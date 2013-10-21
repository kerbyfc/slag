###*
 * @namespace Slag.Models
###
Slag.register class ContentModel extends Slag.Model

  constructor: (attrs = {}, options = {}) ->

    type = "#{attrs.content_type}Content"

    unless _.has Slag.Contents, type
      throw new Error "Content model #{type} isn't defined"

    return new Slag.Contents[type](attrs, options)