require 'nokogiri'
require 'restclient'
# require 'pry'

class CommitService
  attr_reader :username, :page
  def initialize(username)
    @username = username
  end
  def update(bee)
    promises_count
  end

  private
    def page
      @page ||= Nokogiri::HTML(RestClient.get("http://#{username}.commits.to"))
    end

    def promises_count
      page.css('.promise-details').count
    end
  #
end
