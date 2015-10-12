_ = require 'lodash'
React = require 'react'

{
  a
  div
  h3
  section
  span
} = React.DOM

module.exports = React.createFactory React.createClass
  render: ->
    section
      className: 'content'
    ,
      h3 null, 'Components'
      div null,
        _.map @props.componentList, (component) =>
          console.log 'component', component
          div
            key: "component-#{component.name}"
          ,
            a
              href: "/admin/component/#{component._id}/edit"
              onClick: @props.pushState
            ,
              component.name
              span
                style:
                  opacity: 0.6
              ,".#{component.language}"
      div null,
        a
          href: '/admin/component/new'
          onClick: @props.pushState
        , 'new component >'
