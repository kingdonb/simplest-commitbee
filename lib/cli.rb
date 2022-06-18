require 'bundler/setup'
require 'libev_scheduler'
require "thor"
require './lib/bee_service'
require './lib/commit_service_v2'
# require 'pry'

class MyCLI < Thor
  attr_reader :commitsto, :beeminder
  attr_accessor :user

  desc "sync COMMITSTO_USER", "add data points from COMMITSTO_USER (default: 'kb')"
  def sync(name: "kb")
    @user ||= commit_factory(username:name)

    $stdout.sync = true
    Fiber.set_scheduler ::Libev::Scheduler.new
    Fiber.schedule do
      while do_update
        puts "ran the updater, sleeping now"
        t0 = Time.now
        sleep 14400 # 4*60*60
        puts "woke up after #{Time.now - t0} seconds"
      end
    end

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

    def do_update
      `./README`
      init_bee
      @user.update(beeminder)
    end

    def self.start(args)
      super(args)
    end
  #
end
 
