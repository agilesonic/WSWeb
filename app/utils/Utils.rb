class Utils
  @user5=nil
  @@jobid=nil
  @@stats=[]
  @@stats_septoct=[]
  @@stats_novdec=[]
  @@indstats=[]
  @@indstats7=[]
  @@stat_co_time=nil
  @@stat_co_septoct_time=nil
  @@stat_co_novdec_time=nil
  @@stat_ind_time=nil
  @@stat_ind_time7=nil
  
  
  @done_jobs=[]
  
  def self.pad_time(number)
    if number.to_s.length==1
      number.to_s='0'+number.to_s
    end
  end
  
  def self.set_user(user)
    @user5=user
  end 
  
  def self.get_user()
    @user5
  end 




  def self.fill_sat_jobs(sats)
    @done_jobs=sats
  end 
  
  def self.get_sat_jobs()
    @done_jobs
  end 
  
  def self.log(message)
    puts Date.new.to_s + " " + message
  end
  

  def self.record_stat_co_time(ts)
    @@stat_co_time=ts
  end 
  
  def self.get_stat_co_time
    @@stat_co_time
  end 




  def self.record_stat_co_septoct_time(ts)
    @@stat_co_septoct_time=ts
  end 
  
  def self.get_stat_co_septoct_time
    @@stat_co_septoct_time
  end 

  def self.record_stat_co_novdec_time(ts)
    @@stat_co_septoct_time=ts
  end 
  
  def self.get_stat_co_novdec_time
    @@stat_co_septoct_time
  end 

  def self.record_stat_ind_time(ts)
    @@stat_ind_time=ts
  end 
  
  def self.get_stat_ind_time
    @@stat_ind_time
  end 

  def self.record_stat_ind_time7(ts)
    @@stat_ind_time7=ts
  end 
  
  def self.get_stat_ind_time7
    @@stat_ind_time7
  end 




  def self.get_jobid
    @@jobid
  end 
  
  def self.set_jobid jobid5
    @@jobid=jobid5
  end 
  
  def self.deposit_stats(stats1)  
    @@stats=stats1
  end

  def self.withdraw_stats  
    @@stats
  end

  def self.deposit_stats_septoct(stats1)  
    @@stats_septoct=stats1
  end

  def self.withdraw_stats_septoct  
    @@stats_septoct
  end

  def self.deposit_stats_novdec(stats1)  
    @@stats_novdec=stats1
  end

  def self.withdraw_stats_novdec  
    @@stats_novdec
  end


  def self.deposit_indstats(stats1)  
    @@indstats=stats1
  end

  def self.withdraw_indstats  
    @@indstats
  end
    
  def self.deposit_indstats7(stats1)  
    @@indstats7=stats1
  end

  def self.withdraw_indstats7  
    @@indstats7
  end


  def self.format_postal_code(s)
    postal_code = ''
    if !s.nil?
      s.each_char do |c|
       case postal_code.size
          when 0, 5
            postal_code << c.upcase if letter?(c)
          when 2
            postal_code << (c.upcase + ' ') if letter?(c)
          when 1, 4, 6
            postal_code << c if digit?(c)
        end
      end
    end
    return postal_code
  end
  
  def self.letter?(c)
    !c.nil? && c.size == 1 && c.upcase >= 'A' && c.upcase <= 'Z'
  end
    
  def self.digit?(c)
    !c.nil? && c.size == 1 && c >= '0' && c <= '9'
  end
  
  def self.id_to_number(id)
    id.slice(2, id.size).to_i
  end
  
  def self.id_prefix(id)
    id[0, 2]
  end
  
  def self.number_to_id(prefix, number)
    s = number.to_s
    while s.size < 8
      s = '0' + s
    end
    s = prefix + s
  end
  
  def self.next_id(id)
    number_to_id(id_prefix(id), id_to_number(id) + 1)
  end
end