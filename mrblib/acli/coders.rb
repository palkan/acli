module Acli
  module Coders
    module JSON
      def self.encode(data)
        data.to_json
      end

      def self.decode(str)
        ::JSON.parse(str)
      end
    end

    module Msgpack
      def self.encode(data)
        MessagePack.pack(data)
      end

      def self.decode(str)
        MessagePack.unpack(str)
      end
    end
  end
end
