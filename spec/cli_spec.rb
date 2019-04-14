require 'cli'

RSpec.describe MyCLI, '#sync' do
  let(:thor_config) { Marshal.load(
    "\x04\b{\b:\nshello:\x17Thor::Shell::Color\t:\n@base0:\n@muteF:\r@paddingi\x00:\x12@always_forceF:\x14current_commandS:\x12Thor::Command\v:\tnameI\"\tsync\x06:\x06EF:\x10descriptionI\"8add data points from COMMITSTO_USER (default: 'kb')\x06;\x0ET:\x15long_description0:\nusageI\"\x18sync COMMITSTO_USER\x06;\x0ET:\foptions{\x00:\x12ancestor_name0:\x14command_options@\v" ) }
  let(:args) { [] }
  let(:options) { [] }

  let(:kb_commits_to_file) { File.new('spec/stubs/kb_commits_to.txt') }
  let(:why_so_much_file)   { File.new('spec/stubs/why_so_much_memory.txt') }
  let(:buildpacks_v3_file) { File.new('spec/stubs/buildpacks_v3.txt') }

  before do
    WebMock.disable_net_connect!
    stub_request(:get, "http://kb.commits.to/").to_return(kb_commits_to_file)
    stub_request(:get, "http://kb.commits.to/why-is-the-facilities-api-taking-so-much-memory").to_return(why_so_much_file)
    stub_request(:get, "http://kb.commits.to/buildpacks/v3-get-started").to_return(buildpacks_v3_file)
  end

  after do
    WebMock.allow_net_connect!
  end

  context "with simplest-commitsto.json already fetched from Beeminder" do

    let(:commit_double) { CommitService }
    let(:env) {
      {'BEEMINDER_USERNAME' => 'dreev',
       'BEE_AUTH_TOKEN' => 'NoAuthTokenHere'}
    }

    let(:subject) { MyCLI.new(args, options, thor_config,
                              commitsto:commit_double,
                              env:env ) }

    it "responds to the 'sync' command" do
      expect_any_instance_of(BeeService).to receive(:json_data).
        and_return('{}')
      expect_any_instance_of(BeeService).to receive(:fresh_json_data?).
        and_return true

      subject.set_user(username: 'kb')
      allow(subject.user).to receive(:update).
        with(subject.beeminder).and_call_original
      allow(subject.beeminder).to receive(:log_to_beeminder).
        with(Date.parse("2019-03-29"),
             "promise: why-is-the-facilities-api-taking-so-much-memory", 1)
        .and_call_original
      allow(subject.beeminder).to receive(:log_to_beeminder).
        with(Date.parse("2018-10-09"),
             "promise: buildpacks/v3-get-started", 1)
        .and_call_original
      expect{subject.sync}.to_not raise_error
    end
    context "error conditions" do
      it "aborts if simplest-commitsto.json shows any error" do
        expect_any_instance_of(BeeService).to receive(:json_data).
          and_return('{"error":"resource not found"}')
        expect{subject.sync}.to raise_error(BeeService::JsonError, "resource not found")
      end
      it "aborts if simplest-commitsto.json shows a 404 status" do
        expect_any_instance_of(BeeService).to receive(:json_data).
          and_return('{"status":"404","error":"Not Found"}')
        expect{subject.sync}.to raise_error(BeeService::JsonError, "404 Not Found")
      end
      it "aborts if simplest-commitsto.json doesn't appear to have been updated" do
        expect_any_instance_of(BeeService).to receive(:json_data).
          and_return('{}')
        expect_any_instance_of(BeeService).to receive(:fresh_json_data?).
          and_return false
        expect{subject.sync}.to raise_error(BeeService::CurlError)
      end
    end
    context "regular operation" do
      # the regular operation of Sync is defined in the CommitService class
    end
  end
end
