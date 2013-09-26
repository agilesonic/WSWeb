

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
  
  def move_params params
      prep_showindpay
      @hrid=params[:hrid]    
      @person=params[:person]
      @selected_syear=params[:syear]
      @selected_smonth=params[:smonth]
      @selected_sday=params[:sday]
      @selected_fyear=params[:fyear]
      @selected_fmonth=params[:fmonth]
      @selected_fday=params[:fday]
      @selected_year5=params[:year5]
      @selected_month5=params[:month5]
      @selected_day5=params[:day5]
      sdate=Date.parse(@selected_syear.concat('-').concat(@selected_smonth).concat('-').concat(@selected_sday))
      fdate=Date.parse(@selected_fyear.concat('-').concat(@selected_fmonth).concat('-').concat(@selected_fday))
  
      @sessions=Workschedule.find_sessions sdate, fdate, @hrid
      @sessions.each do |ws5|
        names=Employee.just_name_from_id ws5.HRID
        ws5.HRID=names.first
      end

  end
    
  
  def recordpay
    @id=params[:id]
    @ws=Workschedule.find @id
    date=@ws.profiledate
    hrid=@ws.HRID
    if(!@ws.stime.nil?)
      @shour=@ws.stime.hour
      @smin=@ws.stime.min
    end
    if(!@ws.ftime.nil?)
      @fhour=@ws.ftime.hour
      @fmin=@ws.ftime.min
    end
    @rate=nil
    @rate='15.00'
    @rate=@rate.to_f
    if @ws.rate!='0.00'
      @rate=@ws.rate
      @rate=@rate.to_f
    end
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
    
    #@hr_pay, 
    #@min_pay=total_min.divmod 60
    #puts 'Hr_Pay', @hr_pay
    #puts 'Min_Pay', @min_pay
    #puts 'PAY',@pay
    #if @hr_pay.nil?
    #  @hr_pay='0.00'
    #else
    #  @hr_pay=HomeHelper.pad_num2 @hr_pay
    #end
    #min_pay=HomeHelper.pad_num2 @min_pay
    #@hours=@hr_pay.to_s.concat(':').concat(@min_pay.to_s)
    
    @hours=total_min/60.to_f
    @hours=(@hours*100).round / 100.0
    @rate='15.00'
    if !@ws.rate.nil? && @ws.rate.to_f>'0.00'.to_f
      @rate=@ws.rate
      @rate=@rate.to_f
    end
    @pay=@hours*@rate.to_f

    
    
    names=Employee.just_name_from_id hrid
    @name=names.first
    #date=Date.parse('2013-08-27')

    @call_log=HomeHelper.generate_calllog hrid, date
    @record_pay_form=RecordPayForm.new
    @hour_options=HomeHelper::HOURS
    @min_options=HomeHelper::MIN
    @source=params[:source]
    if @source=='showindpay'
      move_params params
    end    
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
    source=params[:source]
    if source=='showindpay'
      move_params params
      render 'showindpay'
      return
    else    
      redirect_to verpay_employees_url(:source=>source)
    end  
  end

 #:id => @hrid, :person=>@person, syear=>@selected_syear, :smonth=>@selected_smonth, :sday=>@selected_sday,
 # :fyear=>@selected_fyear, :fmonth=>@selected_fmonth, :fday=>@selected_fday, :source=>'showindpay' 

  def deletepay
    id=params[:id]
    
    ws=Workschedule.find id
    ws.destroy
    
    source=params[:source]
    if source=='showindpay'
      puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   IN RIGHT PLACE'
      move_params params
      render 'showindpay'
      return  
    else
      redirect_to verpay_employees_url
      return
    end    
  end
  
  def prep_showindpay
    @spf=ShowPayForm.new
    @cpf=CreatePayForm.new
    @year_options=HomeHelper::YEARS  
    @month_options=HomeHelper::MONTHS
    @day_options=HomeHelper::DAYS
    d=Date.today.to_s
    @selected_syear=d[0..3]
    month=d[5..6]
    @selected_smonth=HomeHelper.get_month_from_num month
    @selected_sday=d[8..9]
    @selected_fyear=d[0..3]
    @selected_fmonth=HomeHelper.get_month_from_num month
    @selected_fday=d[8..9]
    @selected_year5=d[0..3]
    @selected_month5=HomeHelper.get_month_from_num month
    @selected_day5=d[8..9]
    names=Employee.active_people_only
    @caller_options=[]
    @caller_options<<'Everyone'
    @caller_options<<'Sales'
    @caller_options<<'Crew'
    names.each do |name|
        @caller_options<<name
    end
    
  end 
   
  def showindpay
    prep_showindpay
  end
  
  def showrangepay
    
  end

  
  def indpay
    spf=params[:show_pay_form]
    prep_showindpay
    @person=spf[:person]
    names=Employee.just_id_from_name @person
    @hrid=names.first
    @selected_syear=spf[:syear]
    @selected_smonth=spf[:smonth]
    @selected_sday=spf[:sday]
    @selected_fyear=spf[:fyear]
    @selected_fmonth=spf[:fmonth]
    @selected_fday=spf[:fday]
    sdate=Date.parse(@selected_syear+'-'+@selected_smonth+'-'+@selected_sday)
    fdate=Date.parse(@selected_fyear+'-'+@selected_fmonth+'-'+@selected_fday)

    @sessions=Workschedule.find_sessions sdate, fdate, @hrid
    @sessions.each do |ws5|
      names=Employee.just_name_from_id ws5.HRID
      ws5.HRID=names.first
    end
    
    render 'showindpay'  
  end
  
  def createpay
    cpf=params[:create_pay_form]
    prep_showindpay
    @hrid=cpf[:hrid]    
    @person=cpf[:person]
    @selected_syear=cpf[:syear]
    @selected_smonth=cpf[:smonth]
    @selected_sday=cpf[:sday]
    @selected_fyear=cpf[:fyear]
    @selected_fmonth=cpf[:fmonth]
    @selected_fday=cpf[:fday]
    @selected_year5=cpf[:year5]
    @selected_month5=cpf[:month5]
    @selected_day5=cpf[:day5]
    date=Date.parse(@selected_year5+'-'+@selected_month5+'-'+@selected_day5)
    ws=Workschedule.new
    ws.profiledate=date
    ws.HRID=@hrid
    ws.save

    sdate=Date.parse(@selected_syear+'-'+@selected_smonth+'-'+@selected_sday)
    fdate=Date.parse(@selected_fyear+'-'+@selected_fmonth+'-'+@selected_fday)

    @sessions=Workschedule.find_sessions sdate, fdate, @hrid
    @sessions.each do |ws5|
      names=Employee.just_name_from_id ws5.HRID
      ws5.HRID=names.first
    end
    render 'showindpay'  
  end

  def back_rangepay
    source=params[:source]
    if source=='showindpay'
      move_params params
      render 'showindpay'
      return
    end  
  end
  
  def back_verpay
    redirect_to verpay_employees_url
  end

  def recruiting_menu
    
  end
   
  def recruiters
    @recsupps= Recsupp.get_recruiters
  end  
  
  def recruits
    @recs=[]
    recs= Recruit.get_recruits
    recs.each do |rec|
      rb=RecruitBundle.new
#      date=Date.parse((rec.year).concat('-').concat(rec.month).concat('-').concat(rec.day))
      rb.date=rec.date  
      rb.source=rec.source
      rb.name=rec.name
      rb.address=rec.address
      rb.shop=rec.shop
      rb.phone=rec.phone
      rb.phone1=rec.phone1
      rb.email=rec.email
      rb.drive=rec.drive
      rb.ladder=rec.ladder
      rb.id=rec.id
      rb.status=rec.status
      calls=Reccontact.calls_to_recruit(rec.id)
      if calls.size!=0
        call=calls.last
        rb.category=call.category
        rb.catdate=call.actiondate
      end
      @recs<<rb
     end
  end  


  def new_recruiters
    @new_recruiters_form=NewRecruitersForm.new
    @recsupps= Recsupp.get_recruiters
  end  
  
  def new_recruits
    @new_recruit_form=NewRecruitForm.new
    @recs= Recruit.get_recruits
    @year_options=HomeHelper::YEARS  
    @month_options=HomeHelper::MONTHS
    @day_options=HomeHelper::DAYS
    d=Date.today.to_s
    month=d[5..6]
    @selected_year=d[0..3]
    @selected_month=HomeHelper.get_month_from_num month
    @selected_day=d[8..9]
    @source_options=HomeHelper::SOURCE
    @shop_options=HomeHelper::SHOP
    @drive_options=HomeHelper::DRIVE
    @ladder_options=HomeHelper::LADDER
    @source_options=[]
    @recsupps= Recsupp.get_recruiters
    @recsupps.each do |r|
      @source_options<<r.company
    end
  end
 
 
  def save_recruiter
    nrf=params[:new_recruiters_form]
    rec=Recsupp.new
    rec.company=nrf[:company]
    rec.name=nrf[:name]
    rec.phone=nrf[:phone]
    rec.email=nrf[:email1].concat('@').concat(nrf[:email2]).concat('.').concat(nrf[:email3])
    rec.offphone=nrf[:offphone]
    rec.offext=nrf[:offext]
    rec.fax=nrf[:fax]
    rec.assname=nrf[:assname]
    rec.assphone=nrf[:assphone]
    rec.save
    redirect_to new_recruiters_employees_url
  end  


#:year, :month, :day, :source, :name, :address, :shop, :phone, :email1, :email2, :email3, :drive, :ladder
  def save_recruit
    nrf=params[:new_recruit_form]
    rec=Recruit.new
    @selected_year=nrf[:year]
    @selected_month=nrf[:month]
    @selected_day=nrf[:day]
    date=Date.parse(@selected_year.concat('-').concat(@selected_month).concat('-').concat(@selected_day))
    rec.date=date  
    rec.source=nrf[:source]
    rec.name=nrf[:name]
    rec.address=nrf[:address]
    rec.shop=nrf[:shop]
    rec.phone=nrf[:phone]
    rec.phone1=nrf[:phone1]
    rec.email=nrf[:email1].concat('@').concat(nrf[:email2]).concat('.').concat(nrf[:email3])
    rec.drive=nrf[:drive]
    rec.ladder=nrf[:ladder]
    rec.status='B'
    rec.save
    redirect_to new_recruits_employees_url
  end  
  
  def delete_recruiter
    @rec= Recsupp.find(params[:id])
    @rec.destroy
    redirect_to recruiters_employees_url
  end  
     
  def delete_recruit
    @rec= Recruit.find(params[:id])
    @rec.destroy
    redirect_to recruits_employees_url
  end  
     
  def edit_recruit
    @rec=Recruit.find(params[:id])
    @edit_recruit_form=NewRecruitForm.new
    @year_options=HomeHelper::YEARS  
    @month_options=HomeHelper::MONTHS
    @day_options=HomeHelper::DAYS
    d=Date.today.to_s
    month=d[5..6]
    @selected_year=d[0..3]
    @selected_month=HomeHelper.get_month_from_num month
    @selected_day=d[8..9]
    @source_options=HomeHelper::SOURCE
    @shop_options=HomeHelper::SHOP
    @drive_options=HomeHelper::DRIVE
    @ladder_options=HomeHelper::LADDER
    @status_options=HomeHelper::STATUS
    @source_options=[]
    @recsupps= Recsupp.get_recruiters
    @recsupps.each do |r|
      @source_options<<r.company
    end
    @selected_name=@rec.name
    @selected_address=@rec.address
    @selected_phone=@rec.phone
    @selected_phone1=@rec.phone1
    @selected_ladder=@rec.ladder
    @selected_email=@rec.email
    @selected_status=@rec.status
    @selected_id=@rec.id
  end  

  def save_edit_recruit
    erf=params[:new_recruit_form]
    rec=Recruit.find(erf[:id])
    @selected_year=erf[:year]
    @selected_month=erf[:month]
    @selected_day=erf[:day]
    date=Date.parse(@selected_year.concat('-').concat(@selected_month).concat('-').concat(@selected_day))
    rec.date=date  
    rec.source=erf[:source]
    rec.name=erf[:name]
    rec.address=erf[:address]
    rec.shop=erf[:shop]
    rec.phone=erf[:phone]
    rec.phone1=erf[:phone1]
    rec.email=erf[:email1]
    rec.drive=erf[:drive]
    rec.ladder=erf[:ladder]
    rec.status=erf[:status]
    rec.save
    redirect_to recruits_employees_url
  end
     
  def call_recruit
    @id=params[:id]
    @rec=Recruit.find(@id)
    @call_recruit_form=CallRecruitForm.new
    @rec=Recruit.find(params[:id])
    @edit_recruit_form=NewRecruitForm.new
    @year_options=HomeHelper::YEARS  
    @month_options=HomeHelper::MONTHS
    @day_options=HomeHelper::DAYS
    d=Date.today.to_s
    month=d[5..6]
    @selected_year=d[0..3]
    @selected_month=HomeHelper.get_month_from_num month
    @selected_day=d[8..9]
    @category_options=HomeHelper::RECCALL
    @calls=Reccontact.calls_to_recruit(@id)
  end  

  def save_call_recruit
    crf=params[:call_recruit_form]
    rec=Reccontact.new
    rec.recruit=crf[:id]
    @selected_year=crf[:year]
    @selected_month=crf[:month]
    @selected_day=crf[:day]
    date=Date.parse(@selected_year.concat('-').concat(@selected_month).concat('-').concat(@selected_day))
    rec.date=date
    rec.category=crf[:category] 
    rec.notes=crf[:notes] 
    @selected_year=crf[:actionyear]
    @selected_month=crf[:actionmonth]
    @selected_day=crf[:actionday]
    actiondate=Date.parse(@selected_year.concat('-').concat(@selected_month).concat('-').concat(@selected_day))
    rec.actiondate=actiondate
    rec.save
    redirect_to recruits_employees_url
  end  

      
end