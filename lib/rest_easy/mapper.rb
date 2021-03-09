module RestEasy
  class NotImplementedError < StandardError; end
  class Mapper
    def initialize(app = nil, **args)
      @app = app
      @args = args || {}
    end

    def call(env = nil)
      raise NotImplementedError, "A mapper must implement #call"
    end
  end
end
