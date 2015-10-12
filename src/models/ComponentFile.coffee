###
# ComponentFile schema
###

coffee = require 'coffee-script'
reactTools = require 'react-tools'

prependReact = (code) ->
  "var React = require('react');\nvar DOM = React.DOM;\n#{code}\n"

module.exports = (mongoose) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId

  ComponentFileSchema = new Schema
    name:
      type: String
      required: true
      index:
        unique: true
    language:
      type: String
      default: 'js'
    src:
      type: String
      default: ''
    bin:
      type: String
      default: ''
    exampleData:
      type: String
      default: '{}'
    createdAt:
      type: Date
      default: Date.now

  ComponentFileSchema.pre 'save', (next) ->
    switch @language
      when 'js'
        code = @src
      when 'jsx'
        code = reactTools.transform @src
      when 'coffee'
        code = coffee.compile @src
      else
        return next new Error 'wtf is ' + @language
    @bin = prependReact code
    next()

  mongoose.model 'ComponentFile', ComponentFileSchema
