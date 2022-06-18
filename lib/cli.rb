require 'bundler/setup'
require 'libev_scheduler'
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

    puts "calling do_update" # (the activity that runs periodically)
    do_update

    puts "calling Fiber.schedule"
    Fiber.schedule do
      puts "ran the updater, sleeping now"
      t0 = Time.now

      sleep 14400 # 4*60*60
      puts "woke up after #{Time.now - t0} seconds"
      self.sync # calling sync again, so this can be a loop
    end

    puts "Fiber scheduled at #{Time.now}"
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

      init_bee
      @user.update(beeminder)
    end

    def self.start(args)
      puts "Setting scheduler to Libev"
      Fiber.set_scheduler Libev::Scheduler.new
      super(args)
    end
  #
end

