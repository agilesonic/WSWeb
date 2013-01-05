class LoginValidator < ActiveModel::Validator
  def validate(login_form)
    unless login_form.email = 'yguobin@hotmail.com'
      login_form.errors << 'The login info does not match our record.'
    end
  end  
end

class LoginForm < BaseModel

  attr_accessor :email, :password
  validates_presence_of :email, :password
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :unless => Proc.new { |f| f.errors.any? }
  validates_with LoginValidator, :unless => Proc.new { |f| f.errors.any? }

end