class CrewsController <  ApplicationController
  layout "application1"
  
  
  def tracker
    @test='trackerses'
    @crew_bundles=[]
    crews=OC.find_crews Date.today     
    #  attr_accessor :part1, :part2, :phone, :status, :prod, :estprod, :target
    crews.each do |crew|
      ctb=CrewTrackerBundle.new
      driver=Employee.just_name_from_id crew.driver
      partner=Employee.just_name_from_id crew.partner
      ctb.driver=driver[0]
      ctb.partner=partner[0]
      ctb.prod=Job.dollar_jobs_produced_curr_crew(Date.today, ctb.driver)
      @crew_bundles<<ctb
    end
    
  end
  
  def activity
    @test='nuts'
  end

end