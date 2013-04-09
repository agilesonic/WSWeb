require 'date'

class SalesController < ApplicationController
  layout "application1"
  protect_from_forgery

  
  def index
    @sales_form=SalesForm.new
    @profile_options=['No Calls', 'Windows Last Spring', 'EH Last Spring', 'Used Us Last Year'] 
    @x='Got into index'
  end
  
  def loadclients
    sf=SalesForm.new(params[:sales_form])
    #@clients=Client.search_cfrange(@sf[:lowcf].to_s,@sf[:highcf].to_s)
    #@clients=Client.search_kbanger('HR00005045')
    @cc=Convertcalls.search_ccrange sf.lowcf, sf.limit
    
    session[:lowcf] = sf.lowcf
    session[:limit] = sf.limit
  end   

  def clientlist
    lowcf=session[:lowcf]
    limit=session[:highcf]
    @cc=Convertcalls.search_ccrange(lowcf, limit)
    #@clients=Client.search_cfrange(lowcf,highcf)
    render 'loadclients'
  end
  
  def nextclient
    cfid=params[:id]
    @jobid1=params[:jobid1]
    @source=params[:source]
    @function=params[:function]
    lowcf=session[:lowcf]
    highcf=session[:highcf]
    clients=Client.search_cfrange(lowcf,highcf)
    i=0
    clients.each do |client|
      if client.CFID==cfid
        i+=1
        break
      end
      i+=1
    end
    next_client=clients[i]
    #redirect_to callclient_sale_url(:id=>next_client.CFID)
    redirect_to clientprofile_function_path(:id => next_client.CFID, :jobid1=>@jobid1, :source=>@source,:function=>@function)
  end

  def callclient
    @source=params[:source]
    @function=params[:function]
    
    @cfid=params[:id]
    @client=Client.find(@cfid)
    @calls=@client.clientcontacts
    if !@calls.nil?
      @calls.each do |call|
        name='unknown'
        if !call.caller.nil?
          e=Employee.find(call.caller)
        end
        if !e.nil?
          call.caller=e.name
        else
          call.caller=name
        end  
      end
    end
    
    @prices_all=HomeHelper.get_props_and_prices(@client)
    @x='OK'
    @tstatus_options=['SOLD', 'LMM', 'LMP']
    @years=HomeHelper::YEARS
    @months=HomeHelper::MONTHS
    @days=HomeHelper::DAYS
    #@cfid=@id
    @call_client_form=CallClientForm.new
    
    
    
    date=HomeHelper.add_days_to_current_date(1)
    date10=HomeHelper.add_days_to_date date,10
    dates=date.to_s
    date10s=date10.to_s
    
    @selected_syear_foll=dates[0,4]
    @selected_smonth_foll=HomeHelper.get_month_from_num(dates[5,2]) 
    @selected_sday_foll=dates[8,2]
    @selected_fyear_foll=date10s[0,4]
    @selected_fmonth_foll=HomeHelper.get_month_from_num(date10s[5,2]) 
    @selected_fday_foll=date10s[8,2]
  end
  
  def callclient1
    #ccf=params[:call_client_form]
    ccf=CallClientForm.new(params[:call_client_form])
    cfid=params[:id]
    t=Time.now
    year=t.to_s[25..28]
    month=t.to_s[7..9]
    day=t.to_s[4..5]
    curr=Date.parse(month+' '+day+', '+year)
    fu=Date.parse(ccf.month.to_s+' '+ccf.day.to_s+', '+ccf.year.to_s)
    
    cc=Clientcontact.new
    cc.CFID= cfid
    cc.tstatus= ccf.tstatus.to_s
    cc.notes= ccf.notes.to_s
    cc.followup= fu
    cc.dateatt= curr
    cc.caller= session[:hrid]
    cc.save!
    #if ccf[:tstatus]=='SOLD'
    #makesale(id, 'tsales')
    #end 
    #redirect_to clientprofile_sale_url(:CFID=>ccf.cfid)
    cfmess='Client Call Recorded Successfully!!!'
    redirect_to clientprofile_function_path(:id => cfid,:source=>'callclient',:function=>'callclient',:cfmess=>cfmess)
  end
 
  def makesale
    @jobinfoid=params[:jobinfoid]
    @source=params[:source]
    @function=params[:function]
    @jobid1=params[:jobid1]
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
    dates=date.to_s
    date10s=date10.to_s
    
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
    d2=date10
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
    date10=HomeHelper.add_days_to_date date,10
#    d1=Date.parse('Mar 22, 2013')
#    d2=Date.parse('Mar 31, 2013')
  
    while date!=date10 do
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
           redirect_to clientprofile_function_url(:id=>cfid, :nosale=>nosale, :jobid=>@jobid, :jobid1=>@jobid1,  :source=>@source, :function=>@function)
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
          redirect_to clientprofile_function_url(:id=>cfid,:nosale=>nosale, :jobid1=>@jobid1, :source => @source, :function=>@function)
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


 end

