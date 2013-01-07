class ProfileValidator < ActiveModel::Validator
  def validate(profile_form)
    if profile_form.new_password != profile_form.new_password_confirm
      profile_form.errors[:new_password_confirm] << 'Password and Confirm Password does not match.'
    end
  end  
end

class ProfileForm < BaseForm
  
  attr_accessor :email, :current_password, :new_password, :new_password_confirm
  
  validates_presence_of :email, :current_password, :new_password, :new_password_confirm
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :unless => "email.empty?"
  validates_length_of :new_password, :minimum => 6, :too_short => "Password must be at least %d characters."
  validates_length_of :new_password_confirm, :minimum => 6, :too_short => "Password must be at least %d characters."
  validates_with ProfileValidator, :unless => Proc.new { |f| f.errors.any? }
  
end