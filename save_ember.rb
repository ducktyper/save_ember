require 'coffee_script'
require './common'
include  Common

ROOT = "/Users/ducksan/projects/hermes/app/assets/javascripts/"
DEST = "/Users/ducksan/projects/hermes-js/app/"
APP  = "Hermes"
# DEST = "/Users/ducksan/projects/save_ember/"

def create_paths
  %w(models adapters serializers).each do |path|
    full_path = DEST + path
    Dir.mkdir(full_path) unless File.exists?(full_path)
  end
end

def coffeefix basename, code
  # Fix reopen the same class issue
  class_name = class_name_from basename
  code.gsub! /\b#{APP}\.#{class_name}\.reopenClass.*/, ''

  code
end

def extract_serializer js, basename
  pattern = /\s*(?<serializer>Hermes\.\w+ = DS.ActiveModelSerializer.extend#{BRACKET};)\s*/
  if (match = js.match pattern)
    js.sub! pattern, ''

    serializer = match[:serializer]
    serializer = export_class APP, serializer
    serializer = import_classes APP, serializer

    save serializer, "#{DEST}serializers/#{basename}.js"
  end
  js
end

def extract_adapter js, basename
  pattern = /\s*(?<adapter>#{APP}\.\w+ = (?<name>[\w\.]+)Adapter.extend#{BRACKET};)\s*/
  if (match = js.match pattern)
    js.sub! pattern, ''

    adapter = match[:adapter]
    adapter = export_class APP, adapter
    adapter = import_classes APP, adapter

    save adapter, "#{DEST}adapters/#{basename}.js"
  end
  js
end

create_paths

[
  "account_management/models/**/*.js.coffee",
  "internal_tools/models/**/*.js.coffee",
  "shared/models/**/*.js.coffee",
].each do |path|
  Dir[ROOT + path].each do |file|
    basename = File.basename(file, ".js.coffee").downcase.gsub('_', '-')

    js = CoffeeScript.compile coffeefix(basename, File.read(file).dup)
    js = remove_outer_closer js
    js = export_class APP, js
    js = extract_serializer js, basename
    js = extract_adapter js, basename
    js = import_classes APP, js

    save js, "#{DEST}models/#{basename}.js"
  end
end
