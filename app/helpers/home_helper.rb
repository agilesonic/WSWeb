module HomeHelper
    MONTHS=['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    YEARS=['2013', '2014','2015']
    DAYS=['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20',
         '21','22','23','24','25','26','27','28','29','30','31']
    STIME=['8:00 AM','Critical 8:00 AM','10:00 AM','Critical 10:00 AM','12:00 PM','Critical 12:00 PM','Anytime','Critical Anytime']
    CAGES=['1','2','3','4','5','As Reqd']
    SAT_TYPES=['Spoke to Client','Client Called Us','Left Message Machine','Left Message Person','No Contact']
    MESS_TYPES=['WS Phoned','Client Phoned','WS LMM','Client LMM','Crew Estimate']
    MESS_HEADERS=['Book Win/Eaves', 'Book Paint', 'Written Win/Eaves Est', 'Paint Est', 'Book DNF', 'Pick Up Sign',
          'Pick Up Debris', 'Pick Up Equipment', 'Pay by Visa', 'Invoice Dispute', 'Mail Invoice', 'Email Invoice',
          'Call Back', 'Custom']
    YESNO=['Yes', 'No']
    CONNECTION_OPTIONS=['No Calls', '4.1+ clients', 'Windows Last Spring', 'EH Last Spring', 'Used Us Last Year']
    CALL_OPTIONS=['LMM', 'LMP', 'Pending Summer 2014', 'Pending Fall 2013', 'NC', 'Moved', 'Phone Out Of Service'] 

    
    def self.add_days_to_current_date(days)
        date=Date.today+days
    end
    
    def self.make_price_zero(price5)
        if price5==''
          price='0.00'
        else
          price=price5  
        end
        return price;
    end
    
    def self.add_days_to_date(date, days)
        date=date+days
    end
    

    def self.pad_id_num(type,num)
      num=num.to_s
      a=num.length
      b=8-a.to_i
      zero="0"*b
      a=zero + num
      ans=type+a
    end
    
    

    def self.get_num_from_month(month)
      ans=''   
      if month.eql? 'Jan'
        ans='01'
      elsif month.eql? 'Feb'
        ans='02'
      elsif month.eql? 'Mar'
        ans='03'
      elsif month.eql? 'Apr'
        ans='04'
      elsif month.eql? 'May'
        ans='05'
      elsif month.eql? 'Jun'
        ans='06'
      elsif month.eql? 'Jul'
        ans='07'
      elsif month.eql? 'Aug'
        ans='08'
      elsif month.eql? 'Sep'
        ans='09'
      elsif month.eql? 'Oct'
        ans='10'
      elsif month.eql? 'Nov'
        ans='11'
      elsif month.eql? 'Dec'
        ans='12'
      end
    end

    def self.get_month_from_num(num)
      ans=''   
      if num.eql? '01'
        ans='Jan'
      elsif num.eql? '02'
        ans='Feb'
      elsif num.eql? '03'
        ans='Mar'
      elsif num.eql? '04'
        ans='Apr'
      elsif num.eql? '05'
        ans='May'
      elsif num.eql? '06'
        ans='Jun'
      elsif num.eql? '07'
        ans='Jul'
      elsif num.eql? '08'
        ans='Aug'
      elsif num.eql? '09'
        ans='Sep'
      elsif num.eql? '10'
        ans='Oct'
      elsif num.eql? '11'
        ans='Nov'
      elsif num.eql? '12'
        ans='Dec'
      end
    end
    
    def self.get_nice_date(sqldate)
      sqldate=sqldate.to_s
      year=sqldate[0,4]
      month=sqldate[5,2]
      month=get_month_from_num(month)
      day=sqldate[8,2]
      date=month.to_s+' '+ day.to_s+', '+year.to_s
    end
    

    def self.get_props_addresses(client)
      @props=client.valid_properties
      @props_options=[]
      if !@props.nil?
        @props.each do |p|
          @props_options<p.address
        end
      end
    end

    
    
    def self.get_props_and_prices(client)
      @props=client.valid_properties
      @prices_all=[]
      i=1
      if !@props.nil?
        @props.each do |p|
          puts 'PROPERTY',p.address
          c=Client.find p.CFID
          ppr=PropPrices.new
          ppr.client= c.honorific+' '+c.firstname+' '+c.lastname
          ppr.id=p.id
          ppr.address=p.address
          ppr.perly=p.perly
          ppr.post_code=p.postcode
          @prices=p.prices
          if !@prices.nil?
            @prices.each do |price5|
              if price5.JobType.eql? 'W1' then
                ppr.w1= price5.price
              elsif price5.JobType.eql? 'EH' then
                ppr.eh= price5.price 
              elsif price5.JobType.eql? 'EG' then
                ppr.eg= price5.price 
              end
              puts price5.JobType, price5.price
            end
          end
              @prices_all << ppr
        end
        return @prices_all
      end
    end

    def self.schedule_bean(d1)    
      eights=Job.search_schedule_times(d1,'8:00 AM')
      lim8=Apptsched.search_limits d1, '8:00 AM'
      tens=Job.search_schedule_times(d1,'10:00 AM')
      lim10=Apptsched.search_limits d1, '10:00 AM'
      twelves=Job.search_schedule_times(d1,'12:00 PM')
      lim12=Apptsched.search_limits d1, '12:00 PM'
      anys=Job.search_schedule_times(d1,'Anytime')
      limany=Apptsched.search_limits d1, 'Anytime'
      sb=ScheduleBundle.new
      sb.date=d1
      sb.eights=eights
      sb.lim8=lim8
      sb.tens=tens
      sb.lim10=lim10
      sb.twelves=twelves
      sb.lim12=lim12
      sb.anytimes=anys
      sb.limany=limany
      if sb.eights.to_i<=lim8.to_i
        sb.lim8='blue'
      else  
        sb.lim8='red'
      end
      if sb.tens.to_i<=lim10.to_i
        sb.lim10='blue'
      else
        sb.lim10='red'
      end
      if sb.twelves.to_i<=lim12.to_i
        sb.lim12='blue'
      else
        sb.lim12='red'
      end
      if sb.anytimes.to_i<=limany.to_i
        sb.limany='blue'
      else
        sb.limany='red'
      end
      return sb
    end

    def self.check_schedule(date,stime)
      if stime.nil?
        stime='eh eh'
      end
     # if stime.index('8:00 AM')>-1
     #   stime='8:00 AM'
     # elsif stime.index('10:00 AM')>-1
     #   stime='10:00 AM'
     # elsif stime.index('12:00 PM')>-1
     #   stime='12:00 PM'
     # elsif stime.index('Anytime')>-1
     #   stime='Anytime'
     # end
      booked=Job.search_schedule_times(date,stime)
      lim=Apptsched.search_limits(date, stime)
      if booked.to_i<=lim.to_i
        return true
      else  
        return false
      end
    end
    
end
