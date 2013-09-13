

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
    @id=params[:id]
    @ws=Workschedule.find @id
    date=@ws.profiledate
    hrid=@ws.HRID
    @shour=@ws.stime.hour
    @smin=@ws.stime.min
    @fhour=@ws.ftime.hour
    @fmin=@ws.ftime.min
    @rate='15.00'
    @rate=@rate.to_f
    min_rate=@rate/60
    @rate=@rate.to_s
    puts 'shour',@shour
    puts 'smin',@smin

    puts 'fhour',@fhour
    puts 'fmin',@fmin

    shour1=HomeHelper.pad_num2 @shour
    smin1=HomeHelper.pad_num2 @smin
    fhour1=HomeHelper.pad_num2 @shour
    fmin1=HomeHelper.pad_num2 @fmin
    
    @selected_shour=HomeHelper.pad_num2 @shour
    @selected_smin=HomeHelper.pad_num2 @smin
    @selected_fhour=HomeHelper.pad_num2 @fhour
    @selected_fmin=HomeHelper.pad_num2 @fmin
#************************************************************************
    if smin1[1..1].to_i<5
      @selected_smin=smin1[0..0].concat('0')
    elsif smin1.to_i<=50 && smin1[1..1].to_i>5
      jj=smin1.to_i+10
      jj=HomeHelper.pad_num2 jj
      @selected_smin=jj[0..0].concat('0')
    elsif smin1.to_i>50 && smin1[1..1].to_i>5
      jj=shour1.to_i+1
      #jj=HomeHelper.pad_num2 jj
      @selected_shour=jj
      @selected_smin='0'
    end

    if fmin1[1..1].to_i<5
      @selected_fmin=fmin1[0..0].concat('0')
    elsif fmin1.to_i<=50 && fmin1[1..1].to_i>5
      jj=fmin1.to_i+10
      jj=HomeHelper.pad_num2 jj
      @selected_fmin=jj[0..0].concat('0')
    elsif fmin1.to_i>50 && fmin1[1..1].to_i>5
      jj=fhour1.to_i+1
      #jj=HomeHelper.pad_num2 jj
      @selected_fhour=jj
      @selected_fmin='0'
    end
#************************************************************************

    @selected_shour5=@selected_shour.to_i.to_s
    @selected_smin5=@selected_smin.to_i.to_s
    @selected_fhour5=@selected_fhour.to_i.to_s
    @selected_fmin5=@selected_fmin.to_i.to_s


        
    stotal_min=@selected_shour.to_i*60+@selected_smin.to_i
    ftotal_min=@selected_fhour.to_i*60+@selected_fmin.to_i
    
    total_min=ftotal_min-stotal_min
    @pay=total_min*min_rate
    
    @hr_pay, @min_pay=total_min.divmod 60
    puts 'Hr_Pay', @hr_pay
    puts 'Min_Pay', @min_pay
    puts 'PAY',@pay
    @hr_pay=HomeHelper.pad_num2 @hr_pay
    @min_pay=HomeHelper.pad_num2 @min_pay
    @hours=@hr_pay.to_s.concat(':').concat(@min_pay.to_s)
    
    @hours=total_min/60.to_f
    @hours=(@hours*100).round / 100.0
    @rate='15.00'
    @pay=@hours*@rate.to_f

    
    
    names=Employee.just_name_from_id hrid
    @name=names.first
    #date=Date.parse('2013-08-27')

    @call_log=HomeHelper.generate_calllog hrid, date
    @record_pay_form=RecordPayForm.new
    @hour_options=HomeHelper::HOURS
    @min_options=HomeHelper::MIN
  end 
  
  def savepay
    rpf=params[:record_pay_form]
    puts 'Form*****************'
    rpf.each do |k,v|
      puts k,v
    end
    id=rpf[:id]
    @ws=Workschedule.find id
    shr=params[:shr]  
    smin=params[:smin]  
    fhr=params[:fhr]  
    fmin=params[:fmin]
    hours=rpf[:hours]
    rate=rpf[:rate]
    rate=rate[1..rate.length]
    pay=rpf[:pay]
    pay=pay[1..pay.length]
    notes=rpf[:notes]
    @ws.stime=shr.concat(':').concat(smin).concat(':00')
    @ws.ftime=fhr.concat(':').concat(fmin).concat(':00')
    @ws.hours=hours
    @ws.rate=rate
    @ws.pay=pay
    @ws.notes=notes
    @ws.type5='Office'
    @ws.save!
    redirect_to verpay_employees_url
  end
   
end