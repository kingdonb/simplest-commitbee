require 'bee_service'
# require 'pry'

RSpec.describe BeeService do
  before do
    expect_any_instance_of(BeeService).
      to receive(:validate_json) #.and_return(nil)
    expect(File).to receive(:read).
      with('').and_return(double('file'))
  end
  let(:bee_service) {
    BeeService.new(username:'dreev',
                   access_token:'NoAccessTokenHere',
                   json_filename:'')
  }
  let(:empty_json) {
    '[{"timestamp":1555189561,"value":0.0,"comment":"initial datapoint of 0.0 on the 13th","id":"5cb24f39bfec0320f2001d8e","updated_at":1555189561,"requestid":null,"canonical":"13 0 \"initial datapoint of 0.0 on the 13th\"","fulltext":"2019-Apr-13 entered at 17:06 ex nihilo","origin": "nihilo","daystamp":"20190413"}]'
  }
  let(:one_seen_promise_json) {
    '[{"timestamp":1553831999,"value":1.0,"comment":"promise: submit-a-netid-affiliate-request","id":"5cb2b814bfec0320f20022de","updated_at":1555216404,"requestid":null,"canonical":"28 1 \"promise: submit-a-netid-affiliate-request\"","fulltext":"2019-Mar-28 entered at 00:33 on 2019-Apr-14  via web","origin":"web","daystamp":"20190328"},{"timestamp":1555189561,"value":0.0,"comment":"initial datapoint of 0.0 on the 13th","id":"5cb24f39bfec0320f2001d8e","updated_at":1555189561,"requestid":null,"canonical":"13 0 \"initial datapoint of 0.0 on the 13th\"","fulltext":"2019-Apr-13 entered at 17:06 ex nihilo","origin":"nihilo","daystamp":"20190413"}]'
  }
  let(:two_seen_one_fulfilled_json) {
    '[{"timestamp":1554609599,"value":1.0,"comment":"success: submit-a-netid-affiliate-request","id":"5cb2b814bfec0320f20022df","updated_at":1555216404,"requestid":null,"canonical":"06 1 \"success: submit-a-netid-affiliate-request\"","fulltext":"2019-Apr-06 entered at 00:33 on 2019-Apr-14  via web","origin":"web","daystamp":"20190406"},{"timestamp":1553831999,"value":1.0,"comment":"promise: submit-a-netid-affiliate-request","id":"5cb2b814bfec0320f20022de","updated_at":1555216404,"requestid":null,"canonical":"28 1 \"promise: submit-a-netid-affiliate-request\"","fulltext":"2019-Mar-28 entered at 00:33 on 2019-Apr-14  via web","origin":"web","daystamp":"20190328"},{"timestamp":1554091199,"value":1.0,"comment":"promise: ob-mirror-beeminder-graph","id":"5cb2b72cbfec0320f20022c4","updated_at":1555216172,"requestid":null,"canonical":"31 1 \"promise: ob-mirror-beeminder-graph\"","fulltext":"2019-Mar-31 entered at 00:29 on 2019-Apr-14  via web","origin":"web","daystamp":"20190331"},{"timestamp":1555189561,"value":0.0,"comment":"initial datapoint of 0.0 on the 13th","id":"5cb24f39bfec0320f2001d8e","updated_at":1555189561,"requestid":null,"canonical":"13 0 \"initial datapoint of 0.0 on the 13th\"","fulltext":"2019-Apr-13 entered at 17:06 ex nihilo","origin":"nihilo","daystamp":"20190413"}]'
  }
  let(:two_seen_two_fulfilled_json) {
    '[{"timestamp":1554609599,"value":1.0,"comment":"success: submit-a-netid-affiliate-request","id":"5cb2b814bfec0320f20022df","updated_at":1555216404,"requestid":null,"canonical":"06 1 \"success: submit-a-netid-affiliate-request\"","fulltext":"2019-Apr-06 entered at 00:33 on 2019-Apr-14  via web","origin":"web","daystamp":"20190406"},{"timestamp":1553831999,"value":1.0,"comment":"promise: submit-a-netid-affiliate-request","id":"5cb2b814bfec0320f20022de","updated_at":1555216404,"requestid":null,"canonical":"28 1 \"promise: submit-a-netid-affiliate-request\"","fulltext":"2019-Mar-28 entered at 00:33 on 2019-Apr-14  via web","origin":"web","daystamp":"20190328"},{"timestamp":1554091199,"value":1.0,"comment":"success: ob-mirror-beeminder-graph","id":"5cb2b7b3bfec0320f20022ce","updated_at":1555216307,"requestid":null,"canonical":"31 1 \"success: ob-mirror-beeminder-graph\"","fulltext":"2019-Mar-31 entered at 00:31 on 2019-Apr-14  via web","origin":"web","daystamp":"20190331"},{"timestamp":1554091199,"value":1.0,"comment":"promise: ob-mirror-beeminder-graph","id":"5cb2b72cbfec0320f20022c4","updated_at":1555216172,"requestid":null,"canonical":"31 1 \"promise: ob-mirror-beeminder-graph\"","fulltext":"2019-Mar-31 entered at 00:29 on 2019-Apr-14  via web","origin":"web","daystamp":"20190331"},{"timestamp":1555189561,"value":0.0,"comment":"initial datapoint of 0.0 on the 13th","id":"5cb24f39bfec0320f2001d8e","updated_at":1555189561,"requestid":null,"canonical":"13 0 \"initial datapoint of 0.0 on the 13th\"","fulltext":"2019-Apr-13 entered at 17:06 ex nihilo","origin":"nihilo","daystamp":"20190413"}]'
  }
  context "with bee_service" do
    describe '#seen_promise?' do
      # let(:promise) {
      #   double('new_promise')
      # }
      let(:slug_text) { 'submit-a-netid-affiliate-request' }
      context "empty_bee_service" do
        let(:empty_bee_service) { bee_service }
        context "without any promises logged" do
          before do
            expect(empty_bee_service).
              to receive(:json_data).and_return(empty_json)
          end
          it 'returns false if the slug+promise is not in json' do
            expect(empty_bee_service.seen_promise?(slug_text)).
              to eq false
          end
        end
      end
      context "bee_service_with_one_seen_promise" do
        let(:visited_bee_service) { bee_service }
        context "with one logged promise" do
          context "and the promise is new" do
            before do
              expect(visited_bee_service).
                to receive(:json_data).and_return(one_seen_promise_json)
            end
            it 'returns true if the slug+promise is in json' do
              expect(visited_bee_service.seen_promise?(slug_text)).
                to eq true
            end
            describe '#seen_completed?' do
              it 'returns false if the slug+success is not in json' do
                expect(visited_bee_service.seen_completed?(slug_text)).
                  to eq false
              end
            end
          end
          context "and the promise is completed" do
            before do
              expect(visited_bee_service).
                to receive(:json_data).and_return(two_seen_one_fulfilled_json)
            end
            describe '#seen_completed?' do
              it 'returns true if the slug+success is in json' do
                expect(visited_bee_service.seen_completed?(slug_text)).
                  to eq true
              end
            end
          end
        end
      end
    end
  end
  context "interface to write beeminder promises and completes" do
    describe '#log_promise' do
      it 'adds a promise with the parameter timestamp and url slug' do
        pending "beeminder gem writes 'promise: goal-slug' with the timestamp"
      end
    end
    describe '#log_completed' do
      it 'adds a success with the parameter timestamp and url slug' do
        pending "beeminder gem writes 'success: goal-slug' with the timestamp"
      end
    end
  end
end
