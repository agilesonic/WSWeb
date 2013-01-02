class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def emailFromTemplate(template, params)
    template_path = File.expand_path('../../email_templates/' + template, __FILE__);
    content = File.open(template_path, "r").read
    params.each do |k, v|
      content.gsub! '<%' + k.to_s + '%>', v
    end
    return content
  end  
end
