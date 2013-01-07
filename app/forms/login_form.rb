class LoginForm < BaseForm

  attr_accessor :email, :password
  validates_presence_of :email, :password
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :unless => Proc.new { |f| f.errors.any? }

end