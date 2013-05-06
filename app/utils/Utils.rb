class Utils
  @@stats=[]
  @@indstats=[]
  @@stat_time
  
  def self.log(message)
    puts Date.new.to_s + " " + message
  end
  
  def self.record_stat_time(ts)
    @@stat_time=ts
  end 
  
  def self.get_stat_time
    @@stat_time
  end 
  
  def self.deposit_stats(stats1)  
    @@stats=stats1
  end

  def self.withdraw_stats  
    @@stats
  end

  def self.deposit_indstats(stats1)  
    @@indstats=stats1
  end

  def self.withdraw_indstats  
    @@indstats
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