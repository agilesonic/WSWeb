class FunctionsController <  ApplicationController
  layout "application1"
  
  def new
    @mess=params[:mess]
    @login_form=Login1Form.new
  end
  
  def show 
    
  end

  def login
    login_form=params[:login1_form]
    name=login_form[:name]
    pass=login_form[:password]
    @user=InternalUser.search(name,pass)  #@user is an array of InternalUser
    if !@user.empty? 
      @l='ok'
      user=@user[0]
      @username=user.username
      session[:username]=@username
      session[:hrid]=user.HRID
    else  
      redirect_to new_function_url(:mess=>'*****Incorrect Username/Password*****')
    end
  end
  
  def login1
    @username=session[:username]
    @messsales=params[:messsales]
    render 'login'
  end
  
  def send_estimate_mail
    c=Client.find 'CF00024278'
    c.email='roger.whiteshark@hotmail.com'
    AppMailer.send_estimate_mail(c).deliver
    redirect_to login1_functions_url
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
  
  def clientprofile1
    @cfid=params[:id]
    @client=Client.find(@cfid)
    @nosale=params[:nosale]
    @cfmess=params[:cfmess]
    @source=params[:source]
    @function=params[:function]
    @jobid=params[:jobid]
    @jobid1=params[:jobid1]
    crs=Clientrate.find_rating @cfid
    cr=crs.first
    @client_header1= @client.CFID
    @client_header2=@client.full_name
    @client_header3=@client.address+' '+@client.phone
    @client_header4='Rating:'+cr.overallrate.to_s
    if @client.registerdate.nil? || @client.registerdate==''
      @client_header5='Date Registered: unknown'
    else 
      @client_header5='Date Registered:'+@client.registerdate.to_formatted_s(:long_ordinal)
    end
    @call_client_form=CallClientForm.new
    @sat_call_form=SatCallForm.new
    @tstatus_options=HomeHelper::CALL_OPTIONS
 
    date=HomeHelper.add_days_to_current_date(1)
    date10=HomeHelper.add_days_to_date date,10
    date10s=date10.to_s
    
    @selected_foll_year=date10s[0,4]
    @selected_foll_month=HomeHelper.get_month_from_num(date10s[5,2]) 
    @selected_foll_day=date10s[8,2]
 
    @year10=date10s[0,4]
    @month10=HomeHelper.get_month_from_num(date10s[5,2]) 
    @day10=date10s[8,2]
    
    
    @sat_options=HomeHelper::SAT_TYPES
    @years=HomeHelper::YEARS
    @months=HomeHelper::MONTHS
    @days=HomeHelper::DAYS
    @calls=@client.clientcontacts
    @call_info=[]      
    @date5=Date.parse("2013-04-01")

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
      @call_info << job_bundle      
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
            @call_info << job_bundle      
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
            @call_info << job_bundle      
            @done_jobs_2013 << job_bundle
         end
        else  
          days=(paid_date-job_date).to_i
          job_bundle.daystopay=days    
         if job_bundle.datebi<Date.parse('2013-01-01')
            @done_jobs << job_bundle
         else
            @done_jobs_2013 << job_bundle
            @call_info << job_bundle
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
      @call_info << job_bundle
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
               @call_info << job_bundle
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
          @call_info << job_bundle
     end
      end     
    end
    @contact_options=HomeHelper::CLIENT_CONTACT_STATUS
    @selected_contact=@client.contactstatus
    @call_info=@call_info.uniq
  end


#    donejobs=@client.done_jobs
#    donejobs2013=@client.done_jobs_2013
#    upcomingjobs=@client.upcoming_jobs

  def clientprofile_jobs(client)
    jobs=[]
    @date_2013=Date.parse("2013-01-01")
    donejobs=client.done_jobs
    donejobs.each do |job|
      job_bundle=JobBundle.new
      job_bundle.typedesc='donejob'
      job_bundle.jobdnf='job'
      if !job.satisfaction.nil?
        job_bundle.sat='ok'
      end
      job_bundle.jobid=job.JobID
      job_bundle.address=job.property.address
      jdesc='unknown'
      if !job.JobDesc.nil?
        jdesc=job.JobDesc
      end
      job_bundle.jobdesc=jdesc
      job_bundle.price=job.Price
      empList=Employee.find_by_hrid(job.SalesID1)
      emp=empList.last
      name="unknown"
      if !emp.nil?
        name=emp.name
      end
      job_bundle.salesp=name
      job_bundle.datesold=job.Datesold.to_formatted_s(:long_ordinal)
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

      if job.Datebi>=@date_2013
        job_bundle.datetag='2013'
      else  
        job_bundle.datetag='pre2013'
      end
      
      job_bundle.datebi=job.Datebi.to_formatted_s(:long_ordinal)
 
      if !job.Recstatus.nil? && !job.Recstatus.index('Receiv').nil? && job.Recstatus.index('Receiv')>-1
         job_bundle.daystopay=job.Recstatus
         jobs << job_bundle
      else       
        trandate=Transactions.date_paid job.JobID
        paid_date=trandate
        job_date=job.Datebi
        if(paid_date.nil? || job_date.nil?)
          job_bundle.daystopay='unknown'    
          jobs << job_bundle
        else  
          days=(paid_date-job_date).to_i
          job_bundle.daystopay=days    
          jobs << job_bundle
        end
    end
    

    dnfs=Jobdnf.search_completed_dnfs(job.JobID)
    if !dnfs.nil?
       dnfs.each do |dnf|
       jdb=JobBundle.new
       jdb.typedesc='donednf'
       jdb.jobdnf='dnf'
       jdb.jobid='DNF for:'+job.JobID
       jdb.address=job.property.address
       jdb.jobdesc=dnf.DnfDesc
       
       empList=Employee.find_by_hrid(dnf.register)
       emp=empList.last
       name="unknown"
       if !emp.nil?
         name=emp.name
       end
       job_bundle.salesp=name
       job_bundle.datesold=dnf.Dnfdate.to_formatted_s(:long_ordinal)
 
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
      if jdb.datebi>=@date_2013
        jdb.datetag='2013'
      else  
        jdb.datetag='pre2013'
      end
       jdb.daystopay='n/a'    
       jobs << jdb
       end
      end
      
      #________
      upcomingdnfs=Jobdnf.search_incomplete_dnfs job.JobID
      upcomingdnfs.each do |dnf|
        job_bundle=JobBundle.new
        job_bundle.typedesc='upcomingdnf'
        job_bundle.jobdnf='dnf'
        job_bundle.jobid=dnf.DNFID+'['+job.JobID+']'
        job_bundle.address=job.property.address
        job_bundle.jobdesc=dnf.DnfDesc
         empList=Employee.find_by_hrid(dnf.register)
         emp=empList.last
         name="unknown"
         if !emp.nil?
           name=emp.name
         end
         job_bundle.salesp=name
         job_bundle.datesold=dnf.Dnfdate.to_formatted_s(:long_ordinal)
 
        if(dnf.Sdate==dnf.Fdate)
          job_bundle.type='Appt('+dnf.Stime+')'
        else  
          job_bundle.type='Fltr'
        end
        puts nil.to_formatted_s(:long_ordinal)
        job_bundle.sdate=dnf.Sdate.to_formatted_s(:long_ordinal)
        job_bundle.datetag='2013'
        jobs << job_bundle
      end

      
      #__________
      sat=job.satisfaction
      if !sat.nil?
        sb=JobBundle.new
        sb.typedesc='satjob'
        sb.jobdnf='sat'
        sb.jobid='Sat for:'+job.JobID
        sb.address=job.property.address
        sb.jobdesc=sat.Comments
        emp=Employee.find(sat.Caller)
        if(!emp.nil?)
          sb.crewname=emp.name
        end
        sb.minutes='n/a'
        sb.datebi=sat.SatDate.to_formatted_s(:long_ordinal)
        if sat.SatDate>=@date_2013
          sb.datetag='2013'
        else  
          sb.datetag='pre2013'
        end

        sb.daystopay='n/a'    
        jobs << sb
      end     
    end
  
    upcomingjobs=client.upcoming_jobs
    upcomingjobs.each do |job|
      job_bundle=JobBundle.new
      job_bundle.typedesc='upcomingjob'
      job_bundle.jobdnf='job'
      job_bundle.jobid=job.JobID
      job_bundle.address=job.property.address
      job_bundle.jobdesc=job.JobDesc
      job_bundle.price=job.Price
       empList=Employee.find_by_hrid(job.SalesID1)
       emp=empList.last
       name="unknown"
       if !emp.nil?
         name=emp.name
       end
       job_bundle.salesp=name
       job_bundle.datesold=job.Datesold.to_formatted_s(:long_ordinal)
 
      if(job.Sdate==job.Fdate)
        job_bundle.type='Appt('+job.Stime+')'
      else  
        job_bundle.type='Fltr'
      end
      job_bundle.sdate=job.Sdate.to_formatted_s(:long_ordinal)
      job_bundle.datetag='2013'

      jobs << job_bundle
    end      
  
    return jobs
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
    num=params[:num]
    if !num.nil?
      session[:num]=num
    end
    
    crs=Clientrate.find_rating @cfid
    overallrate='2.5'
    cr=crs.first
    if !cr.nil?
      overallrate=cr.overallrate
    end
    cfid=@client.CFID
    name='unknown'
    if !@client.full_name.nil?
      name=@client.full_name
    end
    address='unknown'
    if !@client.address.nil?
      address=@client.address
    end
    phone='unknown'
    if !@client.phone.nil?
      phone=@client.phone
    end
    @client_header1= @client.CFID
    @client_header2=name
    @client_header3=address+' '+phone
    @client_header4='Rating:'+overallrate.to_s
    
    if @client.registerdate.nil? || @client.registerdate==''
      @client_header5='Date Registered: unknown'
    else 
      emps=Employee.name_from_id @client.registerperson
      e=emps.first
      @client_header5="Registered By:"+ e.name 
      temp=" On "+@client.registerdate.to_formatted_s(:long_ordinal)
      @client_header5+=temp
    end
    @call_client_form=CallClientForm.new
    @sat_call_form=SatCallForm.new
    @tstatus_options=HomeHelper::CALL_OPTIONS
 
    date=HomeHelper.add_days_to_current_date(1)
    date10=HomeHelper.add_days_to_date date,10
    date10s=date10.to_s
    
    @selected_foll_year=date10s[0,4]
    @selected_foll_month=HomeHelper.get_month_from_num(date10s[5,2]) 
    @selected_foll_day=date10s[8,2]
 
    @year10=date10s[0,4]
    @month10=HomeHelper.get_month_from_num(date10s[5,2]) 
    @day10=date10s[8,2]
    
    
    @sat_options=HomeHelper::SAT_TYPES
    @years=HomeHelper::YEARS
    @months=HomeHelper::MONTHS
    @days=HomeHelper::DAYS
    @calls=@client.clientcontacts
    @call_info=[]      
    @date5=Date.parse("2013-04-01")

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

    @jobs=clientprofile_jobs(@client)  
    @jobs_2013=[]
    @jobs_all=[]
    @jobs_upcoming=[]


#        sb=JobBundle.new
#        sb.typedesc='satjob'
#        sb.jobdnf='sat'

    
    @jobs.each do |job|
      if job.datetag=='2013' && ((job.typedesc!='upcomingjob') && (job.typedesc!='upcomingdnf')) 
        @jobs_2013<<job    
      end
      if (job.typedesc=='upcomingjob' || job.typedesc=='upcomingdnf')
        @jobs_upcoming<<job
      end
      @jobs_all<<job
    end
    
    @edit_client_form=EditClientForm.new
    @prices_all=HomeHelper::get_props_and_prices(@client)
    @contact_options=HomeHelper::CLIENT_CONTACT_STATUS
    @selected_contact=@client.contactstatus
#    @call_info=@call_info.uniq
  end


  def selljob
    @test="sell HI HO"
    @cfid=params[:id]
    @client=Client.find(@cfid)
  end
    
  def editclient
    cfid=params[:id]
    @jobid1=params[:jobid1]
    
    @source=params[:source]
    @function=params[:function]
    client=Client.find cfid
    ecf=EditClientForm.new(params[:edit_client_form]) 
    client.company=ecf.company
    client.honorific=ecf.honorific
    client.firstname=ecf.firstname
    client.lastname=ecf.lastname
    #client.address=ecf.address
    client.city=ecf.city
    client.province  =ecf.province
    client.postcode  =ecf.postcode
    client.perly  =ecf.perly
    client.phone  =ecf.phone
    client.offphone  =ecf.offphone
    client.cellphone  =ecf.cellphone
    client.fax  =ecf.fax
    client.email  =ecf.email
    client.contactstatus= ecf.contactstatus
    client.save!

    cc=Convertcalls.find cfid
    cc.clientstatus=ecf.contactstatus
    cc.save!
    
    redirect_to clientprofile_function_url(:id=>cfid, :jobid1=>@jobid1, :source=>@source, :function=>@function)
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
    @action='Screen Message'
    render 'logmessage'
  end
  
  def makednf
    @jobid=params[:jobid]
    @source=params[:source]
    @function=params[:function]
    @num=params[:num]
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
    redirect_to clientprofile_function_url(:cfid=>cfid, :source=>@source, :function=>@function, :cfmess=>cfmess)
  end

  def modifydnf
    @jobid1=params[:jobid1]
    @source=params[:source]
    @function=params[:function]
    @num=params[:num]
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
  
  def loadsatisfaction
    @sat_form=SatForm.new
    @syear_options=HomeHelper::YEARS
    @smonth_options=HomeHelper::MONTHS
    @sday_options=HomeHelper::DAYS
    @fyear_options=HomeHelper::YEARS
    @fmonth_options=HomeHelper::MONTHS
    @fday_options=HomeHelper::DAYS
    
    type=params[:type]
    if(!type.nil?&&type='reload')
      @selected_syear=session[:syear]
      selected_smonth=session[:smonth]
      @selected_smonth=HomeHelper::get_month_from_num(selected_smonth)
      @selected_sday=session[:sday]
      @selected_fyear=session[:fyear]
      selected_fmonth=session[:fmonth]
      @selected_fmonth=HomeHelper::get_month_from_num(selected_fmonth)
      @selected_fday=session[:fday]
      @lowjob=session[:lowjobsat] 
      @limit=session[:limitsat]
    else      
      satdate=Satisfaction.max_satdate
      satdate=satdate.to_s
      puts 'SATDATE',satdate
      #job=Job.find jobid
      #datebi=job.Datebi.to_s
      year=satdate[0,4]
      month=satdate[5,2]
      day=satdate[8,2]
      month=HomeHelper.get_month_from_num month
      @lowjob='JB00000001'
      @limit='20'
      @selected_syear='2013'
      @selected_smonth='Apr'
      @selected_sday='01'
      @selected_fyear=year
      @selected_fmonth=month
      @selected_fday=day
    end
 end

  
 def generate_sat_list(sdate, fdate, limit, lowjobsat)
    sat_jobids=[]
    job_jobids=[]
    jobs=Job.search_jobs_for_sats sdate, fdate, limit, lowjobsat
    jobs.each do |job|
      job_jobids<<job.JobID  
      sats=Satisfaction.search_sats_job job.JobID
      sat=sats.first
      if !sat.nil? && sat.SatDate!=Date.today
        sat_jobids<<sat.JobID
      end
    end
    need_sat_jobids=job_jobids-sat_jobids
    @numsats=need_sat_jobids.length
    done_jobs=[]
    i=0
    need_sat_jobids.each do |jobid|
      job=Job.find jobid
      prop=job.property
      cfid=prop.CFID
      
      job_bundle=JobBundle.new
      job_bundle.num=i
      sats=Satisfaction.search_sats_job job.JobID
      sat=sats.first

      if !sat.nil? && sat.SatDate==Date.today
        sat_jobids<<sat.JobID
        job_bundle.type='redblackcell'
        
      else  
        job_bundle.type='cell'
      end
      
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
      job_bundle.datebi=job.Datebi.to_formatted_s(:long_ordinal)
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
    sf=SatForm.new(params[:sat_form])
    limit=sf.limit
    lowjob=sf.lowjob
    lowjob=HomeHelper::pad_id_num 'JB', lowjob
    session[:lowjobsat]=lowjob
    session[:limitsat]=limit

    syear=sf.syear
    smonth=sf.smonth
    smonth=HomeHelper.get_num_from_month(smonth)
    sday=sf.sday
    fyear=sf.fyear
    fmonth=sf.fmonth
    fmonth=HomeHelper.get_num_from_month(fmonth)
    fday=sf.fday
    session[:syear]=syear
    session[:smonth]=smonth
    session[:sday]=sday
    session[:fyear]=fyear
    session[:fmonth]=fmonth
    session[:fday]=fday
    
    sdate=Date.parse(syear+'-'+smonth+'-'+sday)
    fdate=Date.parse(fyear+'-'+fmonth+'-'+fday)
 
    @done_jobs=generate_sat_list sdate, fdate, limit, lowjob
    @source='satcall'
    @function='satcall'
  end
  
  def nextsat
    @source=params[:source]
    @function=params[:function]
    lowjob=session[:lowjobsat]
    limit=session[:limitsat]
    syear=session[:syear]
    smonth=session[:smonth]
    sday=session[:sday]
    fyear=session[:fyear]
    fmonth=session[:fmonth]
    fday=session[:fday]
    
    sdate=Date.parse(syear+'-'+smonth+'-'+sday)
    fdate=Date.parse(fyear+'-'+fmonth+'-'+fday)

    jobs=Job.search_jobs_for_sats sdate, fdate, limit, lowjob
    job=jobs.last
    session[:lowjobsat]=job.JobID
    lowjob=session[:lowjobsat]
  
 
    @done_jobs=generate_sat_list sdate, fdate, limit, lowjob
  #  Utils.fill_sat_jobs @done_jobs
 
    render 'satisfaction' 
  end

  def satisfaction1
    syear=session[:syear]
    smonth=session[:smonth]
    sday=session[:sday]
    fyear=session[:fyear]
    fmonth=session[:fmonth]
    fday=session[:fday]
    sdate=Date.parse(syear+'-'+smonth+'-'+sday)
    fdate=Date.parse(fyear+'-'+fmonth+'-'+fday)
    lowjob=session[:lowjobsat]
    limit=session[:limitsat]
    @done_jobs=generate_sat_list sdate, fdate, limit, lowjob
    render 'satisfaction'
  end


  def satisfaction_from_client_profile
    id=params[:id]
    jobid1=params[:jobid1]
    syear=session[:syear]
    smonth=session[:smonth]
    sday=session[:sday]
    fyear=session[:fyear]
    fmonth=session[:fmonth]
    fday=session[:fday]
    
    sdate=Date.parse(syear+'-'+smonth+'-'+sday)
    fdate=Date.parse(fyear+'-'+fmonth+'-'+fday)
    @done_jobs=generate_sat_list sdate, fdate, '1', jobid1

    source=params[:source]
    function=params[:function]
    redirect_to clientprofile_function_url(:cfid=>id,:jobid1=>jobid1, :source=>source, :function=>function)
  end


  def nextsatclient
    jobid5=params[:jobid1]
    @cfid=params[:cfid]
    @source=params[:source]
    @function=params[:function]
    jobid5=params[:jobid1]
    sat_jobids=[]
    job_jobids=[]
    syear=session[:syear]
    smonth=session[:smonth]
    sday=session[:sday]
    fyear=session[:fyear]
    fmonth=session[:fmonth]
    fday=session[:fday]
    
    
    sdate=Date.parse(syear+'-'+smonth+'-'+sday)
    fdate=Date.parse(fyear+'-'+fmonth+'-'+fday)
    lowjob=session[:lowjobsat]
    limit=session[:limitsat]
    @done_jobs=generate_sat_list sdate, fdate, limit, lowjob
    #@done_jobs=Utils.get_sat_jobs
    next_jobid=jobid5
      puts 'current', jobid5
    @done_jobs.each do |job|
      jobid=job.jobid
      puts 'new,current', jobid,jobid5
      if ((jobid<=>jobid5).to_i==1)
          next_jobid=jobid
          break
      end      
    end
      puts 'new', next_jobid
    if next_jobid==jobid5
      session[:lowjobsat]=jobid5
      redirect_to loadsatisfaction_functions_path(:type=>'reload')
      return
    end  
    job=Job.find next_jobid
    prop=Property.find job.JobInfoID
    redirect_to clientprofile_function_path(:id => prop.CFID, :jobid1=>next_jobid, :source=>@source, :function=>@function)
  end
  
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
  
  def stats1
    @username=session[:username]

    @sbs=Utils.withdraw_stats
    @indstats=Utils.withdraw_indstats
    @indstats7=Utils.withdraw_indstats7
    @ts_co=Utils.get_stat_co_time   
    @ts_ind=Utils.get_stat_ind_time   
    @ts_ind7=Utils.get_stat_ind_time7   
    render 'stats'
  end
  
  def co_stats
    @sbs=[]
    stats=[]
    sb=StatBundle.new
    today=Date.today
    @date_2008=Date.parse('2008-01-01')
    @date_2009=@date_2008 >> 12
    @date_2010=@date_2009 >> 12
    @date_2011=@date_2010 >> 12
    @date_2012=@date_2011 >> 12
    @date_2013=@date_2012 >> 12

    @date_today_2013=today
    @date_last7_2013=HomeHelper.add_days_to_date @date_today_2013 , -8
    @date_yesterday_2013=HomeHelper.add_days_to_date @date_today_2013 , -1
    
    @date_today_2012=@date_today_2013 << 12
    @date_today_2012=HomeHelper.add_days_to_date @date_today_2012 , 1
    @date_last7_2012=HomeHelper.add_days_to_date @date_today_2012 , -8
    @date_next7_2012=HomeHelper.add_days_to_date @date_today_2012 , 8
    @date_yesterday_2012=HomeHelper.add_days_to_date @date_today_2012 , -1
    @date_tomorrow_2012=HomeHelper.add_days_to_date @date_today_2012 , 1
    @date_two_2012=HomeHelper.add_days_to_date @date_today_2012 , 2
    @date_three_2012=HomeHelper.add_days_to_date @date_today_2012 , 3
    @date_four_2012=HomeHelper.add_days_to_date @date_today_2012 , 4
    @date_five_2012=HomeHelper.add_days_to_date @date_today_2012 , 5
    
    @date_today_2011=@date_today_2012 << 12
    @date_today_2011=HomeHelper.add_days_to_date @date_today_2011 , 2
    @date_last7_2011=HomeHelper.add_days_to_date @date_today_2011 , -8
    @date_next7_2011=HomeHelper.add_days_to_date @date_today_2011 , 8
    @date_yesterday_2011=HomeHelper.add_days_to_date @date_today_2011 , -1
    @date_tomorrow_2011=HomeHelper.add_days_to_date @date_today_2011 , 1
    @date_two_2011=HomeHelper.add_days_to_date @date_today_2011 , 2
    @date_three_2011=HomeHelper.add_days_to_date @date_today_2011 , 3
    @date_four_2011=HomeHelper.add_days_to_date @date_today_2011 , 4
    @date_five_2011=HomeHelper.add_days_to_date @date_today_2011 , 5
    
    @date_today_2010=@date_today_2011 << 12
    @date_today_2010=HomeHelper.add_days_to_date @date_today_2010 , -6
    @date_last7_2010=HomeHelper.add_days_to_date @date_today_2010 , -8
    @date_next7_2010=HomeHelper.add_days_to_date @date_today_2010 , 8
    @date_yesterday_2010=HomeHelper.add_days_to_date @date_today_2010 , -1
    @date_tomorrow_2010=HomeHelper.add_days_to_date @date_today_2010 , 1
    @date_two_2010=HomeHelper.add_days_to_date @date_today_2010 , 2
    @date_three_2010=HomeHelper.add_days_to_date @date_today_2010 , 3
    @date_four_2010=HomeHelper.add_days_to_date @date_today_2010 , 4
    @date_five_2010=HomeHelper.add_days_to_date @date_today_2010 , 5
    
    @date_today_2009=@date_today_2010 << 12
    @date_today_2009=HomeHelper.add_days_to_date @date_today_2009 , 1
    @date_last7_2009=HomeHelper.add_days_to_date @date_today_2009 , -8
    @date_next7_2009=HomeHelper.add_days_to_date @date_today_2009 , 8
    @date_yesterday_2009=HomeHelper.add_days_to_date @date_today_2009 , -1
    @date_tomorrow_2009=HomeHelper.add_days_to_date @date_today_2009 , 1
    @date_two_2009=HomeHelper.add_days_to_date @date_today_2009 , 2
    @date_three_2009=HomeHelper.add_days_to_date @date_today_2009 , 3
    @date_four_2009=HomeHelper.add_days_to_date @date_today_2009 , 4
    @date_five_2009=HomeHelper.add_days_to_date @date_today_2009 , 5
    
    
    @date_today_2008=@date_today_2009 << 12
    @date_today_2008=HomeHelper.add_days_to_date @date_today_2008 , 1
    @date_last7_2008=HomeHelper.add_days_to_date @date_today_2008 , -8
    @date_next7_2008=HomeHelper.add_days_to_date @date_today_2008 , 8
    @date_yesterday_2008=HomeHelper.add_days_to_date @date_today_2008 , -1
    @date_tomorrow_2008=HomeHelper.add_days_to_date @date_today_2008 , 1
    @date_two_2008=HomeHelper.add_days_to_date @date_today_2008 , 2
    @date_three_2008=HomeHelper.add_days_to_date @date_today_2008 , 3
    @date_four_2008=HomeHelper.add_days_to_date @date_today_2008 , 4
    @date_five_2008=HomeHelper.add_days_to_date @date_today_2008 , 5
    
    
    @date_summer_2008=Date.parse('2008-09-30')
    @date_summer_2009=Date.parse('2009-09-30')
    @date_summer_2010=Date.parse('2010-09-30')
    @date_summer_2011=Date.parse('2011-09-30')
    @date_summer_2012=Date.parse('2012-09-30')
    @date_summer_2013=Date.parse('2013-09-30')

    sb=StatBundle.new
    sb.year=@date_2013.to_s[0,4]
    sb.salesytd=Job.number_jobs_sold @date_2013, @date_today_2013, @date_summer_2013
    sb.salescurr=Job.number_jobs_sold @date_today_2013, @date_today_2013, @date_summer_2013
    sb.yesterday=Job.number_jobs_sold @date_yesterday_2013, @date_yesterday_2013, @date_summer_2013
    sb.lastseven=Job.number_jobs_sold @date_last7_2013, @date_yesterday_2013, @date_summer_2013
    sb.tomorrow='unknown'
    sb.two='unknown'
    sb.three='unknown'
    sb.four='unknown'
    sb.five='unknown'
    sb.nextseven='unknown'
    @sbs<<sb        
    stats<<sb

    sb=StatBundle.new
    sb.year=@date_2012.to_s[0,4]
    sb.salesytd=Job.number_jobs_sold @date_2012, @date_today_2012, @date_summer_2012
    sb.salescurr=Job.number_jobs_sold @date_today_2012, @date_today_2012, @date_summer_2012
    sb.yesterday=Job.number_jobs_sold @date_yesterday_2012, @date_yesterday_2012, @date_summer_2012
    sb.lastseven=Job.number_jobs_sold @date_last7_2012, @date_yesterday_2012, @date_summer_2012
    sb.tomorrow=Job.number_jobs_sold @date_tomorrow_2012, @date_tomorrow_2012, @date_summer_2012
    sb.two=Job.number_jobs_sold @date_two_2012, @date_two_2012, @date_summer_2012
    sb.three=Job.number_jobs_sold @date_three_2012, @date_three_2012, @date_summer_2012
    sb.four=Job.number_jobs_sold @date_four_2012, @date_four_2012, @date_summer_2012
    sb.five=Job.number_jobs_sold @date_five_2012, @date_five_2012, @date_summer_2012
    sb.nextseven=Job.number_jobs_sold @date_tomorrow_2012, @date_next7_2012, @date_summer_2012
    @sbs<<sb        
    stats<<sb

    sb=StatBundle.new
    sb.year=@date_2011.to_s[0,4]
    sb.salesytd=Job.number_jobs_sold @date_2011, @date_today_2011, @date_summer_2011
    sb.salescurr=Job.number_jobs_sold @date_today_2011, @date_today_2011, @date_summer_2011
    sb.yesterday=Job.number_jobs_sold @date_yesterday_2011, @date_yesterday_2011, @date_summer_2011
    sb.lastseven=Job.number_jobs_sold @date_last7_2011, @date_yesterday_2011, @date_summer_2011
    sb.tomorrow=Job.number_jobs_sold @date_tomorrow_2011, @date_tomorrow_2011, @date_summer_2011
    sb.two=Job.number_jobs_sold @date_two_2011, @date_two_2011, @date_summer_2011
    sb.three=Job.number_jobs_sold @date_three_2011, @date_three_2011, @date_summer_2011
    sb.four=Job.number_jobs_sold @date_four_2011, @date_four_2011, @date_summer_2011
    sb.five=Job.number_jobs_sold @date_five_2011, @date_five_2011, @date_summer_2011
    sb.nextseven=Job.number_jobs_sold @date_tomorrow_2011, @date_next7_2011, @date_summer_2011
    @sbs<<sb        
    stats<<sb

    sb=StatBundle.new
    sb.year=@date_2010.to_s[0,4]
    sb.salesytd=Job.number_jobs_sold @date_2010, @date_today_2010, @date_summer_2010
    sb.salescurr=Job.number_jobs_sold @date_today_2010, @date_today_2010, @date_summer_2010
    sb.yesterday=Job.number_jobs_sold @date_yesterday_2010, @date_yesterday_2010, @date_summer_2010
    sb.lastseven=Job.number_jobs_sold @date_last7_2010, @date_yesterday_2010, @date_summer_2010
    sb.tomorrow=Job.number_jobs_sold @date_tomorrow_2010, @date_tomorrow_2010, @date_summer_2010
    sb.two=Job.number_jobs_sold @date_two_2010, @date_two_2010, @date_summer_2010
    sb.three=Job.number_jobs_sold @date_three_2010, @date_three_2010, @date_summer_2010
    sb.four=Job.number_jobs_sold @date_four_2010, @date_four_2010, @date_summer_2010
    sb.five=Job.number_jobs_sold @date_five_2010, @date_five_2010, @date_summer_2010
    sb.nextseven=Job.number_jobs_sold @date_tomorrow_2010, @date_next7_2010, @date_summer_2010
    @sbs<<sb        
    stats<<sb

    sb=StatBundle.new
    sb.year=@date_2009.to_s[0,4]
    sb.salesytd=Job.number_jobs_sold @date_2009, @date_today_2009, @date_summer_2009
    sb.salescurr=Job.number_jobs_sold @date_today_2009, @date_today_2009, @date_summer_2009
    sb.yesterday=Job.number_jobs_sold @date_yesterday_2009, @date_yesterday_2009, @date_summer_2009
    sb.lastseven=Job.number_jobs_sold  @date_last7_2009, @date_yesterday_2009, @date_summer_2009
    sb.tomorrow=Job.number_jobs_sold @date_tomorrow_2009, @date_tomorrow_2009, @date_summer_2009
    sb.two=Job.number_jobs_sold @date_two_2009, @date_two_2009, @date_summer_2009
    sb.three=Job.number_jobs_sold @date_three_2009, @date_three_2009, @date_summer_2009
    sb.four=Job.number_jobs_sold @date_four_2009, @date_four_2009, @date_summer_2009
    sb.five=Job.number_jobs_sold @date_five_2009, @date_five_2009, @date_summer_2009
    sb.nextseven=Job.number_jobs_sold @date_tomorrow_2009, @date_next7_2009, @date_summer_2009
    @sbs<<sb        
    stats<<sb

    sb=StatBundle.new
    sb.year=@date_2008.to_s[0,4]
    sb.salesytd=Job.number_jobs_sold @date_2008, @date_today_2008, @date_summer_2008
    sb.salescurr=Job.number_jobs_sold @date_today_2008, @date_today_2008, @date_summer_2008
    sb.yesterday=Job.number_jobs_sold @date_yesterday_2008, @date_yesterday_2008, @date_summer_2008
    sb.lastseven=Job.number_jobs_sold @date_last7_2008, @date_yesterday_2008, @date_summer_2008
    sb.tomorrow=Job.number_jobs_sold @date_tomorrow_2008, @date_tomorrow_2008, @date_summer_2008
    sb.two=Job.number_jobs_sold @date_two_2008, @date_two_2008, @date_summer_2008
    sb.three=Job.number_jobs_sold @date_three_2008, @date_three_2008, @date_summer_2008
    sb.four=Job.number_jobs_sold @date_four_2008, @date_four_2008, @date_summer_2008
    sb.five=Job.number_jobs_sold @date_five_2008, @date_five_2008, @date_summer_2008
    sb.nextseven=Job.number_jobs_sold @date_tomorrow_2008, @date_next7_2008, @date_summer_2008
    @sbs<<sb        
    stats<<sb
    
    x=Utils.format_postal_code "m5r 2l4"
    
    
    #Utils.log1 "test"
    Utils.deposit_stats stats
    ts=Time.now.to_s 
    Utils.record_stat_co_time ts
    redirect_to login1_functions_url
  end

  def ind_stats
    @date_summer1=Date.parse('2013-04-01')
    @date_summer2=Date.today
    
    ids=Clientcontact.callers

    @indstats={}     
    personal_bundle=PersonalBundle.new
    total_bundle=PersonalBundle.new
    total_bundle.name5='Total'
    total_bundle.sales='0'
    total_bundle.atts='0'
    total_bundle.attscurr='0'
    total_bundle.salescurr='0'
    
    ids.each do |id|
      personal_bundle=PersonalBundle.new
      emps=Employee.name_from_id id
      name=emps.first.name  
      salesass=Convertcalls.sales_by_assist @date_summer1, @date_summer2, id
      salesdir=Convertcalls.sales_by_direct @date_summer1, @date_summer2, id
      sales=salesass.to_i+salesdir.to_i
      atts=Clientcontact.num_cfcontacts_summer2013_ind id
      attscurr=Clientcontact.num_cfcontacts_summer2013_ind_curr id, @date_summer2
      salescurr=Job.number_jobs_sold_ind_curr id, @date_summer2          
      personal_bundle.name5=name
      personal_bundle.salesass=salesass
      personal_bundle.salesdir=salesdir
      personal_bundle.sales=sales
      totsales=total_bundle.sales.to_i+sales.to_i
      total_bundle.sales=totsales.to_s
      
      personal_bundle.atts=atts
      totatts=total_bundle.atts.to_i+atts.to_i
      total_bundle.atts=totatts.to_s
      
      personal_bundle.attscurr=attscurr
      totattscurr=total_bundle.attscurr.to_i+attscurr.to_i
      total_bundle.attscurr=totattscurr.to_s

      personal_bundle.salescurr=salescurr
      totsalescurr=total_bundle.salescurr.to_i+salescurr.to_i
      total_bundle.salescurr=totsalescurr.to_s

      good_sales=salesass.to_i+salesdir.to_i

      if(atts!=0)
        per=sales*100/atts
        per5=HomeHelper.pad_num3 per
        personal_bundle.per=per
        good_sales5='00000'+id
        if good_sales!=0
          good_sales5=(HomeHelper.pad_num5 good_sales.to_s)+id
        end
        @indstats[(good_sales5).to_s.to_sym]=personal_bundle
      end
    end

      if(total_bundle.atts!=0)
        sales=total_bundle.sales
        atts=total_bundle.atts
        per=sales.to_i*100/atts.to_i
        per5=HomeHelper.pad_num3 per
        total_bundle.per=per.to_s
        @indstats[(-1).to_s.to_sym]=total_bundle
      end
    
    @indstats=@indstats.sort_by{|sales, pb| sales}
    @indstats=@indstats.reverse!
    
    Utils.deposit_indstats @indstats
    ts=Time.now.to_s 
    Utils.record_stat_ind_time ts   
    redirect_to login1_functions_url
  end

  def ind_stats_7
    @date_summer1=Date.today-7
    @date_summer2=Date.today
    
    ids=Clientcontact.callers

    @indstats7={}     
    personal_bundle=PersonalBundle.new
    total_bundle=PersonalBundle.new
    total_bundle.name5='Total'
    total_bundle.sales='0'
    total_bundle.atts='0'
    total_bundle.attscurr='0'
    total_bundle.salescurr='0'
    
    ids.each do |id|
      personal_bundle=PersonalBundle.new
      emps=Employee.name_from_id id
      name=emps.first.name  
      salesass=Convertcalls.sales_by_assist @date_summer1, @date_summer2, id
      salesdir=Convertcalls.sales_by_direct @date_summer1, @date_summer2, id
      sales=salesass.to_i+salesdir.to_i
      atts=Clientcontact.num_cfcontacts_summer2013_ind id
      attscurr=Clientcontact.num_cfcontacts_summer2013_ind_curr id, @date_summer2
      salescurr=Job.number_jobs_sold_ind_curr id, @date_summer2          
      personal_bundle.name5=name
      personal_bundle.salesass=salesass
      personal_bundle.salesdir=salesdir
      personal_bundle.sales=sales
      totsales=total_bundle.sales.to_i+sales.to_i
      total_bundle.sales=totsales.to_s
      
      personal_bundle.atts=atts
      totatts=total_bundle.atts.to_i+atts.to_i
      total_bundle.atts=totatts.to_s
      
      personal_bundle.attscurr=attscurr
      totattscurr=total_bundle.attscurr.to_i+attscurr.to_i
      total_bundle.attscurr=totattscurr.to_s

      personal_bundle.salescurr=salescurr
      totsalescurr=total_bundle.salescurr.to_i+salescurr.to_i
      total_bundle.salescurr=totsalescurr.to_s

      good_sales=salesass.to_i+salesdir.to_i

      if(atts!=0)
        per=sales*100/atts
        per5=HomeHelper.pad_num3 per
        personal_bundle.per=per
        good_sales5='00000'+id
        if good_sales!=0
          good_sales5=(HomeHelper.pad_num5 good_sales.to_s)+id
        end
        @indstats7[(good_sales5).to_s.to_sym]=personal_bundle
      end
    end

      if(total_bundle.atts!=0)
        sales=total_bundle.sales
        atts=total_bundle.atts
        per=sales.to_i*100/atts.to_i
        per5=HomeHelper.pad_num3 per
        total_bundle.per=per.to_s
        @indstats7[(-1).to_s.to_sym]=total_bundle
      end
    
    @indstats7=@indstats7.sort_by{|sales, pb| sales}
    @indstats7=@indstats7.reverse!
    
    Utils.deposit_indstats7 @indstats7
    ts=Time.now.to_s 
    Utils.record_stat_ind_time7 ts   
    redirect_to login1_functions_url
  end


   
  def stats_schedule
    @sched_stats=[]
    @sched_stats_ytd=[]
    ssb=ScheduleStatBundle.new 
    
    date2013 = Date.today
    date2012 = date2013 << 12
    date2011 = date2012 << 12
    date2010 = date2011 << 12
    date2009 = date2010 << 12
    date2008 = date2009 << 12
    
    ssb.year='2013 Current'
    ssb.may1=Job.number_jobs_schedule_curr Date.parse('2013-05-01'), Date.parse('2013-05-15')     
    ssb.may2=Job.number_jobs_schedule_curr Date.parse('2013-05-16'), Date.parse('2013-05-31')
    ssb.june1=Job.number_jobs_schedule_curr Date.parse('2013-06-01'), Date.parse('2013-06-15')
    ssb.june2=Job.number_jobs_schedule_curr Date.parse('2013-06-16'), Date.parse('2013-06-30') 
    ssb.july1=Job.number_jobs_schedule_curr Date.parse('2013-07-01'), Date.parse('2013-07-15')     
    ssb.july2=Job.number_jobs_schedule_curr Date.parse('2013-07-16'), Date.parse('2013-07-31') 
    ssb.august=Job.number_jobs_schedule_curr Date.parse('2013-08-01'), Date.parse('2013-08-31')     
    ssb.september=Job.number_jobs_schedule_curr Date.parse('2013-09-01'), Date.parse('2013-09-30') 
    ssb.october=Job.number_jobs_schedule_curr Date.parse('2013-10-01'), Date.parse('2013-10-31') 
    ssb.november=Job.number_jobs_schedule_curr Date.parse('2013-11-01'), Date.parse('2013-11-30')
    @sched_stats_ytd<<ssb 

    ssb=ScheduleStatBundle.new 
    ssb.year='2013 YTD'
    ssb.may1=Job.number_jobs_schedule_ytd Date.parse('2013-05-01'), Date.parse('2013-05-15'), date2013     
    ssb.may2=Job.number_jobs_schedule_ytd Date.parse('2013-05-16'), Date.parse('2013-05-31'), date2013 
    ssb.june1=Job.number_jobs_schedule_ytd Date.parse('2013-06-01'), Date.parse('2013-06-15'), date2013     
    ssb.june2=Job.number_jobs_schedule_ytd Date.parse('2013-06-16'), Date.parse('2013-06-30'), date2013 
    ssb.july1=Job.number_jobs_schedule_ytd Date.parse('2013-07-01'), Date.parse('2013-07-15'), date2013     
    ssb.july2=Job.number_jobs_schedule_ytd Date.parse('2013-07-16'), Date.parse('2013-07-31'), date2013 
    ssb.august=Job.number_jobs_schedule_ytd Date.parse('2013-08-01'), Date.parse('2013-08-31'), date2013     
    ssb.september=Job.number_jobs_schedule_ytd Date.parse('2013-09-01'), Date.parse('2013-09-30'), date2013 
    ssb.october=Job.number_jobs_schedule_ytd Date.parse('2013-10-01'), Date.parse('2013-10-31'), date2013 
    ssb.november=Job.number_jobs_schedule_ytd Date.parse('2013-11-01'), Date.parse('2013-11-30'), date2013
    @sched_stats_ytd<<ssb 

    ssb=ScheduleStatBundle.new 
    ssb.year='2012 YTD'
    ssb.may1=Job.number_jobs_schedule_ytd Date.parse('2012-05-01'), Date.parse('2012-05-15'), date2012     
    ssb.may2=Job.number_jobs_schedule_ytd Date.parse('2012-05-16'), Date.parse('2012-05-31'), date2012 
    ssb.june1=Job.number_jobs_schedule_ytd Date.parse('2012-06-01'), Date.parse('2012-06-15'), date2012     
    ssb.june2=Job.number_jobs_schedule_ytd Date.parse('2012-06-16'), Date.parse('2012-06-30'), date2012 
    ssb.july1=Job.number_jobs_schedule_ytd Date.parse('2012-07-01'), Date.parse('2012-07-15'), date2012     
    ssb.july2=Job.number_jobs_schedule_ytd Date.parse('2012-07-16'), Date.parse('2012-07-31'), date2012 
    ssb.august=Job.number_jobs_schedule_ytd Date.parse('2012-08-01'), Date.parse('2012-08-31'), date2012     
    ssb.september=Job.number_jobs_schedule_ytd Date.parse('2012-09-01'), Date.parse('2012-09-30'), date2012 
    ssb.october=Job.number_jobs_schedule_ytd Date.parse('2012-10-01'), Date.parse('2012-10-31'), date2012 
    ssb.november=Job.number_jobs_schedule_ytd Date.parse('2012-11-01'), Date.parse('2012-11-30'), date2012
    @sched_stats_ytd<<ssb 

    ssb=ScheduleStatBundle.new 
    ssb.year='2011 YTD'
    ssb.may1=Job.number_jobs_schedule_ytd Date.parse('2011-05-01'), Date.parse('2011-05-15'), date2011     
    ssb.may2=Job.number_jobs_schedule_ytd Date.parse('2011-05-16'), Date.parse('2011-05-31'), date2011 
    ssb.june1=Job.number_jobs_schedule_ytd Date.parse('2011-06-01'), Date.parse('2011-06-15'), date2011     
    ssb.june2=Job.number_jobs_schedule_ytd Date.parse('2011-06-16'), Date.parse('2011-06-30'), date2011 
    ssb.july1=Job.number_jobs_schedule_ytd Date.parse('2011-07-01'), Date.parse('2011-07-15'), date2011     
    ssb.july2=Job.number_jobs_schedule_ytd Date.parse('2011-07-16'), Date.parse('2011-07-31'), date2011 
    ssb.august=Job.number_jobs_schedule_ytd Date.parse('2011-08-01'), Date.parse('2011-08-31'), date2011     
    ssb.september=Job.number_jobs_schedule_ytd Date.parse('2011-09-01'), Date.parse('2011-09-30'), date2011 
    ssb.october=Job.number_jobs_schedule_ytd Date.parse('2011-10-01'), Date.parse('2011-10-31'), date2011 
    ssb.november=Job.number_jobs_schedule_ytd Date.parse('2011-11-01'), Date.parse('2011-11-30'), date2011
    @sched_stats_ytd<<ssb 
    
    ssb=ScheduleStatBundle.new 
    ssb.year='2010 YTD'
    ssb.may1=Job.number_jobs_schedule_ytd Date.parse('2010-05-01'), Date.parse('2010-05-15'), date2010     
    ssb.may2=Job.number_jobs_schedule_ytd Date.parse('2010-05-16'), Date.parse('2010-05-31'), date2010 
    ssb.june1=Job.number_jobs_schedule_ytd Date.parse('2010-06-01'), Date.parse('2010-06-15'), date2010     
    ssb.june2=Job.number_jobs_schedule_ytd Date.parse('2010-06-16'), Date.parse('2010-06-30'), date2010 
    ssb.july1=Job.number_jobs_schedule_ytd Date.parse('2010-07-01'), Date.parse('2010-07-15'), date2010     
    ssb.july2=Job.number_jobs_schedule_ytd Date.parse('2010-07-16'), Date.parse('2010-07-31'), date2010 
    ssb.august=Job.number_jobs_schedule_ytd Date.parse('2010-08-01'), Date.parse('2010-08-31'), date2010     
    ssb.september=Job.number_jobs_schedule_ytd Date.parse('2010-09-01'), Date.parse('2010-09-30'), date2010 
    ssb.october=Job.number_jobs_schedule_ytd Date.parse('2010-10-01'), Date.parse('2010-10-31'), date2010 
    ssb.november=Job.number_jobs_schedule_ytd Date.parse('2010-11-01'), Date.parse('2010-11-30'), date2010
    @sched_stats_ytd<<ssb 
    
    ssb=ScheduleStatBundle.new 
    ssb.year='2009 YTD'
    ssb.may1=Job.number_jobs_schedule_ytd Date.parse('2009-05-01'), Date.parse('2009-05-15'), date2009     
    ssb.may2=Job.number_jobs_schedule_ytd Date.parse('2009-05-16'), Date.parse('2009-05-31'), date2009 
    ssb.june1=Job.number_jobs_schedule_ytd Date.parse('2009-06-01'), Date.parse('2009-06-15'), date2009     
    ssb.june2=Job.number_jobs_schedule_ytd Date.parse('2009-06-16'), Date.parse('2009-06-30'), date2009 
    ssb.july1=Job.number_jobs_schedule_ytd Date.parse('2009-07-01'), Date.parse('2009-07-15'), date2009     
    ssb.july2=Job.number_jobs_schedule_ytd Date.parse('2009-07-16'), Date.parse('2009-07-31'), date2009 
    ssb.august=Job.number_jobs_schedule_ytd Date.parse('2009-08-01'), Date.parse('2009-08-31'), date2009     
    ssb.september=Job.number_jobs_schedule_ytd Date.parse('2009-09-01'), Date.parse('2009-09-30'), date2009 
    ssb.october=Job.number_jobs_schedule_ytd Date.parse('2009-10-01'), Date.parse('2009-10-31'), date2009 
    ssb.november=Job.number_jobs_schedule_ytd Date.parse('2009-11-01'), Date.parse('2009-11-30'), date2009
    @sched_stats_ytd<<ssb 

    ssb=ScheduleStatBundle.new 
    ssb.year='2008 YTD'
    ssb.may1=Job.number_jobs_schedule_ytd Date.parse('2008-05-01'), Date.parse('2008-05-15'), date2008     
    ssb.may2=Job.number_jobs_schedule_ytd Date.parse('2008-05-16'), Date.parse('2008-05-31'), date2008 
    ssb.june1=Job.number_jobs_schedule_ytd Date.parse('2008-06-01'), Date.parse('2008-06-15'), date2008     
    ssb.june2=Job.number_jobs_schedule_ytd Date.parse('2008-06-16'), Date.parse('2008-06-30'), date2008 
    ssb.july1=Job.number_jobs_schedule_ytd Date.parse('2008-07-01'), Date.parse('2008-07-15'), date2008     
    ssb.july2=Job.number_jobs_schedule_ytd Date.parse('2008-07-16'), Date.parse('2008-07-31'), date2008 
    ssb.august=Job.number_jobs_schedule_ytd Date.parse('2008-08-01'), Date.parse('2008-08-31'), date2008     
    ssb.september=Job.number_jobs_schedule_ytd Date.parse('2008-09-01'), Date.parse('2008-09-30'), date2008 
    ssb.october=Job.number_jobs_schedule_ytd Date.parse('2008-10-01'), Date.parse('2008-10-31'), date2008 
    ssb.november=Job.number_jobs_schedule_ytd Date.parse('2008-11-01'), Date.parse('2008-11-30'), date2008
    @sched_stats_ytd<<ssb 

#_______________________________________________________________________________________________

    @sched_stats=[]
    ssb=ScheduleStatBundle.new 
    ssb.year='2013 Current'
    ssb.may1=Job.number_jobs_schedule_curr Date.parse('2013-05-01'), Date.parse('2013-05-15')     
    ssb.may2=Job.number_jobs_schedule_curr Date.parse('2013-05-16'), Date.parse('2013-05-31') 
    ssb.june1=Job.number_jobs_schedule_curr Date.parse('2013-06-01'), Date.parse('2013-06-15')     
    ssb.june2=Job.number_jobs_schedule_curr Date.parse('2013-06-16'), Date.parse('2013-06-30') 
    ssb.july1=Job.number_jobs_schedule_curr Date.parse('2013-07-01'), Date.parse('2013-07-15')     
    ssb.july2=Job.number_jobs_schedule_curr Date.parse('2013-07-16'), Date.parse('2013-07-31') 
    ssb.august=Job.number_jobs_schedule_curr Date.parse('2013-08-01'), Date.parse('2013-08-31')     
    ssb.september=Job.number_jobs_schedule_curr Date.parse('2013-09-01'), Date.parse('2013-09-30') 
    ssb.october=Job.number_jobs_schedule_curr Date.parse('2013-10-01'), Date.parse('2013-10-31') 
    ssb.november=Job.number_jobs_schedule_curr Date.parse('2013-11-01'), Date.parse('2013-11-30')
    @sched_stats<<ssb 

    ssb=ScheduleStatBundle.new 
    ssb.year='2013 Total'
    ssb.may1=Job.number_jobs_schedule Date.parse('2013-05-01'), Date.parse('2013-05-15')     
    ssb.may2=Job.number_jobs_schedule Date.parse('2013-05-16'), Date.parse('2013-05-31') 
    ssb.june1=Job.number_jobs_schedule Date.parse('2013-06-01'), Date.parse('2013-06-15')     
    ssb.june2=Job.number_jobs_schedule Date.parse('2013-06-16'), Date.parse('2013-06-30') 
    ssb.july1=Job.number_jobs_schedule Date.parse('2013-07-01'), Date.parse('2013-07-15')     
    ssb.july2=Job.number_jobs_schedule Date.parse('2013-07-16'), Date.parse('2013-07-31') 
    ssb.august=Job.number_jobs_schedule Date.parse('2013-08-01'), Date.parse('2013-08-31')     
    ssb.september=Job.number_jobs_schedule Date.parse('2013-09-01'), Date.parse('2013-09-30') 
    ssb.october=Job.number_jobs_schedule Date.parse('2013-10-01'), Date.parse('2013-10-31') 
    ssb.november=Job.number_jobs_schedule Date.parse('2013-11-01'), Date.parse('2013-11-30')
    @sched_stats<<ssb 

    ssb=ScheduleStatBundle.new 
    ssb.year='2012 Total'
    ssb.may1=Job.number_jobs_schedule Date.parse('2012-05-01'), Date.parse('2012-05-15')     
    ssb.may2=Job.number_jobs_schedule Date.parse('2012-05-16'), Date.parse('2012-05-31') 
    ssb.june1=Job.number_jobs_schedule Date.parse('2012-06-01'), Date.parse('2012-06-15')     
    ssb.june2=Job.number_jobs_schedule Date.parse('2012-06-16'), Date.parse('2012-06-30') 
    ssb.july1=Job.number_jobs_schedule Date.parse('2012-07-01'), Date.parse('2012-07-15')     
    ssb.july2=Job.number_jobs_schedule Date.parse('2012-07-16'), Date.parse('2012-07-31') 
    ssb.august=Job.number_jobs_schedule Date.parse('2012-08-01'), Date.parse('2012-08-31')     
    ssb.september=Job.number_jobs_schedule Date.parse('2012-09-01'), Date.parse('2012-09-30') 
    ssb.october=Job.number_jobs_schedule Date.parse('2012-10-01'), Date.parse('2012-10-31') 
    ssb.november=Job.number_jobs_schedule Date.parse('2012-11-01'), Date.parse('2012-11-30')
    @sched_stats<<ssb 

    ssb=ScheduleStatBundle.new 
    ssb.year='2011 Total'
    ssb.may1=Job.number_jobs_schedule Date.parse('2011-05-01'), Date.parse('2011-05-15')     
    ssb.may2=Job.number_jobs_schedule Date.parse('2011-05-16'), Date.parse('2011-05-31') 
    ssb.june1=Job.number_jobs_schedule Date.parse('2011-06-01'), Date.parse('2011-06-15')     
    ssb.june2=Job.number_jobs_schedule Date.parse('2011-06-16'), Date.parse('2011-06-30') 
    ssb.july1=Job.number_jobs_schedule Date.parse('2011-07-01'), Date.parse('2011-07-15')     
    ssb.july2=Job.number_jobs_schedule Date.parse('2011-07-16'), Date.parse('2011-07-31') 
    ssb.august=Job.number_jobs_schedule Date.parse('2011-08-01'), Date.parse('2011-08-31')     
    ssb.september=Job.number_jobs_schedule Date.parse('2011-09-01'), Date.parse('2011-09-30') 
    ssb.october=Job.number_jobs_schedule Date.parse('2011-10-01'), Date.parse('2011-10-31') 
    ssb.november=Job.number_jobs_schedule Date.parse('2011-11-01'), Date.parse('2011-11-30')
    @sched_stats<<ssb 
    
    ssb=ScheduleStatBundle.new 
    ssb.year='2010 Total'
    ssb.may1=Job.number_jobs_schedule Date.parse('2010-05-01'), Date.parse('2010-05-15')     
    ssb.may2=Job.number_jobs_schedule Date.parse('2010-05-16'), Date.parse('2010-05-31') 
    ssb.june1=Job.number_jobs_schedule Date.parse('2010-06-01'), Date.parse('2010-06-15')     
    ssb.june2=Job.number_jobs_schedule Date.parse('2010-06-16'), Date.parse('2010-06-30') 
    ssb.july1=Job.number_jobs_schedule Date.parse('2010-07-01'), Date.parse('2010-07-15')     
    ssb.july2=Job.number_jobs_schedule Date.parse('2010-07-16'), Date.parse('2010-07-31') 
    ssb.august=Job.number_jobs_schedule Date.parse('2010-08-01'), Date.parse('2010-08-31')     
    ssb.september=Job.number_jobs_schedule Date.parse('2010-09-01'), Date.parse('2010-09-30') 
    ssb.october=Job.number_jobs_schedule Date.parse('2010-10-01'), Date.parse('2010-10-31') 
    ssb.november=Job.number_jobs_schedule Date.parse('2010-11-01'), Date.parse('2010-11-30')
    @sched_stats<<ssb 
    
    ssb=ScheduleStatBundle.new 
    ssb.year='2009 Total'
    ssb.may1=Job.number_jobs_schedule Date.parse('2009-05-01'), Date.parse('2009-05-15')     
    ssb.may2=Job.number_jobs_schedule Date.parse('2009-05-16'), Date.parse('2009-05-31') 
    ssb.june1=Job.number_jobs_schedule Date.parse('2009-06-01'), Date.parse('2009-06-15')     
    ssb.june2=Job.number_jobs_schedule Date.parse('2009-06-16'), Date.parse('2009-06-30') 
    ssb.july1=Job.number_jobs_schedule Date.parse('2009-07-01'), Date.parse('2009-07-15')     
    ssb.july2=Job.number_jobs_schedule Date.parse('2009-07-16'), Date.parse('2009-07-31') 
    ssb.august=Job.number_jobs_schedule Date.parse('2009-08-01'), Date.parse('2009-08-31')     
    ssb.september=Job.number_jobs_schedule Date.parse('2009-09-01'), Date.parse('2009-09-30') 
    ssb.october=Job.number_jobs_schedule Date.parse('2009-10-01'), Date.parse('2009-10-31') 
    ssb.november=Job.number_jobs_schedule Date.parse('2009-11-01'), Date.parse('2009-11-30')
    @sched_stats<<ssb 

    ssb=ScheduleStatBundle.new 
    ssb.year='2008 Total'
    ssb.may1=Job.number_jobs_schedule Date.parse('2008-05-01'), Date.parse('2008-05-15')     
    ssb.may2=Job.number_jobs_schedule Date.parse('2008-05-16'), Date.parse('2008-05-31') 
    ssb.june1=Job.number_jobs_schedule Date.parse('2008-06-01'), Date.parse('2008-06-15')     
    ssb.june2=Job.number_jobs_schedule Date.parse('2008-06-16'), Date.parse('2008-06-30') 
    ssb.july1=Job.number_jobs_schedule Date.parse('2008-07-01'), Date.parse('2008-07-15')     
    ssb.july2=Job.number_jobs_schedule Date.parse('2008-07-16'), Date.parse('2008-07-31') 
    ssb.august=Job.number_jobs_schedule Date.parse('2008-08-01'), Date.parse('2008-08-31')     
    ssb.september=Job.number_jobs_schedule Date.parse('2008-09-01'), Date.parse('2008-09-30') 
    ssb.october=Job.number_jobs_schedule Date.parse('2008-10-01'), Date.parse('2008-10-31') 
    ssb.november=Job.number_jobs_schedule Date.parse('2008-11-01'), Date.parse('2008-11-30')
    @sched_stats<<ssb 
  end

  def stats_production
    @prod_stats=[]
    
    today=Date.today
    @date_2008=Date.parse('2008-01-01')
    @date_2009=@date_2008 >> 12
    @date_2010=@date_2009 >> 12
    @date_2011=@date_2010 >> 12
    @date_2012=@date_2011 >> 12
    @date_2013=@date_2012 >> 12
    


    @date_today_2013=today
    @date_last7_2013=HomeHelper.add_days_to_date @date_today_2013 , -8
    @date_yesterday_2013=HomeHelper.add_days_to_date @date_today_2013 , -1
    
    @date_today_2012=@date_today_2013 << 12
    @date_today_2012=HomeHelper.add_days_to_date @date_today_2012 , 1
    @date_last7_2012=HomeHelper.add_days_to_date @date_today_2012 , -8
    @date_next7_2012=HomeHelper.add_days_to_date @date_today_2012 , 8
    @date_yesterday_2012=HomeHelper.add_days_to_date @date_today_2012 , -1
    @date_tomorrow_2012=HomeHelper.add_days_to_date @date_today_2012 , 1
    @date_two_2012=HomeHelper.add_days_to_date @date_today_2012 , 2
    @date_three_2012=HomeHelper.add_days_to_date @date_today_2012 , 3
    @date_four_2012=HomeHelper.add_days_to_date @date_today_2012 , 4
    @date_five_2012=HomeHelper.add_days_to_date @date_today_2012 , 5
    
    @date_today_2011=@date_today_2012 << 12
    @date_today_2011=HomeHelper.add_days_to_date @date_today_2011 , 2
    @date_last7_2011=HomeHelper.add_days_to_date @date_today_2011 , -8
    @date_next7_2011=HomeHelper.add_days_to_date @date_today_2011 , 8
    @date_yesterday_2011=HomeHelper.add_days_to_date @date_today_2011 , -1
    @date_tomorrow_2011=HomeHelper.add_days_to_date @date_today_2011 , 1
    @date_two_2011=HomeHelper.add_days_to_date @date_today_2011 , 2
    @date_three_2011=HomeHelper.add_days_to_date @date_today_2011 , 3
    @date_four_2011=HomeHelper.add_days_to_date @date_today_2011 , 4
    @date_five_2011=HomeHelper.add_days_to_date @date_today_2011 , 5
    
    
    @date_today_2010=@date_today_2011 << 12
    @date_today_2010=HomeHelper.add_days_to_date @date_today_2010 , -6
    @date_last7_2010=HomeHelper.add_days_to_date @date_today_2010 , -8
    @date_next7_2010=HomeHelper.add_days_to_date @date_today_2010 , 8
    @date_yesterday_2010=HomeHelper.add_days_to_date @date_today_2010 , -1
    @date_tomorrow_2010=HomeHelper.add_days_to_date @date_today_2010 , 1
    @date_two_2010=HomeHelper.add_days_to_date @date_today_2010 , 2
    @date_three_2010=HomeHelper.add_days_to_date @date_today_2010 , 3
    @date_four_2010=HomeHelper.add_days_to_date @date_today_2010 , 4
    @date_five_2010=HomeHelper.add_days_to_date @date_today_2010 , 5
    
    @date_today_2009=@date_today_2010 << 12
    @date_today_2009=HomeHelper.add_days_to_date @date_today_2009 , 1
    @date_last7_2009=HomeHelper.add_days_to_date @date_today_2009 , -8
    @date_next7_2009=HomeHelper.add_days_to_date @date_today_2009 , 8
    @date_yesterday_2009=HomeHelper.add_days_to_date @date_today_2009 , -1
    @date_tomorrow_2009=HomeHelper.add_days_to_date @date_today_2009 , 1
    @date_two_2009=HomeHelper.add_days_to_date @date_today_2009 , 2
    @date_three_2009=HomeHelper.add_days_to_date @date_today_2009 , 3
    @date_four_2009=HomeHelper.add_days_to_date @date_today_2009 , 4
    @date_five_2009=HomeHelper.add_days_to_date @date_today_2009 , 5
    
    
    @date_today_2008=@date_today_2009 << 12
    @date_today_2008=HomeHelper.add_days_to_date @date_today_2008 , 1
    @date_last7_2008=HomeHelper.add_days_to_date @date_today_2008 , -8
    @date_next7_2008=HomeHelper.add_days_to_date @date_today_2008 , 8
    @date_yesterday_2008=HomeHelper.add_days_to_date @date_today_2008 , -1
    @date_tomorrow_2008=HomeHelper.add_days_to_date @date_today_2008 , 1
    @date_two_2008=HomeHelper.add_days_to_date @date_today_2008 , 2
    @date_three_2008=HomeHelper.add_days_to_date @date_today_2008 , 3
    @date_four_2008=HomeHelper.add_days_to_date @date_today_2008 , 4
    @date_five_2008=HomeHelper.add_days_to_date @date_today_2008 , 5
    





    
#      attr_accessor :curr, :ytd, :lastseven, :nextseven, :incomp30, :incomp30plus
#    @date_2013=@date_2012 >> 12
#    @date_today_2013=today
#    @date_last7_2013=HomeHelper.add_days_to_date @date_today_2013 , -8
#    @date_yesterday_2013=HomeHelper.add_days_to_date @date_today_2013 , -1

    
    ssb=ProductionStatBundle.new 
    ssb.year='2013'
    ssb.curr=Job.dollar_jobs_produced_curr @date_today_2013     
    ssb.ytd=Job.dollar_jobs_produced @date_2013, @date_today_2013
    ssb.lastseven=Job.dollar_jobs_produced @date_last7_2013, @date_today_2013
    ssb.nextseven='nil'
    ssb.incomp15=Job.number_jobs_incomplete @date_today_2013-15, @date_today_2013
    ssb.incomp16to30=Job.number_jobs_incomplete @date_today_2013-30, @date_today_2013-16
    ssb.incomp30plus=Job.number_jobs_incomplete @date_2013, @date_today_2013-31
    @prod_stats<<ssb 

    ssb=ProductionStatBundle.new 
    ssb.year='2012'
    ssb.curr=Job.dollar_jobs_produced_curr @date_today_2012     
    ssb.ytd=Job.dollar_jobs_produced @date_2012, @date_today_2012
    ssb.lastseven=Job.dollar_jobs_produced @date_last7_2012, @date_today_2012
    ssb.nextseven=Job.dollar_jobs_produced @date_today_2012, @date_next7_2012
    ssb.incomp15='nil'
    ssb.incomp16to30='nil'
    ssb.incomp30plus='nil'
    @prod_stats<<ssb 

    ssb=ProductionStatBundle.new 
    ssb.year='2011'
    ssb.curr=Job.dollar_jobs_produced_curr @date_today_2011     
    ssb.ytd=Job.dollar_jobs_produced @date_2011, @date_today_2011
    ssb.lastseven=Job.dollar_jobs_produced @date_last7_2011, @date_today_2011
    ssb.nextseven=Job.dollar_jobs_produced @date_today_2011, @date_next7_2011
    ssb.incomp15='nil'
    ssb.incomp16to30='nil'
    ssb.incomp30plus='nil'
    @prod_stats<<ssb 

    ssb=ProductionStatBundle.new 
    ssb.year='2010'
    ssb.curr=Job.dollar_jobs_produced_curr @date_today_2010     
    ssb.ytd=Job.dollar_jobs_produced @date_2010, @date_today_2010
    ssb.lastseven=Job.dollar_jobs_produced @date_last7_2010, @date_today_2010
    ssb.nextseven=Job.dollar_jobs_produced @date_today_2010, @date_next7_2010
    ssb.incomp15='nil'
    ssb.incomp16to30='nil'
    ssb.incomp30plus='nil'
    @prod_stats<<ssb 

    ssb=ProductionStatBundle.new 
    ssb.year='2009'
    ssb.curr=Job.dollar_jobs_produced_curr @date_today_2009     
    ssb.ytd=Job.dollar_jobs_produced @date_2009, @date_today_2009
    ssb.lastseven=Job.dollar_jobs_produced @date_last7_2009, @date_today_2009
    ssb.nextseven=Job.dollar_jobs_produced @date_today_2009, @date_next7_2009
    ssb.incomp15='nil'
    ssb.incomp16to30='nil'
    ssb.incomp30plus='nil'
    @prod_stats<<ssb 

    ssb=ProductionStatBundle.new 
    ssb.year='2008'
    ssb.curr=Job.dollar_jobs_produced_curr @date_today_2008     
    ssb.ytd=Job.dollar_jobs_produced @date_2008, @date_today_2008
    ssb.lastseven=Job.dollar_jobs_produced @date_last7_2008, @date_today_2008
    ssb.nextseven=Job.dollar_jobs_produced @date_today_2008, @date_next7_2008
    ssb.incomp15='nil'
    ssb.incomp16to30='nil'
    ssb.incomp30plus='nil'
    @prod_stats<<ssb 

  end

  
end