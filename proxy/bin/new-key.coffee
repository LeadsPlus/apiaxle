#!/usr/bin/env coffee

{ OptionParser } = require "parseopt"
{ ApiaxleProxy } = require "../apiaxle_proxy"

parser = new OptionParser
  minargs: 1
  strings:
    arguments: "KEY"

parser.add "--qpd",
  type: "integer"
  help: "Queries per day."
  default: 86400

parser.add "--qps",
  type: "integer"
  help: "Queries per second."
  default: 1

parser.add "--for-api",
  type: "string"
  help: "The api this key works with."
  required: true

parser.add "--shared-secret",
  type: "string"
  help: "The shared secret used to generate the shared key."

try
  options = parser.parse( )
catch e
  parser.usage()
  process.exit 1

[ key ] = options.arguments

gk = new ApiaxleProxy()
gk.script ( finish ) ->
  model = gk.model "apiKey"

  model.create key, options.options, ( err ) ->
    throw err if err

    model.find key, ( err, newKey ) ->
      throw err if err

      apiLimits = gk.model( "apiLimits" )

      multi = apiLimits.multi()
      multi.del apiLimits.qpsKey( key )
      multi.del apiLimits.qpdKey( key )

      multi.exec ( ) ->
        console.log newKey
        finish()
