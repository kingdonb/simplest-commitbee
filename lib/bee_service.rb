# require 'pry'
require 'json'

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

  def seen_promise?(slug)
    promise_slugs.include? slug
  end

  def seen_completed?(slug)
    completed_slugs.include? slug
  end

  def not_seen_promises(slug_arr)
    slug_arr.reject do |slug|
      promise_slugs.include? slug
    end
  end

  def not_seen_completes(slug_arr)
    slug_arr.reject do |slug|
      completed_slugs.include? slug
    end
  end

  class NotImplementedYet < StandardError; end
  def log_promise(tuple)
    raise NotImplementedYet
  end

  def log_completed(tuple)
    raise NotImplementedYet
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

    # JSON is considered fresh if it has an mtime in 10 seconds recent history
    def fresh_json_data?
      mtime = File.mtime(json_filename)
      Time.now - mtime < 10
    end

    def comment_matcher
      /(promise|success): (.*)/
    end

    def all_matched_comments
      @all_matched_comments ||=
        json.map{|h| h["comment"]}.
        select{|c| c[comment_matcher]}
    end

    def all_matched_tuples
      @all_matched_tuples ||=
        all_matched_comments.map do |c|
        m = comment_matcher.match c
        [m[1], m[2]]
      end
    end

    def promise_slugs
      @promise_slugs ||=
        all_matched_tuples.
        select{|m| m[0] == "promise"}.
        map{|p| p[1]}
    end

    def completed_slugs
      @completed_slugs ||=
        all_matched_tuples.
        select{|m| m[0] == "success"}.
        map{|s| s[1]}
    end

  #
end
