require 'coffee_script'

root = "/Users/ducksan/projects/hermes/app/assets/javascripts/"
# dest = "/Users/ducksan/projects/hermes-js/app/"
dest = "/Users/ducksan/projects/save_ember/"

def remove_closer js
  js.sub!(/\A\(function\(\) {\n/, '')
  js.sub!(/\n}\)\.call\(this\);\Z/, '')
  js
end

def export_default js
  js.sub!(/Hermes\.[^ ]+ = DS.Model.extend/, "export default DS.Model.extend")
  js
end

def require_model js
  js.prepend "import DS from 'ember-data';\n"
end

model_paths = [
  root + "account_management/models/**/*.js.coffee",
  # root + "internal_tools/models/**/*.js.coffee",
  # root + "shared/models/**/*.js.coffee",
]
model_paths.each do |path|
  Dir[path].each do |file|
    js = CoffeeScript.compile File.read(file)
    js = remove_closer js
    js = export_default js
    js = require_model js

    basename = File.basename(file, ".js.coffee")
    dest_path = dest + "models/" + basename + ".js"
    File.open(dest_path, "w") do |f|
      f.write(js)
    end
  end
end
