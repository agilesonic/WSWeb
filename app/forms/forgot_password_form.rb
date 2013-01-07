class ForgotPasswordValidator < ActiveModel::Validator
  def validate(forgot_password_form)
    if WebUser.by_email(forgot_password_form.email).nil?
      forgot_password_form.errors[:email] << 'This email address does not match our record.'
    end
  end  
end

class ForgotPasswordForm < BaseForm

  attr_accessor :email
  validates_presence_of :email
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :unless => Proc.new { |f| f.errors.any? }
  validates_with ForgotPasswordValidator, :unless => Proc.new { |f| f.errors.any? }

end