module Acli
  class UtilsTest < MTest::Unit::TestCase
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

    def test_normalize_url
      assert_equal "http://example.com?q=1", Utils.normalize_url("EXAMPLE.COM?q=1")
      assert_equal "http://example.com?q=1", Utils.normalize_url("ws://example.com?q=1")
      assert_equal "http://example.com?q=1", Utils.normalize_url("http://example.com?q=1")
      assert_equal "https://example.com?q=1", Utils.normalize_url("wss://example.com?q=1")
    end

    def test_uri_to_ws_s
      %w[
        http://example.com/?q=1
        https://example.com/cable
        ws://example.com:999/?q=1
        wss://user:pass@test.com:321/test/path
      ].each do |url|
        assert_equal url.sub("http", "ws"), Utils.uri_to_ws_s(URI.parse(url))
      end
    end
  end
end

MTest::Unit.new.run
