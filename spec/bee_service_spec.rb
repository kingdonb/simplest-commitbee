require 'bee_service'
# require 'pry'

RSpec.describe BeeService do
  before do
    expect_any_instance_of(BeeService).
      to receive(:validate_json).and_return(nil)
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
  context "with bee_service" do
    describe '#seen_promise?' do
      let(:promise) {
        double('new_promise')
      }
      context "empty_bee_service" do
        let(:empty_bee_service) { bee_service }
        context "without any promises logged" do
          before do
            expect(empty_bee_service).
              to receive(:json_data).and_return(empty_json)
          end
          it 'returns false if the slug+promise is not in json' do
            expect(empty_bee_service.seen_promise?(promise)).
              to eq false
          end
        end
      end
      context "bee_service_with_one_seen_promise" do
        let(:visited_bee_service) { bee_service }
        context "with one logged promise" do
          it 'returns true if the slug+promise is in json' do
            pending "manually log a promise slug and created timestamp"
          end
          describe '#seen_completed?' do
            it 'returns false if the slug+success is not in json' do
              pending "the promise is logged but tfin is not yet recorded"
            end
          end
          context "and the promise is completed" do
            describe '#seen_completed?' do
              it 'returns true if the slug+success is in json' do
                pending "manually log a success slug and tfin fulfilled stamp"
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
