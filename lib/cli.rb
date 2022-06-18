require 'bundler/setup'
# require 'libev_scheduler'
require "thor"
# require 'tty-command'
# require 'byebug'
# require "ostruct"
require './lib/bee_service'
require './lib/commit_service_v2'
require 'active_support'
require 'active_support/core_ext'
# require 'pry'

class MyCLI < Thor
  attr_reader :commitsto, :beeminder
  attr_accessor :user

  desc "sync COMMITSTO_USER", "add data points from COMMITSTO_USER (default: 'kb')"
  def sync(name: "kb")
    @user ||= commit_factory(username:name)
    $stdout.sync = true

    # puts "Setting scheduler to Libev"
    puts "No scheduler, this fancy shit is causing trouble"

    # Fiber.set_scheduler Libev::Scheduler.new
    # Fiber.schedule do
      puts "scheduled activity"
      # loop do
        puts "looping again"
        do_update
        puts "ran the updater, sleeping now"
        t0 = Time.now

        sleep 100 # 4*60*60
        puts "woke up after #{Time.now - t0} seconds"
      # end

      # Fiber should never finish
      puts "Fiber finished at #{Time.now}"
    # end

    puts "scheduled"
  end

  no_commands {
    def set_user(username:)
      @user = commit_factory(username:username)
    end
  }

  def initialize(args, opts, config, commitsto:CommitServiceV2, env:ENV)
    @commitsto = commitsto
    @beeminder = nil
    @username = env['BEEMINDER_USERNAME']
    @token = env['BEE_AUTH_TOKEN']
    super(args, opts, config)
  end

  private
    def commit_factory(username:)
      commitsto.new(username)
    end

    def init_bee
      @beeminder = BeeService.new(
        username: @username,
        access_token: @token,
        json_filename: 'simplest-commitsto.json' )
    end

    def show_errors!(err:, status:)
      puts "checking for errors"
      if err.present? || status != 0
        puts "Errors:"
        if err.present?
          puts; puts err
          puts "(exit status: #{status})"
        else
          puts "None (exit status: #{status})"
        end
        Kernel.exit(status)
      end
    end

    def do_update
      begin
        api="https://www.beeminder.com/api/v1"
        goal="simplest-commitsto"
        json="goals/#{goal}/datapoints.json"
        username="#{@username}"
        token="auth_token=#{@token}"

        uristr = "#{api}/users/#{username}/#{json}?#{token}"
        uri = URI.parse(uristr)
        response = Net::HTTP.get_response(uri)
        puts "response is fetched"
        # response = OpenStruct.new(body: "foo")

        File.open("#{goal}.json", 'w') do |file|
          file.write(response.body)
        end

        puts "Wrote #{goal}.json"

        # show_errors!(err: cmd.err, status: cmd.status)
      end
      # puts cmd.out

      init_bee
      @user.update(beeminder)
    end

    def self.start(args)
      super(args)
    end
  #
end

