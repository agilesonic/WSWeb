class CrewsController <  ApplicationController
  layout "application1"
  
  
  def tracker
    date=Date.today-2
    @test='trackerses'
    @crew_bundles={}
    crews=OC.find_crews date     
    #  attr_accessor :part1, :part2, :phone, :status, :prod, :estprod, :target
    crews.each do |crew|
      ctb=CrewTrackerBundle.new
      driver=Employee.just_name_from_id crew.driver
      partner=Employee.just_name_from_id crew.partner
      ctb.driver=driver[0]
      ctb.partner=partner[0]
      ctb.phone=crew.phone
      jobs=Job.jobs_crew driver[0], date
      jobs5={}
      jobs.each do |j|
        if j.reportstime.nil?
          j.reportstime='99:99:99'
        end
        if j.reportftime.nil?
          j.reportftime='99:99:99'
        end
        if j.nextdestination.nil?
          j.nextdestination='unknown'
        end
        jobs5[j.reportstime+j.num.to_s+j.JobID]=j
      end
      jobs5=jobs5.sort_by{|k, v| k}
      jobs55=[]
      jobs5.each do |k,j|
        jobs55<<j
      end
      
      fj=jobs55.first
      lj=jobs55.last
      if fj.nil?
        ctb.status='No Jobs'
      elsif fj.reportstime=='99:99:99'
        ctb.status='Not Started'
      elsif lj.reportftime!='99:99:99'
        ctb.status='Day Finished'
      else  
        status='AWOL'
        jobs5.each do |k,j|
          if j.reportstime!='99:99:99' && j.reportftime!='99:99:99'
            status='Travelling'
          end
          if j.reportstime!='99:99:99' && j.reportftime=='99:99:99'
            status='OnSite'
          end
        end
        ctb.status=status
      end
      ctb.prod=Job.dollar_jobs_produced_curr_crew(date, ctb.driver)
      @crew_bundles[ctb.prod]=ctb
    end
    #@stats['-1'.to_s]=sbtot
    @crew_bundles=@crew_bundles.sort_by{|k, v| k.to_f}
    @crew_bundles=@crew_bundles.reverse!
    
  end
  
  def activity
    name=params[:id]
    jobs5={}
    jobs=Job.jobs_crew name, Date.today-2
    jobs.each do |j|
        if j.reportstime.nil?
          j.reportstime='99:99:99'
        end
        if j.reportftime.nil?
          j.reportftime='99:99:99'
        end
        if j.nextdestination.nil?
          j.nextdestination='unknown'
        end
        jobs5[j.reportstime+j.num.to_s+j.JobID]=j
      end
      jobs5=jobs5.sort_by{|k, v| k}
      @jobs55=[]
      @lastjob=nil
      @started='false'
      jobs5.each do |k,j|
        j.Actiontake=j.property.address
        if j.reportftime!='99:99:99'
          @lastjob=j.JobID
        end 
        if j.reportstime!='99:99:99' && j.reportftime=='99:99:99'
          @started='true'
        end 
        @jobs55<<j
      end
    end
    
    def job_details
        @jobid=params[:id]
       
        @job=Job.find @jobid
        props=Property.get_property_from_jobinfoid @job.JobInfoID
        prop=props[0]
        @cfid=prop.CFID
        @esf_form=CreateSaleForm.new
        @ppr=PropPrices.new
        @ppr.id=prop.id
        @ppr.address=prop.address
        @ppr.city=HomeHelper::codeToCity(prop.postcode)
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
        
        @hour_options=HomeHelper::HOURS
        @min_options=HomeHelper::MIN
        
        @selected_reportstime=@job.reportstime
        @selected_reportftime=@job.reportftime
        if @selected_reportstime.nil?
          @selected_reportshour='00'
          @selected_reportsmin='00'
        else  
          @selected_reportshour=@selected_reportstime[0..1]
          @selected_reportsmin=@selected_reportstime[3..4]
        end
        if @selected_reportftime.nil?
          @selected_reportfhour='00'
          @selected_reportfmin='00'
        else  
          @selected_reportfhour=@selected_reportftime[0..1]
          @selected_reportfmin=@selected_reportftime[3..4]
          total_smins=@selected_reportshour.to_i*60 + @selected_reportsmin.to_i 
          total_fmins=@selected_reportfhour.to_i*60 + @selected_reportfmin.to_i 
          @actmin_value=total_fmins-total_smins
          
        end
        
        jri=Jobrelatedinfo.find @jobid
        @estmin_value=jri.EstiJobMinutes
        @pyear_options=HomeHelper::PROD_YEARS
        @pmonth_options=HomeHelper::PROD_MONTHS
        @pday_options=HomeHelper::PROD_DAYS

        datebi=@job.Datebi
        datebi=datebi.to_s        
        @selected_pyear=datebi[0..3]
        @selected_pmonth=HomeHelper.get_month_from_num datebi[5..6]
        @selected_pday=datebi[8..9]
        
        @origrecstatus=@job.Recstatus
        if @jobrecstatus.nil?
           @job.Recstatus='Nil'
        end 
        @rec_options=HomeHelper::REC_OPTIONS
        
        @clienthm_options=HomeHelper::CLIENTHM_OPTIONS
        @selected_clienthm=@job.Clienthm
        @lawnsign_options=HomeHelper::LAWNSIGN_OPTIONS
        @selected_lawnsign=@job.LawnSign

        @notes=Notes.get_job_notes @jobid
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
    end

end