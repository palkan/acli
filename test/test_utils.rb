module Acli
  class TestUtils < MTest::Unit::TestCase
    include Acli::Utils

    def test_serialize
      assert_equal true, serialize('t')
      assert_equal true, serialize('y')
      assert_equal true, serialize('yes')

      assert_equal false, serialize('f')
      assert_equal false, serialize('n')
      assert_equal false, serialize('no')

      assert_equal 1, serialize('1')
      assert_equal 3.14, serialize('3.14')

      assert_equal nil, serialize('nil')
      assert_equal nil, serialize('null')

      assert_equal 'word', serialize(%("word"))
      assert_equal 'word', serialize(%('word'))
      assert_equal 'word', serialize('word')
    end
  end
end

MTest::Unit.new.run
