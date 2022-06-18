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

    Fiber.set_scheduler ::Libev::Scheduler.new
    Fiber.schedule do
      while do_update
        puts "ran the update, sleeping now"
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
    @beeminder = BeeService.new(
      username: env['BEEMINDER_USERNAME'],
      access_token: env['BEE_AUTH_TOKEN'],
      json_filename: 'simplest-commitsto.json' )
    super(args, opts, config)
  end

  private
    def commit_factory(username:)
      commitsto.new(username)
    end

    def do_update
      @user.update(beeminder)
    end

    def self.start(args)
      super(args)
    end
  #
end
 
