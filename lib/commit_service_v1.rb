require 'nokogiri'
require 'restclient'
# require 'pry'
require 'active_support'
require 'active_support/core_ext'

class CommitServiceV1
  attr_reader :username, :page, :bee
  def initialize(username)
    @username = username
    @page = Nokogiri::HTML(RestClient.get(root_url))
  end
  def update(bee)
    @bee = bee

    add_any_untracked_promises
    add_any_newly_completed_promises
  end

  private
    def root_url
      "http://#{username}.commits.to/"
    end

    def slug_url(slug)
      root_url + slug
    end

    def promises
      page.css('ul.promises-list section.promise')
    end

    def promises_count
      promises.count
    end

    def add_any_untracked_promises
      all_unlogged_promises_slug_and_created_at.each do |t|
        bee.log_promise(t)
      end
    end

    def add_any_newly_completed_promises
      all_unlogged_fulfills_slug_and_tfin.each do |t|
        bee.log_completed(t)
      end
    end

    def all_promises_sections
      promises
    end

    def all_promise_slugs
      all_promises_sections.map do |p|
        slug_from(p)
      end
    end

    def all_completed_html_nodes
      promises.css(':has(.completed)')
    end

    def all_completed_slugs
      all_completed_html_nodes.map do |p|
        slug_from(p)
      end
    end

    def slug_from(promise)
      promise.css('div.promise-slug').text.strip
    end

    def all_unlogged_promises_slug_and_created_at
      urls_to_visit =
        bee.not_seen_promises(all_promise_slugs).
        map { |slug| slug_url(slug) }

      urls_to_visit.map do |u|
        promise_url_to_slug_and_created_at_tuple(u)
      end
    end

    def all_unlogged_fulfills_slug_and_tfin
      urls_to_visit =
        bee.not_seen_completes(all_completed_slugs).
        map { |slug| slug_url(slug) }

      urls_to_visit.map do |u|
        promise_url_to_slug_and_tfin_tuple(u)
      end
    end

    def promise_url_to_slug_and_created_at_tuple(url)
      promise_url_to_slug_and_date_selector_value_tuple(url, 'input#tini')
    end

    def promise_url_to_slug_and_tfin_tuple(url)
      promise_url_to_slug_and_date_selector_value_tuple(url, 'input#tfin')
    end

    def promise_url_to_slug_and_date_selector_value_tuple(url, selector)
      this_page = Nokogiri::HTML(RestClient.get(url))
      node = this_page.css(selector)

      slug_nodes = this_page.css('.promise-slug a')
      slugs = slug_nodes.map{|n| n.try(:text)&.strip}

      selected_nodes = this_page.css(selector)

      if selected_nodes.present?
        selected_date = Date.parse(selected_nodes.first.attr(:value))
      # else
      #   binding.pry
      end

      [slugs.first, selected_date]
    end

  #
end
