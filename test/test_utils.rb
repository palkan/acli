module Acli
  class TestUtils < MTest::Unit::TestCase
    def test_serialize
      assert_equal true, Utils.serialize('t')
      assert_equal true, Utils.serialize('y')
      assert_equal true, Utils.serialize('yes')

      assert_equal false, Utils.serialize('f')
      assert_equal false, Utils.serialize('n')
      assert_equal false, Utils.serialize('no')

      assert_equal 1, Utils.serialize('1')
      assert_equal 3.14, Utils.serialize('3.14')

      assert_equal nil, Utils.serialize('nil')
      assert_equal nil, Utils.serialize('null')

      assert_equal 'word', Utils.serialize(%("word"))
      assert_equal 'word', Utils.serialize(%('word'))
      assert_equal 'word', Utils.serialize('word')
    end
  end
end

MTest::Unit.new.run
