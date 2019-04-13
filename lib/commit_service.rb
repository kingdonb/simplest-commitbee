class CommitService
  attr_reader :username
  def initialize(username)
    @username = username
  end
  def update(bee)
    # binding.pry
    raise StandardError, "making sure test fails"
  end
end
