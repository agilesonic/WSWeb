class EmployeesController <  ApplicationController
  layout "application1"

  def verpay
    @open_sessions=Workschedule.find_open_sessions
    @open_sessions.each do |ws|
      names=Employee.just_name_from_id ws.HRID
      ws.HRID=names.first
    end
    @closed_sessions=Workschedule.find_closed_sessions
    @closed_sessions.each do |ws5|
      names=Employee.just_name_from_id ws5.HRID
      ws5.HRID=names.first
    end
  end
  
  def recordpay
    id=params[:id]
    @ws=Workschedule.find id
    date=@ws.profiledate
    hrid=@ws.HRID
    @shour=@ws.stime.hour
    @smin=@ws.stime.min
    @fhour=@ws.ftime.hour
    @fmin=@ws.ftime.min
    @rate=15
    @rate=@rate.to_f
    min_rate=@rate/60
    @rate=@rate.to_s
    puts 'shour',@shour
    puts 'smin',@smin

    puts 'fhour',@fhour
    puts 'fmin',@fmin
    
    stotal_min=@shour*60+@smin
    ftotal_min=@fhour*60+@fmin
    
    total_min=ftotal_min-stotal_min
    @pay=total_min*min_rate
    
    @hr_pay, @min_pay=total_min.divmod 60
    puts 'Hr_Pay', @hr_pay
    puts 'Min_Pay', @min_pay
    puts 'PAY',@pay
    @hr_pay=HomeHelper.pad_num2 @hr_pay
    @min_pay=HomeHelper.pad_num2 @min_pay
    @hours=@hr_pay.to_s.concat(':').concat(@min_pay.to_s)
    
    
    names=Employee.just_name_from_id hrid
    @name=names.first
    date=Date.parse('2013-08-27')

    @call_log=HomeHelper.generate_calllog 'HR00005404', date
    puts 'HRID', hrid
    puts 'Date', date
    puts 'size', @call_log.size
    @record_pay_form=RecordPayForm.new
    @hour_options=HomeHelper::HOURS
    @min_options=HomeHelper::MIN
  end 
  
  def savepay
    render 'verpay'
  end
   
end