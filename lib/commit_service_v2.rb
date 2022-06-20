require 'json'
require 'restclient'
# require 'pry'
require 'active_support'
require 'active_support/core_ext'

class CommitServiceV2
  attr_reader :username, :data, :bee
  def initialize(username)
    @username = username
    @data = nil
  end
  def update(bee)
    @bee = bee

    do_lifting
    add_any_untracked_promises
    add_any_newly_completed_promises
  end

  private
    def do_lifting
      `./README-commitsto`
      @data = nil

      hit_up_commitsto_api
    end

    def hit_up_commitsto_api
      @data ||= JSON.parse(File.read('promises.json'))
    end

    def promises_url
      "http://commits.to/api/v1/user/promises?username=#{username}"
    end

    def promises
      data['promises']
    end

  # # Useful for debugging, but not called by any other client function
  #   # def promises_count
  #   #   promises.count
  #   # end

    def add_any_untracked_promises
      slug_and_created_at_for_promises_not_seen_before.each do |t|
        bee.log_promise(t)
      end
    end

    def add_any_newly_completed_promises
      slug_and_tfin_for_promises_fulfilled_not_logged_already.each do |t|
        bee.log_completed(t)
      end
    end

    def all_promises
      promises
    end

    def all_promise_slugs
      all_promises.map do |p|
        slug_from(p)
      end
    end

    def all_completed_promises
      promises.select{ |p| p['tfin'].present? }
    end

    def all_completed_slugs
      all_completed_promises.map do |p|
        slug_from(p)
      end
    end

    def slug_from(promise)
      promise['slug']
    end

    def slug_and_created_at_for_promises_not_seen_before
      not_seen = bee.not_seen_promises(all_promise_slugs)

      not_seen.map do |p_slug|
        p = all_promises.select{ |pro| pro['slug'] == p_slug }.first
        promise_to_slug_and_created_at_tuple(p)
      end
    end

    def slug_and_tfin_for_promises_fulfilled_not_logged_already
      newly_complete = bee.not_seen_completes(all_completed_slugs)

      newly_complete.map do |c_slug|
        c = all_completed_promises.select{ |pro| pro['slug'] == c_slug }.first
        promise_to_slug_and_tfin_tuple(c)
      end
    end

    def promise_to_slug_and_created_at_tuple(promise)
      promise_to_slug_and_date_field_value_tuple(promise, 'tini')
    end

    def promise_to_slug_and_tfin_tuple(promise)
      promise_to_slug_and_date_field_value_tuple(promise, 'tfin')
    end

    def promise_to_slug_and_date_field_value_tuple(promise, selector)
      selected_date = promise[selector]
      if selected_date.present?
        selected_date = Date.parse(selected_date)
      # else
      #   binding.pry
      end

      [slug_from(promise), selected_date]
    end

  #
end
