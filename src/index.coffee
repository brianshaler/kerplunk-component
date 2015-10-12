ComponentFileSchema = require './models/ComponentFile'

module.exports = (System) ->
  ComponentFile = System.registerModel 'ComponentFile', ComponentFileSchema

  getFile = (req, res, next) ->
    return next() unless req.params.format == 'js'
    parts = [req.params.part1]
    if req.params.part2?.length > 0
      parts.push req.params.part2
    if req.params.part3?.length > 0
      parts.push req.params.part3
    componentName = parts.join '/'
    name = "#{req.params.pluginName}:#{componentName}"
    ComponentFile
    .where
      name: name
    .findOne (err, component) ->
      return next() if err
      return next() unless component
      res.setHeader 'Content-Type', 'application/javascript'
      script = component.bin ? component.src
      res.send "\n;define(function(require,exports,module){#{script}});"

  list = (req, res, next) ->
    ComponentFile
    .find (err, components) ->
      return next err if err
      res.render 'list',
        componentList: components

  newComponent = (req, res, next) ->
    unless req.body?.name
      return res.render 'edit'
    component = new ComponentFile req.body
    component.save (err) ->
      return next err if err
      System.reset ->
        console.log 'System.reset complete!'
        res.redirect "/admin/component/#{component._id}/edit"

  edit = (req, res, next) ->
    {id} = req.params
    ComponentFile
    .where
      _id: id
    .findOne (err, component) ->
      return next err if err
      return next() unless component
      if req.body.src
        resetRequired = component.name != req.body.name
        component.name = req.body.name
        component.language = req.body.language
        component.src = req.body.src
        component.exampleData = req.body.exampleData
        component.save (err) ->
          return next err if err
          if resetRequired
            System.reset ->
              console.log 'System.reset complete!'
              res.render 'edit',
                component: component
          else
            res.render 'edit',
              component: component
      else
        res.render 'edit',
          component: component

  postRegistration = ->
    ComponentFile
    .find (err, components) ->
      return next() if err
      for component in components
        Component = null
        try
          ((module) ->
            eval(component.bin)
            Component = module.exports
          )({})
        catch ex
          console.log 'hax failed', ex
        if Component
          # console.log 'going to register this:', component.name, Component
          System.registerComponent component.name, Component
        else
          console.log 'failed to eval()', component.name
    return

  globals =
    public:
      nav:
        Admin:
          Components: {}
    events:
      componentsRegistered:
        post: postRegistration

  routes:
    admin:
      '/admin/component/:id/edit': 'edit'
      '/admin/component/new': 'newComponent'
      '/admin/component/list': 'list'
    public:
      '/plugins/:pluginName/components/:part1/:part2?/:part3?': 'getFile'

  handlers:
    getFile: getFile
    edit: edit
    newComponent: newComponent
    list: list
    index: (req, res, next) ->
      res.render 'index'

  globals: globals

  init: (next) ->
    ComponentFile
    .find (err, components) ->
      return next() if err
      nav =
        'All Components': '/admin/component/list'
      for component in components
        name = component.name.replace ':', '/'
        segments = name.split '/'
        ref = nav
        for i in [0..segments.length - 2] by 1
          segment = segments[i]
          ref[segment] = {} unless ref[segment]
          ref = ref[segment]
        ref[segments[segments.length - 1]] = "/admin/component/#{component._id}/edit"
      nav.New = '/admin/component/new'
      globals.public.nav.Admin.Components = nav
      next()
