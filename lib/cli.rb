require "thor"
require './lib/bee_service'
require './lib/commit_service'
require 'json'
# require 'pry'

class MyCLI < Thor
  attr_reader :commitsto, :beeminder

  desc "sync COMMITSTO_USER", "add data points from COMMITSTO_USER (default: 'kb')"
  def sync(name: "kb")
    user = commit_factory(username:name)

    user.update(beeminder)
  end

  def initialize(args, opts, config, commitsto:CommitService, env:ENV)
    @commitsto = commitsto
    @beeminder = BeeService.new(
      username: env['BEEMINDER_USERNAME'],
      access_token: env['BEE_AUTH_TOKEN'],
      json_data: File.read('simplest-commitsto.json') )
    super(args, opts, config)
  end

  private
    def commit_factory(username:)
      commitsto.new(username)
    end

    def self.start(args)
      super(args)
    end
  #
end
 
