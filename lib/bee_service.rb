class BeeService
  class JsonError < StandardError; end
  attr_reader :username, :access_token
  attr_reader :json_data
  def initialize(username:, access_token:, json_data:)
    @username = username
    @access_token = access_token
    @json_data = json_data

    validate_json
  end

  private
  def validate_json
    status = json["status"]
    error = json["error"]

    if status == "404"
      raise JsonError, "#{status} #{error}"
    end
    raise JsonError, json["error"] if json.has_key?("error")
  end
  def json
    @json ||= JSON.parse(json_data)
  end
end
