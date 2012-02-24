async = require "async"

{ ApiaxleTest } = require "../../../apiaxle"

class exports.UserControllerTest extends ApiaxleTest
  @start_webserver = true
  @empty_db_on_setup = true

  "test POST a valid user": ( done ) ->
    options =
      path: "/v1/user/this_is_bob"
      headers:
        "Content-Type": "application/json"
      data: JSON.stringify
        email: "this_is_bob@example.com"

    @POST options, ( err, res ) =>
      @isNull err

      res.parseJson ( json ) =>
        @isUndefined json["error"]
        @equal json.email, "this_is_bob@example.com"

        # check it went in
        @application.model( "users" ).find "this_is_bob", ( err, dbUser ) =>
          @ok dbUser.createdAt
          @equal dbUser.email, "this_is_bob@example.com"

          done 5

  "test POST an invalid user (empty email)": ( done ) ->
    options =
      path: "/v1/user/this_is_bob"
      headers:
        "Content-Type": "application/json"
      data: JSON.stringify
        email: ""

    @POST options, ( err, res ) =>
      @isNull err

      res.parseJson ( json ) =>
        @ok json.error
        @equal json.error.status, 400
        @match json.error.message, /email/

        # check it went in
        @application.model( "users" ).find "this_is_bob", ( err, dbUser ) =>
          @isNull dbUser
          @isNull err

          done 6

  "test double POST a valid user": ( done ) ->
    options =
      path: "/v1/user/this_is_bob"
      headers:
        "Content-Type": "application/json"
      data: JSON.stringify
        email: "this_is_bob@example.com"

    @POST options, ( err, res ) =>
      @isNull err

      res.parseJson ( json ) =>
        @isUndefined json["error"]
        @equal json.email, "this_is_bob@example.com"

        # another post
        @POST options, ( err, res ) =>
          @isNull err

          res.parseJson ( json ) =>
            @ok json.error
            @equal json.error.status, 400

            done 6
