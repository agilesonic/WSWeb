class CrewsController <  ApplicationController
  layout "application1"
  
  
  def tracker
    @test='trackerses'
    @crew_bundles={}
    crews=OC.find_crews Date.today     
    #  attr_accessor :part1, :part2, :phone, :status, :prod, :estprod, :target
    crews.each do |crew|
      ctb=CrewTrackerBundle.new
      driver=Employee.just_name_from_id crew.driver
      partner=Employee.just_name_from_id crew.partner
      ctb.driver=driver[0]
      ctb.partner=partner[0]
      ctb.phone=crew.phone
      jobs=Job.jobs_crew driver[0], Date.today
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
        jobs5[j.reportstime]=j
      end
      jobs5=jobs5.sort_by{|k, v| k}
      jobs55=[]
      jobs5.each do |k,j|
        jobs55<<j
      end
      
      fj=jobs55.first
      lj=jobs55.last
      if fj.reportstime=='99:99:99'
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
      ctb.prod=Job.dollar_jobs_produced_curr_crew(Date.today, ctb.driver)
      @crew_bundles[ctb.prod]=ctb
    end
    #@stats['-1'.to_s]=sbtot
    @crew_bundles=@crew_bundles.sort_by{|k, v| k}
    @crew_bundles=@crew_bundles.reverse!
    
  end
  
  def activity
    @test='nuts'
  end

end