module ApplicationHelper
  def field_error(field, errors)
    errors && !errors.empty? ? (field.to_s + ' ' + errors.first).html_safe : '' 
  end
  
end
