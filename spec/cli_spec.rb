require 'cli'
# require 'pry'

RSpec.describe MyCLI, '#sync' do
  let(:thor_config) { Marshal.load(
    "\x04\b{\b:\nshello:\x17Thor::Shell::Color\t:\n@base0:\n@muteF:\r@paddingi\x00:\x12@always_forceF:\x14current_commandS:\x12Thor::Command\v:\tnameI\"\tsync\x06:\x06EF:\x10descriptionI\"8add data points from COMMITSTO_USER (default: 'kb')\x06;\x0ET:\x15long_description0:\nusageI\"\x18sync COMMITSTO_USER\x06;\x0ET:\foptions{\x00:\x12ancestor_name0:\x14command_options@\v" ) }
  let(:args) { [] }
  let(:options) { [] }
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
      it "hits http://kb.commits.to/ and visits, adds each of the uncounted points" do
        pending "verify simplest-commitsto.json first"
      end
      it "hits http://kb.commits.to/ again and noops when the data hasn't changed" do
        pending "verify simplest-commitsto.json first"
      end
    end
  end
end
