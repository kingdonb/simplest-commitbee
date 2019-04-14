require 'commit_service'

RSpec.describe CommitService, '#update' do
  context 'with help from the BeeService class' do
    context 'a new promise is detected' do
      it "gets the timestamp when a new promise is observed" do
        pending "BeeService tells whether the promise has been logged"
      end
      it "adds the new promise through BeeService" do
        pending "BeeService tells whether the promise has been logged"
      end
      it "adds a point for the completed promise" do
        pending "BeeService tells whether the completion has been logged"
      end
    end
    context 'no new promise is detected' do
      it "noops when the commit data hasn't changed" do
        pending "BeeService tells whether the promise has been logged"
      end
      it "noops when the completion is already recorded" do
        pending "BeeService tells whether the completion has been logged"
      end
    end
  end
end
