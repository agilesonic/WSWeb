module ApplicationHelper
  def field_error(field, errors)
    errors && !errors.empty? ? field.to_s + ' ' + errors.first : '' 
  end
end
