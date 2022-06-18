require 'bundler/setup'
require 'libev_scheduler'
require "thor"
require 'open3'
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
    puts "Setting scheduler to Libev"

    Fiber.set_scheduler ::Libev::Scheduler.new
    Fiber.schedule do
      while do_update
        puts "ran the updater, sleeping now"
        $stdout.flush
        t0 = Time.now

        sleep 14400 # 4*60*60
        puts "woke up after #{Time.now - t0} seconds"
        $stdout.flush
      end

      # Fiber should never finish
      puts "Fiber finished at #{Time.now}"
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

    def show_errors!(err:, status:)
      if err.present? || status != 0
        puts "Errors:"
        if err.present?
          puts; puts err
          puts "(exit status: #{status})"
          $stdout.flush
        else
          puts "None (exit status: #{status})"
          $stdout.flush
        end
        Kernel.exit(status)
      end
    end

    def do_update
      $stdout.sync = true
      stdout, stderr, status = Open3.capture3("./README")
      puts stdout
      $stdout.flush
      show_errors!(err: stderr, status: status)

      init_bee
      @user.update(beeminder)
    end

    def self.start(args)
      super(args)
    end
  #
end

