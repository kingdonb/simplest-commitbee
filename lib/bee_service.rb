class BeeService
  attr_reader :username, :access_token
  def initialize(username:, access_token:)
    @username = username
    @access_token = access_token
  end
end
