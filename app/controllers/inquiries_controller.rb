class InquiriesController < ApplicationController
  def new
    @inquiry_form = InquiryForm.new
  end

  def create
    @inquiry_form = InquiryForm.new(params[:inquiry])
    if @inquiry_form.valid?
      AppMailer.inquiry_mail(@inquiry_form).deliver
      render :confirm
    else
      render :new
    end
  end
  

end
