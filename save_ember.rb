require 'coffee_script'
require './common'
include  Common

ROOT = "/Users/ducksan/projects/hermes/app/assets/javascripts/"
DEST = "/Users/ducksan/projects/hermes-js/app/"
# DEST = "/Users/ducksan/projects/save_ember/"

def create_paths
  %w(models adapters serializers).each do |path|
    full_path = DEST + path
    Dir.mkdir(full_path) unless File.exists?(full_path)
  end
end

def extended_model js, basename
  class_name = class_name_from basename

  if js.sub!(/Hermes\.#{class_name} = Hermes\.(\w+)\.extend\(/, 'export default \1.extend(')
    js.prepend "import #{$1} from './#{file_name_from $1}';\n"
  end
  js
end

def export_default js
  js.sub!(/\s*Hermes\.\w+ = DS.Model.extend/, "export default DS.Model.extend")
  js
end

def require_model js
  js.prepend "import DS from 'ember-data';\n"
end

def extract_serializer js, basename
  if js.sub!(/\s*(Hermes\.\w+ = DS.ActiveModelSerializer.extend#{BRACKET};)\s*/, '')
    serializer = $1
    serializer.sub!(/\s*Hermes\.\w+ = DS/, 'export default DS')
    serializer = require_model serializer

    save serializer, "#{DEST}serializers/#{basename}.js"
  end
  js
end

def extract_adapter js, basename
  if js.sub!(/\s*Hermes\.\w+ = Hermes\.InternalAdapter.extend\(\)\s*/, '')
    adapter = "export default DS.RESTAdapter.extend({\n  namespace: 'internal/v1'\n});"
    adapter = require_model adapter

    save adapter, "#{DEST}adapters/#{basename}.js"
  elsif js.sub!(/\s*(Hermes\.\w+ = Hermes\.RESTAdapter.extend#{BRACKET};)\s*/, '')
    adapter = $1
    adapter.sub!(/\s*Hermes\.\w+ = Hermes/, 'export default DS')
    adapter = require_model adapter

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

    js = CoffeeScript.compile File.read(file)
    js = remove_outer_closer js
    js = extended_model js, basename
    js = export_default js
    js = require_model js
    js = extract_serializer js, basename
    js = extract_adapter js, basename

    save js, "#{DEST}models/#{basename}.js"
  end
end
