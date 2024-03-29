require 'bundler/setup'
require 'fiber_scheduler'
require "thor"
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

    puts "calling Fiber.schedule for do_update loop"
    Fiber.schedule do
      loop do
        do_update

        puts "ran the updater, sleeping now"
        t0 = Time.now

        sleep 14400 # 4*60*60
        puts "updater running again after #{Time.now - t0} seconds"
      end
    end

    Fiber.schedule(:waiting) do
      loop do
        t0 = Time.now
        sleep 60 * 60
        how_long = (Time.now - t0) / 60.0
        puts "heartbeat every #{how_long.round}m"
      end
    end

    puts "MyCLI::sync scheduled Fibers at #{Time.now}" # + " and yields to libev"
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
      @beeminder ||= BeeService.new(
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
      # turns out Fiber.scheduler messes with Net::HTTP
      # (maybe because it's supposed to be non-blocking?)
      # The old standby shell-out still works here though!
      `./README`

      hit_up_commitsto_api
      hit_up_beeminder_json
      @user.update(beeminder)
    end

    def hit_up_commitsto_api
      set_user(username: 'kb')
    end

    def hit_up_beeminder_json
      @bee_service = init_bee
      @bee_service.do_lifting unless @bee_service.fresh_read?
    end

    def self.start(args)
      puts "Setting scheduler to bruno-/fiber_scheduler"
      Fiber.set_scheduler(FiberScheduler.new)
      super(args)
    end
  #
end

