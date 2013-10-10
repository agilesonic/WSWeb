

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
  
  def show_recruits
    @show_recruits_form=ShowRecruitsForm.new
    @training_options=[]
    @training_options<<'none'
    @trainings= Training.find_trainings
    @trainings.each do |t|
      @training_options<<t.tdate.to_s
    end
    @status_options=['All']
    s1=HomeHelper::RECCALL
    s1.each do |s|
      @status_options<<s
    end
  end
  
  def recruits
    srf=params[:show_recruits_form]
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
      if rec.training.nil?
        rb.training='none'
      else  
        rb.training=rec.training
      end
      
      calls=Reccontact.calls_to_recruit(rec.id)
      if calls.size!=0
        call=calls.last
        rb.category=call.category
        rb.catdate=call.actiondate
      end
      if srf[:status]=='All'
        @recs<<rb
      elsif srf[:status]==rb.category && srf[:training]==rb.training
        @recs<<rb
      end
      
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
    redirect_to show_recruits_employees_url
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

    @training_options=[]
    @training_options<<'none'
    @trainings= Training.find_trainings
    @trainings.each do |t|
      @training_options<<t.tdate.to_s
    end

    @selected_name=@rec.name
    @selected_address=@rec.address
    @selected_phone=@rec.phone
    @selected_phone1=@rec.phone1
    @selected_ladder=@rec.ladder
    @selected_email=@rec.email
    @selected_status=@rec.status
    @selected_training=@rec.training
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
    if erf[:training].nil?
      rec.training=nil
    else
      rec.training=erf[:training]
    end
    rec.save!
    redirect_to show_recruits_employees_url
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
    rec.save!
    redirect_to show_recruits_employees_url
  end  
  
  def make_schedule
    @make_schedule_form=MakeScheduleForm.new
    @year_options=HomeHelper::YEARS  
    @month_options=HomeHelper::MONTHS
    @day_options=HomeHelper::DAYS
    d=Date.today.to_s
    month=d[5..6]
    @selected_year=d[0..3]
    @selected_month=HomeHelper.get_month_from_num month
    @selected_day=d[8..9]

    @checked_same=true
    @checked_next=false
    

    year=params[:year]
    if !year.nil?
      @selected_year=year[0..3]
      @selected_month=HomeHelper.get_num_from_month params[:month]
      @selected_day=params[:day]
      date=Date.parse(@selected_year.concat('-').concat(@selected_month).concat('-').concat(@selected_day))
      @selected_month=HomeHelper.get_month_from_num month
      if params[:nextday]=='next'   
        date=date+1
        date=date.to_s
        puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',year
        month=date[5..6]
        @selected_year=date[0..3]
        @selected_month=HomeHelper.get_month_from_num month
        @selected_day=date[8..9]
        @checked_same=false
        @checked_next=true
      end
    end

    @office_options=HomeHelper::OFFICE_OPTIONS
    @times_options=HomeHelper::TIMES_OPTIONS
    @sched5=Schedule.get_schedule
    @username=session[:username]
    @sched=[]
    sched=HomeHelper.sort_schedule @sched5, @username
    #puts 'HI HO HI HO HI HO',sched.size 
    sched.each do |ws| 
         if (ws.date-Date.today).to_i>=0
           @sched<<ws
         end
    end
  end
  
  # attr_accessor :year, :month, :day, :conn, :voicemail, :payments, :recble15, :recble30, :recble45, :gth, :estsigns 

  
  def save_schedule
    msf=params[:make_schedule_form]
    sched=Schedule.new
    tasks=''
    @selected_year=msf[:year]
    x=msf[:year]
    puts '555555555555555555555555555555555',x
    @selected_month=msf[:month]
    @selected_day=msf[:day]
    date=Date.parse(@selected_year.concat('-').concat(@selected_month).concat('-').concat(@selected_day))
    sched.date=date
    if msf[:open]=='1'
      tasks+='Open//'
    end
    if msf[:line1]=='1'
      tasks+='Line 1//'
    end
    if msf[:otherlines]=='1'
      tasks+='Line 2+//'
    end
    if msf[:conn]=='1'
      tasks+='Conn Calls//'
    end
    if msf[:voicemail]=='1'
      tasks+='Voice Mail//'
    end
    if msf[:voicemailw]=='1'
      tasks+='Voice Mail Wknd//'
    end
    if msf[:emails]=='1'
      tasks+='Check Emails//'
    end
    if msf[:recble15]=='1'
      tasks+='Recble15//'
    end
    if msf[:recble30]=='1'
      tasks+='Recble30//'
    end
    if msf[:recble45]=='1'
      tasks+='Recble45//'
    end
    if msf[:payments]=='1'
      tasks+='Process Payments//'
    end
    if msf[:sats]=='1'
      tasks+='Sats//'
    end
    if msf[:gth]=='1'
      tasks+='GTH//'
    end
    if msf[:estsigns]=='1'
      tasks+='Ests Signs//'
    end
    if msf[:getmail]=='1'
      tasks+='Get Mail//'
    end
    if msf[:newsletter]=='1'
      tasks+='Newsletter//'
    end
    if msf[:close]=='1'
      tasks+='Close//'
    end
    
    notes=msf[:notes]
    sched.tasks=tasks
    sched.notes=notes
    sched.stime=msf[:stime]
    sched.ftime=msf[:ftime]
    person=msf[:person]
    ids=Employee.just_id_from_name person
    id=ids.first
    sched.hrid=id
    sched.save
    nextday=msf[:nextday]
    redirect_to make_schedule_employees_url(:year=>msf[:year], :month=>msf[:month], :day=>msf[:day], :nextday=>nextday)
  end

  def deleteschedule
    id=params[:id]
    sched=Schedule.find id
    sched.destroy
    redirect_to make_schedule_employees_url
  end
  
  def show_schedule
    @spf=ShowPayForm.new
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
    @caller_options=[]
    @caller_options<<'Everyone'
    @office_options=HomeHelper::OFFICE_OPTIONS
    @office_options.each do |emp|
      @caller_options<<emp
    end
  end
  
  def schedule
    spf=params[:show_pay_form]

    @selected_syear=spf[:syear]
    @selected_smonth=spf[:smonth]
    @selected_sday=spf[:sday]
    @selected_fyear=spf[:fyear]
    @selected_fmonth=spf[:fmonth]
    @selected_fday=spf[:fday]
    sdate=Date.parse(@selected_syear+'-'+@selected_smonth+'-'+@selected_sday)
    fdate=Date.parse(@selected_fyear+'-'+@selected_fmonth+'-'+@selected_fday)

    @person=spf[:person]
    @sched=[]
    if @person=='Everyone'
      @sched=Schedule.get_schedule_all sdate, fdate
    else
      names=Employee.just_id_from_name @person
      @hrid=names.first
      @sched=Schedule.get_schedule_ind @hrid, sdate, fdate
    end
    @sched.each do |ws|
      names=Employee.just_name_from_id ws.hrid
      ws.hrid=names.first
    end
    @username=session[:username]
    @sched=HomeHelper.sort_schedule @sched, @username
  end
  
  def show_training
    @make_training_form=MakeTrainingForm.new
    @year_options=HomeHelper::YEARS  
    @month_options=HomeHelper::MONTHS
    @day_options=HomeHelper::DAYS
    d=Date.today.to_s
    @selected_syear=d[0..3]
    month=d[5..6]
    @selected_smonth=HomeHelper.get_month_from_num month
    @selected_sday=d[8..9]
    @trainings=Training.find_trainings
  end   

  def save_training
    mtf=params[:make_training_form]
    year=mtf[:year]
    month=mtf[:month]
    day=mtf[:day]
    t=Training.new
    t.tdate=Date.parse(year+'-'+month+'-'+day)
    t.save!
    redirect_to show_training_employees_url
  end
  
  def delete_training
    id=params[:id]
    t=Training.find id
    t.destroy
    redirect_to show_training_employees_url
  end
   
end



