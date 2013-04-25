require 'date'

class SalesController < ApplicationController
  layout "application1"
  protect_from_forgery

  def callprofile
    @cp_form=CallProfileForm.new
    cc=Convertcalls.select(:hrid).uniq
    @caller_options=[]
    cc.each do |c|
      if !c.hrid.nil?
        emp=Employee.name_from_id c.hrid
        @caller_options<<emp.first.name
      end
    end
    @year_options=HomeHelper::YEARS
    @month_options=HomeHelper::MONTHS
    @day_options=HomeHelper::DAYS
  end

  def callprofile1
    cp=CallProfileForm.new(params[:call_profile_form])
    #sdate=Date.parse(cp_form.smonth.to_s +' '+ cp_form.sday.to_s+', '+ cp_form.syear.to_s)
    #fdate=Date.parse(cp_form.fmonth.to_s +' '+ cp_form.fday.to_s+', '+ cp_form.fyear.to_s)
    sdate=Date.parse(cp.smonth.to_s+' '+cp.sday.to_s+', '+cp.syear.to_s)
    fdate=Date.parse(cp.fmonth.to_s+' '+cp.fday.to_s+', '+cp.fyear.to_s)
    name=cp.caller
    emps=Employee.find_by_name name
    puts 'EHEHEHEHEH',emps.first.HRID

  end 
   
  def findclients
    @find_client_form=FindClientForm.new
    @profile_options=HomeHelper::PROFILE_OPTIONS
    cc=Convertcalls.select(:hrid).uniq
    @callers=[]
    cb=CallerBundle.new
    cb.name='Unassigned'
    cb.num=Convertcalls.search_unassigned
        cb.fourseven=Convertcalls.search_unassigned_fourseven     
        cb.fourfive=Convertcalls.search_unassigned_fourfive    
        cb.fourthree=Convertcalls.search_unassigned_fourthree    
        cb.fourone=Convertcalls.search_unassigned_fourone 
        cb.threenine=Convertcalls.search_unassigned_threenine 
        cb.threesix=Convertcalls.search_unassigned_threesix 
        cb.newests=Convertcalls.search_unassigned_newestimates 
    @callers<<cb
    cc.each do |c|
      if !c.hrid.nil?
        cb=CallerBundle.new
        emp=Employee.name_from_id c.hrid
        cb.name=emp.first.name
        cb.num=Convertcalls.search_assigned_by_holder c.hrid
        cb.fourseven=Convertcalls.search_assigned_by_holder_fourseven c.hrid    
        cb.fourfive=Convertcalls.search_assigned_by_holder_fourfive c.hrid    
        cb.fourthree=Convertcalls.search_assigned_by_holder_fourthree c.hrid    
        cb.fourone=Convertcalls.search_assigned_by_holder_fourone c.hrid    
        cb.threenine=Convertcalls.search_assigned_by_holder_threenine c.hrid    
        cb.threesix=Convertcalls.search_assigned_by_holder_threesix c.hrid    
        cb.newests=Convertcalls.search_assigned_by_holder_newestimates c.hrid    
        cb.lastsummer=Convertcalls.search_assigned_by_holder_lastsummer c.hrid    
        @callers<<cb
      end
    end
  end
  
  def searchclients
    fcf=FindClientForm.new(params[:find_client_form])
    session[:assprofile]=fcf.profile
    if fcf.lowcf!=''
      fcf.lowcf=HomeHelper.pad_id_num('CF',fcf.lowcf)
    end
    
    session[:asslowcf]=fcf.lowcf
    session[:asslimit]=fcf.limit
    @cc=[]
  #    PROFILE_OPTIONS=['4.1+ clients', 'Used Us Last Summer']
    if fcf.profile=='4.0=>4.1 clients'
      @cc=Convertcalls.available_ratingsfourpointone fcf.lowcf, fcf.limit
    elsif fcf.profile=='4.2=>4.3 clients'
      @cc=Convertcalls.available_ratingsfourpointthree  fcf.lowcf, fcf.limit
    elsif fcf.profile=='4.4=>4.5 clients'
      @cc=Convertcalls.available_ratingsfourpointfive  fcf.lowcf, fcf.limit
    elsif fcf.profile=='4.6=>4.7 clients'
      @cc=Convertcalls.available_ratingsfourpointseven  fcf.lowcf, fcf.limit
    elsif fcf.profile=='3.7=>3.9 clients'
      @cc=Convertcalls.available_ratingsthreepointnine  fcf.lowcf, fcf.limit
    elsif fcf.profile=='3.3=>3.6 clients'
      @cc=Convertcalls.available_ratingsthreepointsix  fcf.lowcf, fcf.limit
    elsif fcf.profile=='Used Us Last Summer'
      @cc=Convertcalls.available_lastsummer fcf.lowcf, fcf.limit  
    end
    @assign_client_form=AssignClientForm.new
    emps=Employee.active_sales_people
    @salesp_options=[]
    emps.each do|emp|
      @salesp_options<<emp.name
    end        
  end
  
  def assclients
    acf=AssignClientForm.new(params[:assign_client_form])
    profile=session[:assprofile]
    lowcf=session[:asslowcf]
    limit=session[:asslimit]
    cc=[]
  #    PROFILE_OPTIONS=['4.1+ clients', 'Used Us Last Summer']
  #'4.0=>4.1 clients','4.2=>4.3 clients','4.4=>4.5 clients', '4.6=>4.7 clients'
  
    if profile=='4.0=>4.1 clients'
      cc=Convertcalls.available_ratingsfourpointone  lowcf, limit
    elsif profile=='4.2=>4.3 clients'
      cc=Convertcalls.available_ratingsfourpointthree  lowcf, limit
    elsif profile=='4.4=>4.5 clients'
      cc=Convertcalls.available_ratingsfourpointfive  lowcf, limit
    elsif profile=='4.6=>4.7 clients'
      cc=Convertcalls.available_ratingsfourpointseven  lowcf, limit
    elsif profile=='3.7=>3.9 clients'
      cc=Convertcalls.available_ratingsthreepointnine  lowcf, limit
    elsif profile=='3.3=>3.6 clients'
      cc=Convertcalls.available_ratingsthreepointsix  lowcf, limit
    elsif profile=='Used Us Last Summer'
      cc=Convertcalls.available_lastsummer lowcf, limit  
    end
    salesp=acf.salesp
    low=acf.low
    high=acf.high
    emp=Employee.find_by_name salesp
    hrid=emp.first.HRID
    cc_select=cc[low.to_i-1, high.to_i-1]
    cc_select.each do |c|
      c.hrid=hrid
      c.save!
    end
    redirect_to findclients_sales_url    
  end   
  
  def index
    hrid=session[:hrid]    
    @cb=CallerBundle.new
    emp=Employee.name_from_id hrid
    @cb.name=emp.first.name
    @cb.num=Convertcalls.search_assigned_by_holder hrid
    @cb.fourseven=Convertcalls.search_assigned_by_holder_fourseven hrid    
    @cb.fourfive=Convertcalls.search_assigned_by_holder_fourfive hrid    
    @cb.fourthree=Convertcalls.search_assigned_by_holder_fourthree hrid    
    @cb.fourone=Convertcalls.search_assigned_by_holder_fourone hrid    
    @cb.threenine=Convertcalls.search_assigned_by_holder_threenine hrid    
    @cb.threesix=Convertcalls.search_assigned_by_holder_threesix hrid    
    @cb.newests=Convertcalls.search_assigned_by_holder_newestimates hrid    
    @cb.lastsummer=Convertcalls.search_assigned_by_holder_lastsummer hrid    
   
    
    @sales_form=SalesForm.new
    @profile_options=HomeHelper::CONNECTION_OPTIONS
    @lowcf=session[:lowcf]
    @limit=session[:limit] 
    @selected_profile=session[:selected_profile] 
  end
  
  
  def loadclients
    sf=SalesForm.new(params[:sales_form])
    hrid=session[:hrid]
    @cc=Convertcalls.search_ccrange sf.lowcf, sf.limit, hrid, sf.profile, Date.today
    if !@cc.empty?
      cc=@cc.last
      session[:profile] = sf.profile
      if sf.lowcf!=''
        sf.lowcf=HomeHelper.pad_id_num('CF',sf.lowcf)
      end
      session[:lowcf] = sf.lowcf
      session[:highcf] = cc.cfid
      session[:limit] = sf.limit
      session[:selected_profile] = sf.profile
      @count=Convertcalls.count_ccrange cc.cfid, hrid, sf.profile, Date.today
    end
  end   

  def clientlist
    lowcf=session[:lowcf]
    limit=session[:limit]
    hrid=session[:hrid]
    profile=session[:profile]
    @cc=Convertcalls.search_ccrange(lowcf, limit, hrid, profile, Date.today)
    render 'loadclients'
  end

  def nextbatch
  
  
  
  
  
  
  
  
  
  
    @sales_form=SalesForm.new
    @profile_options=HomeHelper::CONNECTION_OPTIONS
    
    cfid=session[:highcf]
    
    cfid=cfid[2,cfid.size]
    cfid=cfid.to_i
    cfid+=1
    cfid=HomeHelper.pad_id_num('CF', cfid)

    session[:lowcf]=cfid
    @lowcf=cfid
    @limit=session[:limit] 
    @selected_profile=session[:selected_profile] 
    render 'index'
  end


  
  def nextclient
    cfid=params[:id]
    @jobid1=params[:jobid1]
    @source=params[:source]
    @function=params[:function]
    lowcf=session[:lowcf]
    limit=session[:limit]
    hrid=session[:hrid]
    profile=session[:profile]
    if(profile=='No Calls')
      clients=Convertcalls.search_ccrange(lowcf, limit.to_i-1, hrid, profile, Date.today)
    else
      clients=Convertcalls.search_ccrange(lowcf, limit, hrid, profile, Date.today)
    end
    i=0
    puts 'CFID**************',cfid
    #puts 'VALUE OF **************',i
    clients.each do |client|
      puts 'LOOP CFID*******',client.cfid
    end    
    clients.each do |client|
      if client.cfid>cfid
        #i+=1
        break
      end
      i+=1
    end
    puts 'Clients size**************',clients.size
    puts 'VALUE OF **************',i
    next_client=clients[i]
    if next_client.nil?
      redirect_to sales_path
      return
    end
    redirect_to clientprofile_function_path(:id => next_client.cfid, :jobid1=>@jobid1, :source=>@source,:function=>@function)
  end

  def previousclient
    cfid=params[:id]
    @jobid1=params[:jobid1]
    @source=params[:source]
    @function=params[:function]
    lowcf=session[:lowcf]
    limit=session[:limit]
    hrid=session[:hrid]
    profile=session[:profile]
    if(profile=='No Calls')
      clients=Convertcalls.search_ccrange(lowcf, limit.to_i-1, hrid, profile, Date.today)
    else
      clients=Convertcalls.search_ccrange(lowcf, limit, hrid, profile, Date.today)
    end
    i=0
    puts 'CFID**************',cfid
    #puts 'VALUE OF **************',i
    clients.each do |client|
      puts 'LOOP CFID*******',client.cfid
    end    
    clients.each do |client|
      i+=1
      if client.cfid>cfid
        i=i-3
        break
      end
    end
    puts 'Clients size**************',clients.size
    puts 'VALUE OF **************',i
    next_client=clients[i]
    if next_client.nil?
      redirect_to sales_path
      return
    end

    redirect_to clientprofile_function_path(:id => next_client.cfid, :jobid1=>@jobid1, :source=>@source,:function=>@function)
  end



 # def callclient
  #  @source=params[:source]
  #  @function=params[:function]
  #  
  #  @cfid=params[:id]
  #  @client=Client.find(@cfid)
  #  @calls=@client.clientcontacts
  #  if !@calls.nil?
  #    @calls.each do |call|
  #      name='unknown'
  #      if !call.caller.nil?
  #        e=Employee.find(call.caller)
  
  #      end
  #      if !e.nil?
  #        call.caller=e.name
  #      else
  #        call.caller=name
  #      end  
  #    end
  #  end
    
  #  @prices_all=HomeHelper.get_props_and_prices(@client)
  #  @x='OK'
  #  @tstatus_options=['SOLD', 'LMM', 'LMP']
  #  @years=HomeHelper::YEARS
  #  @months=HomeHelper::MONTHS
  #  @days=HomeHelper::DAYS
  #  #@cfid=@id
  #  @call_client_form=CallClientForm.new
    
    
    
  #  date=HomeHelper.add_days_to_current_date(1)
  #  date10=HomeHelper.add_days_to_date date,10
  #  dates=date.to_s
  #  date10s=date10.to_s
    
  #  @selected_syear_foll=dates[0,4]
  #  @selected_smonth_foll=HomeHelper.get_month_from_num(dates[5,2]) 
  #  @selected_sday_foll=dates[8,2]
  #  @selected_fyear_foll=date10s[0,4]
  #  @selected_fmonth_foll=HomeHelper.get_month_from_num(date10s[5,2]) 
  #  @selected_fday_foll=date10s[8,2]
  #end
  
  def update_convertcall(cfid, tstatus, followup)
    convcall=Convertcalls.find cfid
    if tstatus=='Pending Summer 2014' || tstatus=='Pending Fall 2013'
      tstatus='Pending'
    end
    if tstatus=='Phone Out Of Service'
      tstatus='Phone OOS'
    end
    
    convcall.laststatus=tstatus
    convcall.followup=followup
    convcall.lastcall=Date.today
    convcall.summcalls=Clientcontact.num_cfcontacts_summer2013 cfid
    convcall.fallcalls=Clientcontact.num_cfcontacts_fall2013 cfid
    convcall.save!
  end

  def deletecontact
    cfid=params[:id]
    jobid1=params[:jobid1]
    source=params[:source]
    function=params[:function]
    
    contacts=Clientcontact.search_cfcontacts cfid
    contact=contacts.last
    contact.destroy
    redirect_to clientprofile_function_url(:id=>cfid, :jobid1=>jobid1, :source => source, :function=>function)
  end

  def deletesale
    #       <td><%= link_to 'Delete Sale', deletesale_sale_path(:jobid => job.jobid, :jobid1=>@jobid1,  :source=>@source, :function=>@function),:style=>"color: yellow"%></td>
    cfid=params[:id]
    jobid=params[:jobid]
    jobid1=params[:jobid1]
    source=params[:source]
    function=params[:function]
    job=Job.find jobid
    job.destroy
    cfmess='Job Deleted Successfully!!!'
    redirect_to clientprofile_function_url(:id=>cfid, :jobid1=>jobid1, :source => source, :function=>function, :cfmess=>cfmess)
  end

  def record_contact(cfid, tstatus, followup,notes)
    cc=Clientcontact.new
    cc.CFID= cfid
    cc.tstatus= tstatus
    cc.notes= notes
    cc.followup= followup
    cc.dateatt= Date.today
    cc.caller= session[:hrid]
    cc.save!
  end
  
  def callclient1
    ccf=CallClientForm.new(params[:call_client_form])
    cfid=params[:id]
    t=Time.now
    year=t.to_s[25..28]
    month=t.to_s[7..9]
    day=t.to_s[4..5]
    curr=Date.parse(month+' '+day+', '+year)
    fu=Date.parse(ccf.month.to_s+' '+ccf.day.to_s+', '+ccf.year.to_s)
    
    record_contact(cfid, ccf.tstatus, fu, ccf.notes)
    update_convertcall(cfid, ccf.tstatus, fu)


    cfmess='Client Call Recorded Successfully!!!'
    redirect_to clientprofile_function_path(:id => cfid,:source=>'callclient',:function=>'callclient',:cfmess=>cfmess)
  end
 
  def makesale
    @jobinfoid=params[:jobinfoid]
    @source=params[:source]
    @function=params[:function]
    @jobid1=params[:jobid1]
    @nosale=params[:nosale]
    props=Property.get_property_from_jobinfoid @jobinfoid
    prop=props[0]
    @cfid=prop.CFID
    @csf_form=CreateSaleForm.new
    @ppr=PropPrices.new
    @ppr.id=prop.id
    c=Client.find prop.CFID
    @ppr.client= c.honorific+' '+c.firstname+' '+c.lastname
    @ppr.address=prop.address
    @prices=prop.prices
    if !@prices.nil?
      @prices.each do |price5|
        if price5.JobType.eql? 'W1' then
          @ppr.w1=price5.price
        elsif price5.JobType.eql? 'W2' then
          @ppr.w2=price5.price 
        elsif price5.JobType.eql? 'EH' then
          @ppr.eh=price5.price 
        elsif price5.JobType.eql? 'EG' then
          @ppr.eg=price5.price 
        end
      end
    end  
    
    @syear_options=HomeHelper::YEARS
    @smonth_options=HomeHelper::MONTHS
    @sday_options=HomeHelper::DAYS
    
    @fyear_options=HomeHelper::YEARS
    @fmonth_options=HomeHelper::MONTHS
    @fday_options=HomeHelper::DAYS

    date=HomeHelper.add_days_to_current_date(1)
    date10=HomeHelper.add_days_to_date date,10
    date30=HomeHelper.add_days_to_date date,30
    dates=date.to_s
    date10s=date10.to_s
    date30s=date30.to_s
    
    @selected_syear=dates[0,4]
    @selected_smonth=HomeHelper.get_month_from_num(dates[5,2]) 
    @selected_sday=dates[8,2]
    @selected_fyear=date10s[0,4]
    @selected_fmonth=HomeHelper.get_month_from_num(date10s[5,2]) 
    @selected_fday=date10s[8,2]
    
    @stime_options=HomeHelper::STIME
    @cagenum_options=HomeHelper::CAGES   
    @sbs=[]
    d1=date
    d2=date30
#    d1=Date.parse('Mar 22, 2013')
#    d2=Date.parse('Mar 31, 2013')
  
    while d1!=d2 do
      sb=ScheduleBundle.new
      sb=HomeHelper.schedule_bean d1
      @sbs<<sb
      d1=HomeHelper.add_days_to_date(d1,1) 
    end
  end

  def modifysale
    puts 'IN EDIT SALE *************'
    @source=params[:source]
    @function=params[:function]
    @jobid=params[:jobid]
    @jobid1=params[:jobid1]
    @job=Job.find @jobid
    @nosale=params[:nosale]
    props=Property.get_property_from_jobinfoid @job.JobInfoID
    prop=props[0]
    puts 'PPPRRROOOOOPPPPPP',prop.address
    @cfid=prop.CFID
    @esf_form=CreateSaleForm.new
    @ppr=PropPrices.new
    @ppr.id=prop.id
    @ppr.address=prop.address
    @prices=prop.prices
    if !@prices.nil?
      @prices.each do |price5|
        if price5.JobType.eql? 'W1' then
          @ppr.w1=price5.price
        elsif price5.JobType.eql? 'W2' then
          @ppr.w2=price5.price 
        elsif price5.JobType.eql? 'EH' then
          @ppr.eh=price5.price 
        elsif price5.JobType.eql? 'EG' then
          @ppr.eg=price5.price 
        end
      end
    end  
    
    @syear_options=HomeHelper::YEARS
    @smonth_options=HomeHelper::MONTHS
    @sday_options=HomeHelper::DAYS
    
    @fyear_options=HomeHelper::YEARS
    @fmonth_options=HomeHelper::MONTHS
    @fday_options=HomeHelper::DAYS

    date=@job.Sdate
    date10=@job.Fdate
    dates=date.to_s
    date10s=date10.to_s
    
    @selected_syear=dates[0,4]
    @selected_smonth=HomeHelper.get_month_from_num(dates[5,2]) 
    @selected_sday=dates[8,2]
    @selected_fyear=date10s[0,4]
    @selected_fmonth=HomeHelper.get_month_from_num(date10s[5,2]) 
    @selected_fday=date10s[8,2]
    
    @selected_stime=@job.Stime
    
    @stime_options=HomeHelper::STIME
    @cagenum_options=HomeHelper::CAGES   
    @notes=Notes.get_job_notes @jobid
    puts 'NOTES SIZE',@notes.size
    @notes_list=[]
    @notes.each do |note|
      nb=NoteBundle.new  
      nb.id=note.id
      nb.notes=note.notes
      emp=Employee.find note.recorder
      nb.recorder=emp.name
      nb.ts=note.ts
      @notes_list<<nb
    end
    @sbs=[]
    date=HomeHelper.add_days_to_current_date(1)
    date30=HomeHelper.add_days_to_date date,30
#    d1=Date.parse('Mar 22, 2013')
#    d2=Date.parse('Mar 31, 2013')
  
    while date!=date30 do
      sb=ScheduleBundle.new
      sb=HomeHelper.schedule_bean date
      @sbs<<sb
      date=HomeHelper.add_days_to_date(date,1) 
    end

  end

  def savemodifysale
    esf=CreateSaleForm.new(params[:create_sale_form])
    @jobid=params[:jobid]
    @jobid1=params[:jobid1]
    @source=params[:source]
    @function=params[:function]
    job=Job.find esf.jobid
    cfid=esf.cfid;
    stime=esf.stime
    salesid1=session[:hrid]
    syear=esf.syear
    smonth=esf.smonth
    smonth=HomeHelper.get_num_from_month(smonth)
    sday=esf.sday
    fyear=esf.fyear
    fmonth=esf.fmonth
    fmonth=HomeHelper.get_num_from_month(fmonth)
    fday=esf.fday
    
    sdate=Date.parse(syear+'-'+smonth+'-'+sday)
    fdate=Date.parse(fyear+'-'+fmonth+'-'+fday)
    if(job.Sdate!=sdate || job.Fdate!=fdate || job.Stime!=stime)
      if sdate==fdate
         if !HomeHelper.check_schedule sdate, stime
           nosale='Edit Sale Not Processed. Invalid Date/Time'
           #redirect_to clientprofile_function_url(:id=>cfid, :nosale=>nosale, :jobid=>@jobid, :jobid1=>@jobid1,  :source=>@source, :function=>@function)
           redirect_to modifysale_sale_path(:jobid => @jobid, :jobid1=>@jobid1, :nosale=>nosale,  :source=>@source, :function=>@function)
           return
         end
      end
    end

    jobdesc=esf.jobdesc
    price=esf.jobprice
    hst=esf.jobhst
    w1=nil;
    w2=nil
    w3=nil
    w4=nil
    eh=nil
    eg=nil
    custom=nil
    customdesc=nil
    cages=nil
    
    if(esf.w1=='1')
      w1=esf.w1price
    puts 'WWWWWWWWWWW111111111111111111 First',w1,esf.w1price
      w1=HomeHelper.make_price_zero w1
    end    
    puts 'WWWWWWWWWWW111111111111111111',w1,esf.w1price
    if(esf.w2=='1')
      w2=esf.w2price  
      w2=HomeHelper.make_price_zero w2
    end
    if(esf.w3=='1')
      w3=esf.w3price  
      w3=HomeHelper.make_price_zero w3
    end
    if(esf.w4=='1')
      w4=esf.w4price  
      w4=HomeHelper.make_price_zero w4
    end
    if(esf.eh=='1')
      eh=esf.ehprice  
      eh=HomeHelper.make_price_zero eh
    end
    if(esf.eg=='1')
      eg=esf.egprice  
      eg=HomeHelper.make_price_zero eg
    end
    if(esf.custom=='1')
      custom=esf.customprice 
      custom=HomeHelper.make_price_zero custom
      customdesc='custom' 
    end
    if(esf.cages=='1')
      cages=esf.cageprice 
      if(jobdesc.include?('install cages(As Reqd)'))
        cages=-1
      end
    end
    job.JobDesc=jobdesc
    job.Price=price
    job.Cages=cages
    job.W1=w1
    job.W2=w2
    job.W3=w3
    job.W4=w4
    job.EH=eh
    job.EG=eh
    job.Custom=custom
    job.CustomDesc=customdesc
    job.Revenue=price
    job.gst=hst
    job.Stime=stime
    job.Sdate=sdate
    job.Fdate=fdate
    job.save!
    
    if(esf.notes!='')
      note=Notes.new
      note.recorder=session[:hrid]
      note.notes=esf.notes
      note.objectid=esf.jobid
      note.destgroup='Job Notes To Be Printed on Runsheets;;;;;;Job Scheduling Notes';
      note.destitem='Job Notes To Be Printed on Runsheets;;;;;;Job Scheduling Notes';
      note.id1=esf.jobid
      note.for_invoice='N' 
      note.save!   
    end
    cfmess='Sale Edited Successfully!!!'
    redirect_to clientprofile_function_url(:id=>cfid, :cfmess=>cfmess, :jobid=>@jobid, :jobid1=>@jobid1,  :source=>@source, :function=>@function)
  end

  
  def makesale1
    csf=params[:csf_form]
    cfid=csf[:CFID]
    redirect_to callclient_sale_url(:CFID=>cfid)
  end
  
  
  
  def makesalefromcfdetails
    csf=CreateSaleForm.new(params[:create_sale_form])
    @jobid1=params[:jobid1]
    @source=params[:source]
    @function=params[:function]
    cfid=params[:CFID]
    address=csf.address
    props=Property.get_property_from_address(address)
    jobinfoid=''
    props.each do |prop|
      jobinfoid=prop.JobInfoID
    end

    stime=csf.stime
    salesid1=session[:hrid]
    syear=csf.syear
    smonth=csf.smonth
    smonth=HomeHelper.get_num_from_month(smonth)
    sday=csf.sday
    fyear=csf.fyear
    fmonth=csf.fmonth
    fmonth=HomeHelper.get_num_from_month(fmonth)
    fday=csf.fday
    jobdesc=csf.jobdesc
    
    sdate=Date.parse(syear+'-'+smonth+'-'+sday)
    fdate=Date.parse(fyear+'-'+fmonth+'-'+fday)
    
    if sdate==fdate
       if !HomeHelper.check_schedule sdate, stime
          nosale='Sale['+jobdesc+'  '+sdate.to_s+'  '+stime+'] Not Processed. Invalid Date/Time'
          redirect_to makesale_sale_url(:jobinfoid => jobinfoid, :jobid1=>@jobid1,:nosale=>nosale, :source => @source, :function=>@function)
         return
       end
    end
    
    price=csf.jobprice
    hst=csf.jobhst
    w1=nil;
    w2=nil
    w3=nil
    w4=nil
    eh=nil
    eg=nil
    custom=nil
    customdesc=nil
    cages=nil
    
    if(csf.w1=='1')
      w1=csf.w1price
    puts 'WWWWWWWWWWW111111111111111111 First',w1,csf.w1price
      w1=HomeHelper.make_price_zero w1
    end    
    puts 'WWWWWWWWWWW111111111111111111',w1,csf.w1price
    if(csf.w2=='1')
      w2=csf.w2price  
      w2=HomeHelper.make_price_zero w2
    end
    
    if(csf.w3=='1')
      w3=csf.w3price  
      w3=HomeHelper.make_price_zero w3
    end
    if(csf.w4=='1')
      w4=csf.w4price  
      w4=HomeHelper.make_price_zero w4
    end
    if(csf.eh=='1')
      eh=csf.ehprice  
      eh=HomeHelper.make_price_zero eh
    end
    if(csf.eg=='1')
      eg=csf.egprice  
      eg=HomeHelper.make_price_zero eg
    end
    if(csf.custom=='1')
      custom=csf.customprice 
      custom=HomeHelper.make_price_zero custom
      customdesc='custom' 
    end
    if(csf.cages=='1')
      cages=csf.cageprice 
      if(jobdesc.include?('install cages(As Reqd)'))
        cages=-1
      end
    end
    
    
    jobid=Job.max_id
    jobid=jobid[2,jobid.size]
    jobid=jobid.to_i
    jobid+=1
    jobid=HomeHelper.pad_id_num('JB',jobid)

    job=Job.new
    job.JobID=jobid
    job.JobInfoID=jobinfoid
    job.JobDesc=jobdesc
    job.Price=price
    
    job.Cages=cages
    job.W1=w1
    job.W2=w2
    job.W3=w3
    job.W4=w4
    job.EH=eh
    job.EG=eg
    job.Custom=custom
    job.CustomDesc=customdesc
    job.Revenue=price
    job.gst=hst
    job.Stime=stime
    job.SalesID1=salesid1
    job.Datesold=Date.today
    job.Sdate=sdate
    job.Fdate=fdate
    job.save!
    if(csf.notes!='')
      note=Notes.new
      note.recorder=session[:hrid]
      note.notes=csf.notes
      note.objectid=jobid
      note.destgroup='Job Notes To Be Printed on Runsheets;;;;;;Job Scheduling Notes';
      note.destitem='Job Notes To Be Printed on Runsheets;;;;;;Job Scheduling Notes';
      note.id1=jobid
      note.for_invoice='N' 
      note.save!   
    end
    if @function=='callclient'
      record_contact(cfid, 'SALE', Date.today, '')
      update_convertcall(cfid, 'SALE', Date.today)
      tsj=Telesalejobs.new
      tsj.jobid=jobid
      tsj.save!
    end
    cfmess='SALE Created Successfully!!!'
    #redirect_to makesale_sale_url(:jobinfoid=>jobinfoid)
    if csf.source=='cfinfo'
      redirect_to clientprofile_function_url(:id=>cfid, :cfmess=>cfmess, :jobid1=>@jobid1, :source => @source, :function=>@function)
    elsif csf.source=='callclient'
      redirect_to callclient_sale_url(:CFID=>cfid)
    elsif csf.source=='messages'
      redirect_to messagelog_functions__url
    else  
      redirect_to clientprofile_function_url(:id=>cfid, :cfmess=>cfmess, :jobid1=>@jobid1, :source => @source, :function=>@function)
    end
  end

  def screenconvertcalls
    cfid1=Client.max_CFID
    cfid=Convertcalls.max_CFID
    puts cfid,cfid1
    clients=Client.range_for_convertcalls cfid,cfid1 
    clients.each do |client|
      cc=Convertcalls.new
      cc.cfid=client.CFID
      cc.numjobsls='0'
      cc.numjobslf='0'
      cc.fallcalls='0'
      cc.summcalls='0'
      cc.package='0'
      cc.rating='2.5'
      cc.save!
    end
    redirect_to login1_functions_url 
  end


 end

