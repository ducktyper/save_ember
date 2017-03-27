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

  def import_classes app_name, code
    import_code = code.scan(/\b(([A-Z]\w+)\.([A-Z]\w+))/).map(&:first).uniq.map do |class_name|
      case class_name
      when /^DS\./
        "import DS from 'ember-data';"
      when /^Ember\./, /^Em\./
        "import Ember from 'ember';"
      when /^#{app_name}\.(\w+)/
        "import #{$1} from './#{file_name_from $1}';"
      else
        raise "Don't know how to import #{class_name}"
      end
    end.join("\n")

    if import_code != ''
      code.prepend(import_code + "\n\n")
      code.gsub!(/\b#{app_name}\./, '')
      code.gsub!(/\bEm\./, 'Ember.')
    end
    code
  end

  def export_class app_name, code
    if (match = code.match(/\s*#{app_name}\.\w+ = .*\.extend/))
      code.sub!(/\s*#{app_name}\.\w+ = (#{app_name}\.)?/, 'export default ')
      code
    else
      puts "Don't know how to export #{code.scan(/.*/)[0]}"
      code
    end
  end
end
