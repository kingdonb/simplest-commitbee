require 'bee_service'

RSpec.describe BeeService do
  let(:empty_json) {
    '[{"timestamp":1555189561,"value":0.0,"comment":"initial datapoint of 0.0 on the 13th","id":"5cb24f39bfec0320f2001d8e","updated_at":1555189561,"requestid":null,"canonical":"13 0 \"initial datapoint of 0.0 on the 13th\"","fulltext":"2019-Apr-13 entered at 17:06 ex nihilo","origin": "nihilo","daystamp":"20190413"}]'
  }
  let(:empty_bee_service) {
    expect_any_instance_of(BeeService).
      to receive(:validate_json).and_return(nil)
    expect_any_instance_of(BeeService).
      to receive(:json_data).and_return(empty_json)
    expect(File).to receive(:read).
      with('').and_return(double('file'))
    BeeService.new(username:'dreev',
                   access_token:'NoAccessTokenHere',
                   json_filename:'')
  }
  describe '#seen_promise?' do
    let(:new_promise) {
      double('new_promise')
    }
    it 'returns true if the slug+promise is in json' do
      pending
    end
    it 'returns false if the slug+promise is not in json' do
      expect(empty_bee_service.seen_promise?(new_promise)).
        to eq false
    end
  end
  describe '#seen_completed?' do
    it 'returns true if the slug+success is in json' do
      pending
    end
    it 'returns false if the slug+success is not in json' do
      pending
    end
  end
  describe '#log_promise' do
    it 'adds a promise with the parameter timestamp and url slug' do
      pending
    end
  end
  describe '#log_completed' do
    it 'adds a success with the parameter timestamp and url slug' do
      pending
    end
  end
end
