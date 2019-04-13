require 'nokogiri'
require 'restclient'
# require 'pry'

class CommitService
  attr_reader :username, :page, :bee
  def initialize(username)
    @username = username
  end
  def update(bee)
    @bee = bee

    add_any_untracked_promises
    add_any_newly_completed_promises
  end

  private
    def page
      @page ||= Nokogiri::HTML(RestClient.get("http://#{username}.commits.to"))
    end

    def promises_count
      page.css('.promise-details').count
    end

    def add_any_untracked_promises
      # binding.pry
    end

    def add_any_newly_completed_promises
      # binding.pry
    end
  #
end
