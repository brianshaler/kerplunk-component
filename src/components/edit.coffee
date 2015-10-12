_ = require 'lodash'
React = require 'react'

{
  div
  form
  h3
  input
  option
  section
  select
  textarea
} = React.DOM

module.exports = React.createFactory React.createClass
  getInitialState: ->
    showPreview: false

  componentDidMount: ->
    @setState
      showPreview: true

  render: ->
    component = @props?.component ? {}
    url = '/admin/component/' + if component._id
      "#{component._id}/edit"
    else
      'new'

    section
      className: 'content'
    ,
      h3 null, 'Edit Component'
      form
        method: 'post'
        action: url
        # onSubmit: @onSave
      ,
        div null,
          'Name: '
          input
            name: 'name'
            defaultValue: component.name ? ''
            placeholder: 'name'
        div null,
          select
            name: 'language'
            defaultValue: component.language ? ''
            style:
              width: '10em'
          ,
            option
              value: 'js'
            , 'js'
            option
              value: 'jsx'
            , 'jsx'
            option
              value: 'coffee'
            , 'coffee'
        div null,
          'Code:'
          textarea
            name: 'src'
            defaultValue: component.src ? ''
            style:
              width: '100%'
              height: '20em'
        div null,
          'Example Data:'
          textarea
            name: 'exampleData'
            defaultValue: component.exampleData ? ''
            style:
              width: '100%'
              height: '12em'
        div null,
          input
            type: 'submit'
            value: 'Save'
            className: 'btn btn-submit'
      if @state.showPreview
        Component = @props.getComponent "#{component.name}.js?"
        data = {}
        if component.exampleData?.length > 1
          try
            data = JSON.parse component.exampleData
          catch ex
            console.log ex
            'nothing'
        # console.log 'data', data
        div null,
          h3 null, 'Preview'
          Component _.extend {}, @props, data
      else
        null
