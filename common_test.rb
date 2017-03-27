require 'minitest/autorun'
require './common'

include Common

describe "common" do
  let(:app) {'Hermes'}

  it "bracket" do
    [
      ["func1({abcde;});", "({abcde;})"],
      ["func1({\nfunc2();});\nfunc3();", "({\nfunc2();})"],
    ].each do |code, match|
      regex = "func1#{BRACKET};"
      code.match /#{regex}/
      assert_equal match, $1, "Code: #{code}\nMatch: #{regex}"
    end
  end

  it "file_name_from & class_name_from" do
    [
      ["AaBb", "aa-bb", "AaBb"],
      ["AABb", "aa-bb", "AaBb"],
    ].each do |class_name, file_name, back_to_class_name|
      assert_equal(file_name, file_name_from(class_name))
      assert_equal(back_to_class_name, class_name_from(file_name))
    end
  end

  it "remove_outer_closer" do
    from =
"(function() {
  code
}).call(this);"
    assert_equal(remove_outer_closer(from), "code")
  end

  it "import_classes" do
    assert_equal("import DS from 'ember-data';\n\nDS.Model", import_classes('Hermes', 'DS.Model'))
    assert_equal("import Ember from 'ember';\n\nEmber.Object", import_classes('Hermes', 'Ember.Object'))
    assert_equal("import RESTAdapter from './rest-adapter';\n\nRESTAdapter", import_classes('Hermes', 'Hermes.RESTAdapter'))
  end

  it "export_class" do
    out = export_class 'Hermes', 'Hermes.Test = DS.Model.extend()'
    assert_equal("export default DS.Model.extend()", out)

    out = export_class 'Hermes', 'Hermes.Test = Hermes.Parent.extend()'
    assert_equal("export default Parent.extend()", out)
  end
end
