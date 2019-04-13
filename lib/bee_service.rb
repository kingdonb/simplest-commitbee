class BeeService
  class JsonError < StandardError; end
  class CurlError < StandardError; end
  attr_reader :username, :access_token
  attr_reader :json_data, :json_filename
  def initialize(username:, access_token:, json_filename:)
    @username = username
    @access_token = access_token
    @json_filename = json_filename
    @json_data = File.read(json_filename)

    validate_json
  end

  private
  def validate_json
    if json.class.to_s == "Hash"
      status = json["status"]
      error = json["error"]

      if status == "404"
        raise JsonError, "#{status} #{error}"
      end
      raise JsonError, json["error"] if json.has_key?("error")
    elsif json.class.to_s == "Array"
      raise JsonError, "no data points" if json.count < 1
    else
      raise JsonError, "no data was parsed"
    end

    raise CurlError, "JSON data isn't fresh, try ./README" unless fresh_json_data?
  end
  def json
    @json ||= JSON.parse(json_data)
  end

  private
    # JSON is considered fresh if it has an mtime in 10 seconds recent history
    def fresh_json_data?
      mtime = File.mtime(json_filename)
      Time.now - mtime < 10
    end
  #
end
