class FunctionsController <  ApplicationController
  layout "application1"
  
  def new
    @login_form=Login1Form.new
  end
  
  def show 
    
  end

  def login
    login_form=params[:login1_form]
    #login_form = Login1Form.new(params[:login1_form])

    name=login_form[:name]
    pass=login_form[:password]
    @user=InternalUser.search(name,pass)  #@user is an array of InternalUser
    user=@user[0]
    puts "******************",pass,@user
    if !@user.empty? 
      @l='ok'
      session[:hrid]=user.HRID
    else  
      redirect_to new_function_url
    end
  end
  
  def smartsearch
    @smart_search_form=SmartSearchForm.new
  end

  def findclients
    @xx='Test'
    ssf=params[:smart_search_form]
    cfid=ssf[:CFID]
    if cfid!=''
      cfid=HomeHelper.pad_id_num('CF',cfid)
    end
      jobid=ssf[:jobid]
    if jobid!=''
      jobid=HomeHelper.pad_id_num('JB',jobid)
    end
    puts 'CFID**************************************************************',cfid
    puts 'JOBID*************************************************************',jobid
    
    name=ssf[:name]
    address=ssf[:address]
    jobaddress=ssf[:jobaddress]
    phone=ssf[:phone]
    if cfid.eql? '' then
      cfid='Wayne Gretzky'
    end
    if jobid.eql? '' then
      jobid='Wayne Gretzky'
    end
    if name.eql? '' then
      name='Wayne Gretzky'
    end
    if address.eql? '' then
      address='Wayne Gretzky'
    end   
    if jobaddress.eql? '' then
      jobaddress='Wayne Gretzky'
    end   
    if phone.eql? '' then
      phone='Wayne Gretzky' 
    end
    @clients=Client.search1(name,address,phone, jobaddress, cfid, jobid)
 #   @props=Property.search(jobaddress)
 #   @props.each do |prop|
 #     cfid=prop.CFID
 #     c=Client.find(cfid)
 #     @clients<<c
 #   end   
    @clients=@clients.uniq
    @source=ssf[:source]
  end
  
  def clientprofile
    @cfid=params[:id]
    @client=Client.find(@cfid)
    @nosale=params[:nosale]
    @cfmess=params[:cfmess]
    @source=params[:source]
    @function=params[:function]
    @jobid=params[:jobid]
    @jobid1=params[:jobid1]
    @client_header= @client.full_name+'   '+@client.phone
    
    @call_client_form=CallClientForm.new
    @sat_call_form=SatCallForm.new
    @tstatus_options=['SOLD', 'LMM', 'LMP']
    @sat_options=HomeHelper::SAT_TYPES
    @years=HomeHelper::YEARS
    @months=HomeHelper::MONTHS
    @days=HomeHelper::DAYS
    @calls=@client.clientcontacts
    if @function=='callclient'
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
    end
    
    
    if @function=='satcall'
      job=Job.find @jobid1
      @sat_info=[]      
      job_bundle=JobBundle.new
      job_bundle.jobdnf='job'
      job_bundle.jobid=job.JobID
      job_bundle.address=job.property.address
      job_bundle.jobdesc=job.JobDesc
      job_bundle.price=job.Price
      partner="".to_s
      empList=Employee.find_by_name(job.CrewName)
      emp=empList.last
      if(!emp.nil?)
        ocList=OC.find_partner  emp.HRID, job.Datebi
        oc=ocList.first
        if(!oc.nil?)
          emp2List=Employee.find_by_hrid oc.partner
          emp=emp2List.last
          if(!emp.nil?)
            partner="/" + emp.name.to_s
          end
        end
      end
      job_bundle.crewname=job.CrewName.to_s + partner.to_s
      job_bundle.minutes=job.Minutes
      job_bundle.datebi=job.Datebi
 
      if !job.Recstatus.nil? && !job.Recstatus.index('Receiv').nil? && job.Recstatus.index('Receiv')>-1
         job_bundle.daystopay=job.Recstatus
          @sat_info << job_bundle
      else       
        trandate=Transactions.date_paid job.JobID
        paid_date=trandate
        job_date=job.Datebi
        if(paid_date.nil? || job_date.nil?)
          job_bundle.daystopay='unknown'    
          @sat_info << job_bundle
        else  
          days=(paid_date-job_date).to_i
          job_bundle.daystopay=days    
          @sat_info << job_bundle
        end
      end
  
      upcomingdnfs=Jobdnf.search_incomplete_dnfs job.JobID
      upcomingdnfs.each do |dnf|
      job_bundle=JobBundle.new
      job_bundle.jobdnf='dnf'
      job_bundle.jobid=dnf.DNFID
      job_bundle.address=job.property.address
      job_bundle.jobdesc=dnf.DnfDesc
      if(dnf.Sdate==dnf.Fdate)
        job_bundle.type='Appt('+dnf.Stime+')'
      else  
        job_bundle.type='Fltr'
      end
      job_bundle.sdate=dnf.Sdate
      @sat_info << job_bundle
     end
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    dnfs=Jobdnf.search_completed_dnfs(job.JobID)
    if !dnfs.nil?
      dnfs.each do |dnf|
        jdb=JobBundle.new
        jdb.jobdnf='dnf'
        jdb.jobid='DNF for:'+job.JobID
        jdb.address=job.property.address
        jdb.jobdesc=dnf.DnfDesc
        jdb.crewname=dnf.CrewName
        if !dnf.Datebi.nil?  
          partner="".to_s
          empList=Employee.find_by_name(dnf.CrewName)
          emp=empList.last
          if(!emp.nil?)
            ocList=OC.find_partner  emp.HRID, dnf.Datebi
            oc=ocList.first
              if(!oc.nil?)
                emp2List=Employee.find_by_hrid oc.partner
                emp=emp2List.last
                if(!emp.nil)
                  partner="/" + emp.name.to_s
                end
              end
          end
          job_bundle.crewname=job.CrewName.to_s + partner.to_s
        else
          job_bundle.crewname=''
        end
        jdb.minutes=dnf.Minutes
        jdb.datebi=dnf.Datebi
        jdb.daystopay='n/a'    
        @sat_info << jdb
      end
    end
    end


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

   
    @edit_client_form=EditClientForm.new
    @prices_all=HomeHelper::get_props_and_prices(@client)
    donejobs=@client.done_jobs
    donejobs2013=@client.done_jobs_2013
    upcomingjobs=@client.upcoming_jobs
    @done_jobs=[]
    @done_jobs_2013=[]
    @upcoming_jobs=[]
    upcomingjobs.each do |job|
      job_bundle=JobBundle.new
      job_bundle.jobdnf='job'
      job_bundle.jobid=job.JobID
      job_bundle.address=job.property.address
      job_bundle.jobdesc=job.JobDesc
      job_bundle.price=job.Price
      if(job.Sdate==job.Fdate)
        job_bundle.type='Appt('+job.Stime+')'
      else  
        job_bundle.type='Fltr'
      end
      job_bundle.sdate=job.Sdate
      @upcoming_jobs << job_bundle
    end

    @upcoming_dnfs=[]
    donejobs.each do |job|
      job_bundle=JobBundle.new
      job_bundle.jobdnf='job'
      if !job.satisfaction.nil?
        job_bundle.sat='ok'
      end
      job_bundle.jobid=job.JobID
      job_bundle.address=job.property.address
      job_bundle.jobdesc=job.JobDesc
      job_bundle.price=job.Price
      partner="".to_s
      empList=Employee.find_by_name(job.CrewName)
      emp=empList.last
      if(!emp.nil?)
        ocList=OC.find_partner  emp.HRID, job.Datebi
        oc=ocList.first
        if(!oc.nil?)
          emp2List=Employee.find_by_hrid oc.partner
          emp=emp2List.last
          if(!emp.nil?)
            partner="/" + emp.name.to_s
          end
        end
      end
      job_bundle.crewname=job.CrewName.to_s + partner.to_s
      job_bundle.minutes=job.Minutes
      job_bundle.datebi=job.Datebi
 
      if !job.Recstatus.nil? && !job.Recstatus.index('Receiv').nil? && job.Recstatus.index('Receiv')>-1
         job_bundle.daystopay=job.Recstatus
         if job_bundle.datebi<Date.parse('2013-01-01')
            @done_jobs << job_bundle
         else
            @done_jobs_2013 << job_bundle
         end
      else       
        trandate=Transactions.date_paid job.JobID
        paid_date=trandate
        job_date=job.Datebi
        if(paid_date.nil? || job_date.nil?)
          job_bundle.daystopay='unknown'    
         if job_bundle.datebi<Date.parse('2013-01-01')
            @done_jobs << job_bundle
         else
            @done_jobs_2013 << job_bundle
         end
        else  
          days=(paid_date-job_date).to_i
          job_bundle.daystopay=days    
         if job_bundle.datebi<Date.parse('2013-01-01')
            @done_jobs << job_bundle
         else
            @done_jobs_2013 << job_bundle
         end
        end
    end
    
    upcomingdnfs=Jobdnf.search_incomplete_dnfs job.JobID
    upcomingdnfs.each do |dnf|
      job_bundle=JobBundle.new
      job_bundle.jobdnf='dnf'
      job_bundle.jobid=dnf.DNFID
      job_bundle.address=job.property.address
      job_bundle.jobdesc=dnf.DnfDesc
      if(dnf.Sdate==dnf.Fdate)
        job_bundle.type='Appt('+dnf.Stime+')'
      else  
        job_bundle.type='Fltr'
      end
      job_bundle.sdate=dnf.Sdate
      @upcoming_dnfs << job_bundle
    end

    dnfs=Jobdnf.search_completed_dnfs(job.JobID)
      if !dnfs.nil?
          dnfs.each do |dnf|
            jdb=JobBundle.new
            jdb.jobdnf='dnf'
            jdb.jobid='DNF for:'+job.JobID
            jdb.address=job.property.address
            jdb.jobdesc=dnf.DnfDesc
            jdb.crewname=dnf.CrewName
                if !dnf.Datebi.nil?  
                  partner="".to_s
                  empList=Employee.find_by_name(dnf.CrewName)
                  emp=empList.last
                      if(!emp.nil?)
                        ocList=OC.find_partner  emp.HRID, dnf.Datebi
                        oc=ocList.first
                            if(!oc.nil?)
                              emp2List=Employee.find_by_hrid oc.partner
                              emp=emp2List.last
                              if(!emp.nil?)
                                partner="/" + emp.name.to_s
                              end
                            end
                      end
                  jdb.crewname=job.CrewName.to_s + partner.to_s
                else
                  jdb.crewname=''
                end
            jdb.minutes=dnf.Minutes
            jdb.datebi=dnf.Datebi
            jdb.daystopay='n/a'    
            if jdb.datebi<Date.parse('2013-01-01')
               @done_jobs << jdb
            else
               @done_jobs_2013 << jdb
            end
          end
      end
      sat=job.satisfaction
      if !sat.nil?
        sb=JobBundle.new
        sb.jobdnf='sat'
        sb.jobid='Sat for:'+job.JobID
        sb.address=job.property.address
        sb.jobdesc=sat.Comments
        emp=Employee.find(sat.Caller)
        if(!emp.nil?)
          sb.crewname=emp.name
        end
        sb.minutes='n/a'
        sb.datebi=sat.SatDate
        sb.daystopay='n/a'    
        if sb.datebi<Date.parse('2013-01-01')
          @done_jobs << sb
        else
          @done_jobs_2013 << sb
        end
      end     
    end
  end

  def selljob
    @test="sell HI HO"
    @cfid=params[:id]
    @client=Client.find(@cfid)
  end
    
  def editclient
    cfid=params[:id]
    client=Client.find cfid
    ecf=EditClientForm.new(params[:edit_client_form]) 
    client.company=ecf.company
    client.firstname=ecf.firstname
    client.lastname=ecf.lastname
    client.address=ecf.address
    client.save!
    redirect_to clientprofile_function_url(:id=>cfid)
  end

  def messagelog
    @test='in messages'
    mess=Messages.unresolved_messages
    @mess=[]
  
    mess.each do |m|
      mb=MessageBundle.new
      d=HomeHelper.get_nice_date m.messdate
      mb.messdate=d
      mb.msid=m.msid
      emp=Employee.find m.recorder
      mb.recorder=emp.name
      mb.message=m.message
      d=HomeHelper.get_nice_date m.followup
      mb.followup=d
      if m.followobject.index('HR')==0
        emp=Employee.find m.followobject
        mb.followobject=emp.name
      else
        mb.followobject=m.followobject  
      end      
      mb.cfid=m.cfid
      @mess<<mb
    end
  end
  
  def logmessage
    @log_message_form=LogMessageForm.new
    if(!params[:source].nil?)
      @source=params[:source]
      @sourceid=params[:sourceid]
      @cfid=params[:sourceid]
      @client=Client.find(@cfid)
      @jobaddress_options=HomeHelper.get_props_addresses @client
      @name=@client.full_name
      @address=@client.address
      @phone=@client.phone
      @action='Create Message'
    else
      @action='Screen Message'
      @jobaddress_options=['']
    end
    @messheader_options=HomeHelper::MESS_HEADERS
    @messtype_options=HomeHelper::MESS_TYPES
  end
  
  def screenmessage
    @log_message_form=LogMessageForm.new(params[:log_message_form])
    @action=@log_message_form.action
    @source=@log_message_form.source
    @sourceid=@log_message_form.sourceid
    @messheader_options=HomeHelper::MESS_HEADERS
    @messtype_options=HomeHelper::MESS_TYPES
    if @action=='Create Message'
      msid=Messages.max_id
      msid=msid[2,msid.size]
      msid=msid.to_i
      msid+=1
      msid=HomeHelper.pad_id_num('MS',msid)

      m=Messages.new
      m.msid=msid
      m.messtype=@log_message_form.messtype
      m.message=@log_message_form.messheader
      m.recorder=session[:hrid]
      if @log_message_form.message!=''
        m.message+=' N:'+@log_message_form.message
      end  
      m.cfid=@log_message_form.cfid
      m.jobid=@log_message_form.jobid
      if @log_message_form.jobaddress!=''
        props=Property.get_property_from_address  @log_message_form.jobaddress
        prop=props[0]
        m.jobaddress=prop.address
        m.jobinfoid=prop.JobInfoID
      end
      m.name=@log_message_form.name
      m.address=@log_message_form.address
      m.phone=@log_message_form.phone
      m.save!
      if @source=='clientprofile'
        redirect_to clientprofile_function_url(:id=>m.cfid)
      else
        redirect_to logmessage_functions_url
      end
      return
    end
    
    @cfid=@log_message_form.cfid
    @jobid=@log_message_form.jobid
    @shortname=@log_message_form.shortname
    @name=@log_message_form.name
    @address=@log_message_form.address
    @jobaddress=@log_message_form.jobaddress
    @phone=@log_message_form.phone
    @message=@log_message_form.message
    
      @jobaddress_options=['']
    if @cfid.eql? '' then
      @cfid='Wayne Gretzky'
    end
    if @jobid.eql? '' then
      @jobid='Wayne Gretzky'
    end
    if @name.eql? '' then
      @name='Wayne Gretzky'
    end
    if @shortname.eql? '' then
      @shortname='Wayne Gretzky'
    end
    if @address.eql? '' then
      @address='Wayne Gretzky'
    end   
    if @jobaddress.eql? '' then
      @jobaddress='Wayne Gretzky'
    end   
    if @phone.eql? '' then
      @phone='Wayne Gretzky' 
    end
    puts 'name......',@shortname
    puts 'ADDRESS......',@address
    puts 'PHONE......',@phone
    puts 'Job ADDRESS......',@jobaddress
    @clients=Client.search1(@shortname, @address, @phone, @jobaddress, @cfid, @jobid)
    @clients=@clients.uniq
    if @cfid.eql? 'Wayne Gretzky' then
      @cfid=''
    end
    if @jobid.eql? 'Wayne Gretzky' then
      @jobid=''
    end
    if @name.eql? 'Wayne Gretzky' then
      @name=''
    end
    if @shortname.eql? 'Wayne Gretzky' then
      @shortname=''
    end
    if @address.eql? 'Wayne Gretzky' then
      @address=''
    end   
    if @jobaddress.eql? 'Wayne Gretzky' then
      @jobaddress=''
    end   
    if @phone.eql? 'Wayne Gretzky' then
      @phone='' 
    end
    puts 'CLIENT SIZE****************',@clients.size
    @action='Screen Message'
    render 'logmessage'
  end
  
  def makednf
    @jobid=params[:jobid]
    @source=params[:source]
    @function=params[:function]
    job=Job.find @jobid
    props=Property.get_property_from_jobinfoid job.JobInfoID
    prop=props[0]
    @cfid=prop.CFID
    @cdf_form=CreateDNFForm.new
    @ppr=PropPrices.new
    @ppr.id=prop.id
    c=Client.find prop.CFID
    @ppr.client= c.honorific+' '+c.firstname+' '+c.lastname
    @ppr.address=prop.address
    
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
    @clienthm_options=HomeHelper::YESNO
  end

 
  def makednffromcfdetails
    cdf=CreateDNFForm.new(params[:create_dnf_form])
    @source=params[:source]
    @function=params[:function]
    jobid=params[:jobid]
    job=Job.find jobid
    prop=Property.find job.JobInfoID
    client=Client.find prop.CFID
    cfid=client.CFID
  
    stime=cdf.stime
    register=session[:hrid]
    syear=cdf.syear
    smonth=cdf.smonth
    smonth=HomeHelper.get_num_from_month(smonth)
    sday=cdf.sday
    fyear=cdf.fyear
    fmonth=cdf.fmonth
    fmonth=HomeHelper.get_num_from_month(fmonth)
    fday=cdf.fday
    dnfdesc=cdf.dnfdesc
    
    sdate=Date.parse(syear+'-'+smonth+'-'+sday)
    fdate=Date.parse(fyear+'-'+fmonth+'-'+fday)
    
    dnfid=Jobdnf.max_id
    dnfid=dnfid[2,dnfid.size]
    dnfid=dnfid.to_i
    dnfid+=1
    dnfid=HomeHelper.pad_id_num('DN',dnfid)

    jobdnf=Jobdnf.new
    jobdnf.DNFID=dnfid
    jobdnf.JobID=jobid
    jobdnf.DnfDesc=dnfdesc
    jobdnf.Stime=stime
    jobdnf.register=register
    jobdnf.Contact=cdf.contact
    jobdnf.ClientBeHome=cdf.clienthm
    jobdnf.Dnfdate=Date.today
    jobdnf.Sdate=sdate
    jobdnf.Fdate=fdate
    jobdnf.save!
    cfmess='DNF created successfully!!!'
    redirect_to clientprofile_function_url(:cfid=>cfid, :cfmess=>cfmess)
  end

  def modifydnf
    @jobid1=params[:jobid1]
    @source=params[:source]
    @function=params[:function]
    @dnfid=params[:dnfid]
    @dnf=Jobdnf.find @dnfid
    @jobid=@dnf.JobID
    job=Job.find @jobid
    prop=Property.find job.JobInfoID

    @cfid=prop.CFID
    @edf_form=CreateDNFForm.new
    @ppr=PropPrices.new
    @ppr.id=prop.id
    @ppr.client= @dnf.Contact
    @ppr.address=prop.address

    @selected_clienthm=@dnf.Clienthm    
    
    @syear_options=HomeHelper::YEARS
    @smonth_options=HomeHelper::MONTHS
    @sday_options=HomeHelper::DAYS
    
    @fyear_options=HomeHelper::YEARS
    @fmonth_options=HomeHelper::MONTHS
    @fday_options=HomeHelper::DAYS

    date=@dnf.Sdate
    date10=@dnf.Fdate
    dates=date.to_s
    date10s=date10.to_s
    
    @selected_syear=dates[0,4]
    @selected_smonth=HomeHelper.get_month_from_num(dates[5,2]) 
    @selected_sday=dates[8,2]
    @selected_fyear=date10s[0,4]
    @selected_fmonth=HomeHelper.get_month_from_num(date10s[5,2]) 
    @selected_fday=date10s[8,2]
    @selected_stime=@dnf.Stime
    @stime_options=HomeHelper::STIME
    @clienthm_options=HomeHelper::YESNO
  end
  
  def savemodifydnf
    edf=CreateDNFForm.new(params[:create_dnf_form])
    @cfid=params[:CFID]
    @jobid1=params[:jobid1]
    @source=params[:source]
    @function=params[:function]
    
    dnf=Jobdnf.find edf.dnfid
    stime=edf.stime
    register=session[:hrid]
    syear=edf.syear
    smonth=edf.smonth
    smonth=HomeHelper.get_num_from_month(smonth)
    sday=edf.sday
    fyear=edf.fyear
    fmonth=edf.fmonth
    fmonth=HomeHelper.get_num_from_month(fmonth)
    fday=edf.fday
    sdate=Date.parse(syear+'-'+smonth+'-'+sday)
    fdate=Date.parse(fyear+'-'+fmonth+'-'+fday)
    dnfdesc=edf.dnfdesc
    contact=edf.contact
    clienthm=edf.clienthm

    dnf.Sdate=sdate
    dnf.Fdate=fdate
    dnf.Stime=stime
    dnf.Contact=contact
    dnf.Clienthm=clienthm
    dnf.DnfDesc=dnfdesc
    dnf.save!
    cfmess='DNF Edited Successfully!!!'
    redirect_to clientprofile_function_url(:cfid=>@cfid,:jobid1=>@jobid1, :source=>@source, :function=>@function, :cfmess=>cfmess)
  end
  
  def generate_sat_list
    date=Date.parse('2013-03-01')
    sat_jobids=[]
    job_jobids=[]
    sats=Satisfaction.search_sats date
    sats.each do |sat|
      sat_jobids<<sat.JobID  
    end
    jobs=Job.search_jobs_for_sats date
    jobs.each do |job|
      job_jobids<<job.JobID  
    end
    need_sat_jobids=job_jobids-sat_jobids
    done_jobs=[]
    i=0
    need_sat_jobids.each do |jobid|
      job=Job.find jobid
      prop=job.property
      cfid=prop.CFID
      job_bundle=JobBundle.new
      job_bundle.num=i
      job_bundle.jobdnf='job'
      job_bundle.jobid=job.JobID
      job_bundle.cfid=cfid
      job_bundle.address=job.property.address
      job_bundle.jobdesc=job.JobDesc
      job_bundle.price=job.Price
      partner="".to_s
      empList=Employee.find_by_name(job.CrewName)
      emp=empList.last
      if(!emp.nil?)
        ocList=OC.find_partner  emp.HRID, job.Datebi
        oc=ocList.first
        if(!oc.nil?)
          emp2List=Employee.find_by_hrid oc.partner
          emp=emp2List.last
          if(!emp.nil?)
            partner="/" + emp.name.to_s
          end
        end
      end
      job_bundle.crewname=job.CrewName.to_s + partner.to_s
      job_bundle.minutes=job.Minutes
      job_bundle.datebi=job.Datebi
      if !job.Recstatus.nil? && !job.Recstatus.index('Receiv').nil? && job.Recstatus.index('Receiv')>-1
         job_bundle.daystopay=job.Recstatus
          done_jobs << job_bundle
      else       
        trandate=Transactions.date_paid job.JobID
        paid_date=trandate
        job_date=job.Datebi
        if(paid_date.nil? || job_date.nil?)
          job_bundle.daystopay='unknown'    
          done_jobs << job_bundle
        else  
          days=(paid_date-job_date).to_i
          job_bundle.daystopay=days    
          done_jobs << job_bundle
        end
      end
      i+=1
    end
    return done_jobs
  end
  
    
  def satisfaction
    @done_jobs=generate_sat_list
    @source='satcall'
    @function='satcall'
  end

  def satisfaction_from_client_profile
    id=params[:id]
    jobid1=params[:jobid1]
    @done_jobs=generate_sat_list
    source=params[:source]
    function=params[:function]
    redirect_to clientprofile_function_url(:cfid=>id,:jobid1=>jobid1, :source=>source, :function=>function)
  end


  def nextsatclient
    @test='Nut WEEEENNNAAHHHHHH'
    jobid5=params[:jobid1]
    @source=params[:source]
    @function=params[:function]
    jobid5=params[:jobid1]
    date=Date.parse('2013-03-01')
    sat_jobids=[]
    job_jobids=[]
    sats=Satisfaction.search_sats date
    sats.each do |sat|
      sat_jobids<<sat.JobID  
    end
    jobs=Job.search_jobs_for_sats date
    jobs.each do |job|
      job_jobids<<job.JobID
    end
    
    need_sat_jobids=job_jobids-sat_jobids
    i=0
    next_jobid=jobid5
    job=Job.find next_jobid
    prop=job.property
    cfid=prop.CFID
    need_sat_jobids.each do |jobid|
      if jobid>jobid5
          next_jobid=need_sat_jobids[i]
          job=Job.find next_jobid
          prop=job.property
          cfid=prop.CFID
          break
      end      
      i+=1
    end
    redirect_to clientprofile_function_path(:id => cfid, :jobid1=>next_jobid, :source=>@source, :function=>@function)
  end

#<td><%= link_to 'Make Sat Call', satisfaction1_function_path(:id=@cfid, :jobid => job.jobid, :jobid1=>@jobid1,  :source=>@source, :function=>@function),:style=>"color: yellow"%></td>


  
#    <%= form_for @sat_call_form, :url => satcall_function_url(:id => @cfid, :source=>'satcall', :function=>'satcall') do |cc| %>
  def savesatcall
    @cfmess='Satisfaction Call Recorded Successfully!!!'
    @source=params[:source]
    @function=params[:function]
    @jobid1=params[:jobid1]
    scf=SatCallForm.new(params[:sat_call_form])
    
    sat=Satisfaction.new
    sat.JobID=@jobid1
    sat.Caller=session[:hrid]
    sat.Comments=scf.comments
    sat.Type=scf.type
    sat.SatDate=Date.today
    sat.save!
    redirect_to clientprofile_function_url(:cfid=>@cfid, :jobid1=>@jobid1, :source=>@source, :function=>@function, :cfmess=>@cfmess)
  end
  
end