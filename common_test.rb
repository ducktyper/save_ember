require 'minitest/autorun'
require './common'

include Common

describe "common" do
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
      ["AaBb", "aa-bb"],
    ].each do |class_name, file_name|
      assert_equal(file_name, file_name_from(class_name))
      assert_equal(class_name, class_name_from(file_name))
    end
  end

  it "remove_outer_closer" do
    from =
"(function() {
  code
}).call(this);"
    assert_equal(remove_outer_closer(from), "code")
  end
end
