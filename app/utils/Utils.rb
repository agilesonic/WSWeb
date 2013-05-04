class Utils
  @@stats={}
  
  def self.log(message)
    puts Date.new.to_s + " " + message
  end
  
  def self.log1(stats1)  
    @@stats=stats1
    puts Date.new.to_s + " " + message
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