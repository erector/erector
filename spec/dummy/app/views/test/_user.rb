class Views::Test::User < Erector::Widget
  needs :user

  def content
    text @user
  end
end
