module Common
  BRACKET = '(?<bracket>\(([^()]|\g<bracket>)*\))'

  def file_name_from class_name
    class_name.sub(/^[A-Z]/, &:downcase).
      gsub(/[A-Z]/) {|first| '-' + first.downcase}
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

end
