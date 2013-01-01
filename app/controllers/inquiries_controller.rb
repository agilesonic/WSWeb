class InquiriesController < ApplicationController
  def new
    @inquiry = @inquiry || Inquiry.new
  end

  def create
    @inquiry = Inquiry.new(params[:inquiry])
    if @inquiry.valid?
      render :confirm
    else
      render :new
    end
  end
end
