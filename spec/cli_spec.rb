require 'cli'

RSpec.describe MyCLI, '#sync' do
  context "with simplest-commitsto.json already fetched from Beeminder" do
    it "hits http://kb.commits.to/ and visits, adds each of the uncounted points" do
      pending "verify simplest-commitsto.json first"
    end
    it "hits http://kb.commits.to/ again and noops when the data hasn't changed" do
      pending "verify simplest-commitsto.json first"
    end
    context "error conditions" do
      it "aborts if simplest-commitsto.json shows a 404" do
        pending "it has a 404 now, make it pass"
        # binding.pry
        pending "make the test pass"
      end
      it "aborts if simplest-commitsto.json doesn't appear to have been updated" do
        pending "need to fetch a good version first to see how this can be achieved"
      end
    end
  end
end
