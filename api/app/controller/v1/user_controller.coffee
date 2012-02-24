_ = require "underscore"

{ ApiaxleController } = require "../controller"
{ NotFoundError, AlreadyExists } = require "../../../lib/error"

userDetails = ( app ) ->
  ( req, res, next ) ->
    user = req.params.user

    app.model( "users" ).find user, ( err, dbUser ) ->
      return next err if err

      req.requestedUser = dbUser

      return next()

class exports.CreateUser extends ApiaxleController
  @verb = "post"

  middleware: -> [ userDetails( @app ) ]

  path: -> "/v1/user/:user"

  execute: ( req, res, next ) ->
    # error if it exists
    if req.requestedUser?
      return next new AlreadyExists "#{ user } already exists."

    @app.model( "users" ).create req.params.user, req.body, ( err, newObj ) ->
      return next err if err

      res.json newObj
