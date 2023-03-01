module Acli
  class DebugLogger
    def log(msg)
      puts "[DEBUG] [#{Time.now.to_s}] #{msg}"
    end
  end

  class NoopLogger
    def log(_msg)
    end
  end
end
