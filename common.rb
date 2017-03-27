module Common
  BRACKET = '(?<bracket>\(([^()]|\g<bracket>)*\))'

  def file_name_from class_name
    class_name.sub(/^[A-Z]/, &:downcase).
      gsub(/[A-Z]/) {|first| '-' + first.downcase}.gsub(/-(\w)(?=-)/, '\1')
  end

  def class_name_from file_name
    file_name.gsub(/\b\w/, &:upcase).gsub('-', '')
  end

  def save text, path
    File.open(path, "w") {|f| f.write(text)}
  end

  def remove_outer_closer js
    js.sub!(/\A\(function\(\) {\n/, '')
    js.sub!(/\n}\)\.call\(this\);\Z/, '')
    js.gsub!(/^\s\s/, '') # remove indent
    js
  end

  def import_class app_name, class_name
    if class_name =~ /^DS\./
      "import DS from 'ember-data';\n"
    elsif class_name =~ /^#{app_name}\.(\w+)$/
      "import #{$1} from './#{file_name_from $1}';\n"
    else
      puts "Don't know how to import #{class_name}"
      nil
    end
  end

  def export_class app_name, code
    if (match = code.match(/\s*#{app_name}\.\w+ = (?<class_name>.*)\.extend/))
      code.sub!(/\s*#{app_name}\.\w+ = (#{app_name}\.)?/, 'export default ')
      code.prepend(import_class app_name, match[:class_name])
      code
    else
      puts "Don't know how to export #{code.scan(/.*/)[0]}"
      code
    end
  end
end
