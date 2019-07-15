module Channable
  class Response

    attr_reader :data
    attr_reader :success
    attr_reader :response

    def initialize(response_data)
      @response = response_data
      @success = response_data.success?
      @data = JSON.parse(response_data.body, object_class: OpenStruct)
    end

  end
end