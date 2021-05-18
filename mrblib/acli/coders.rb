module Acli
  module Coders
    module JSON
      def self.encode(data)
        data.to_json
      end

      def self.decode(str)
        ::JSON.parse(str)
      end

      def self.frame_format
        :text_frame
      end
    end

    module Msgpack
      def self.encode(data)
        MessagePack.pack(data)
      end

      def self.decode(str)
        MessagePack.unpack(str)
      end

      def self.frame_format
        :binary_frame
      end
    end
  end
end
