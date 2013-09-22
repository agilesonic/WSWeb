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
    ASS_OPTIONS=['unassign', 'transfer']
    CONNECTION_OPTIONS=['New Estimates','3.3=>3.6 clients','3.7=>3.9 clients','4.0=>4.1 clients',
       '4.2=>4.3 clients', '4.4=>4.5 clients', '4.6=>4.7 clients', 'Used Us Last Sept/Oct','Used Us Last Nov/Dec']
    NUM_CALLS_OPTIONS=['0','1','2']
    CALL_OPTIONS=['LMM', 'LMP', 'Pending', 'Pending Summer 2014', 'Pending Fall 2014', 'NC', 'Moved', 'Phone Out Of Service'] 
    PROFILE_OPTIONS=['New Estimates','3.3=>3.6 clients','3.7=>3.9 clients','4.0=>4.1 clients','4.2=>4.3 clients',
      '4.4=>4.5 clients', '4.6=>4.7 clients']
    CLIENT_CONTACT_STATUS=['Normal Client', 'No Phone Call', 'No Mail', 'No Phone Call and No Mail', 'Ask Client To Pay Promptly',
                           "Client doesn't want us", "We don't want the client"]
    
    SCHEDULING_NOTES=['MON => Markham, Thornhill, Richmond Hill','TUES => Scarborough','WED => Woodbridge, Vaughan',
      'THURS => Mississauga, Oakville, Brampton','FRI => Keep light for Rain Days','SAT => 1/2 Crews working and 50% more labor cost']
    HOURS=['07','08','09','10','11','12','13','14','15','16','17','18','19','20']
    MIN=['00','05','10','15','20','25','30','35','40','45','50','55']
    SOURCE=['TORONTO SUN', 'METRO']
    SHOP=['East(Carlaw Ave/Lakeshore Blvd)', 'West(Dundas St West/Bloor St West)']
    DRIVE=['No License','Valid G License', 'Valid G2 License']
    LADDER=['No Experience', 'Some Experience', 'Very Experienced']
    
    def self.generate_calllog hrid, date
      call_log={}
      cc=Clientcontact.calllog hrid, date
      if(!cc.nil?&& !cc.empty?)
        cc.each do |c|
          cbl=CallLogBundle.new
          client=Client.find c.CFID
          cbl.ts=c.callmade
          cbl.type='Conn Call'
          cbl.object=c.CFID+' '+client.full_name
          cbl.notes=client.full_name.concat(".....").concat(c.tstatus).concat(".....").concat(c.followup.to_s)
          call_log[c.callmade]=cbl
        end
      end
      notes=Notes.calllog hrid, date
      if !notes.nil?
        notes.each do |n|
          cbl=CallLogBundle.new
          cbl.ts=n.ts
          puts n.id.to_s.concat('  ').concat(n.ts.to_s).concat(n.notes)
          if !n.nil? && !n.notes.nil? && !n.notes.index('Recble').nil?
            cbl.type='Recble'
          else  
            cbl.type='Notes'
          end
          cbl.object=n.objectid

          if !n.objectid.nil?
            if !n.notes.index('Went To House').nil?
              if n.objectid.index('JB')==0
                j=Job.find n.objectid
                cbl.notes=n.notes.concat('[').concat(n.objectid).concat(' - ').concat(j.property.address).concat('//').concat(j.property.perly).concat(']')
              else  
                cbl.notes=n.notes.concat('[').concat(n.objectid).concat(']')
              end
            else
              cbl.notes=n.notes.concat('[').concat(n.objectid).concat(']')
            end
          else
            cbl.notes=n.notes
          end  
          call_log[n.ts]=cbl
        end
      end
      
      sats=Satisfaction.calllog hrid, date
      sats.each do |s|
        cbl=CallLogBundle.new
        cbl.ts=s.callmade
        cbl.type='Satis'
        cbl.object=s.JobID
        cbl.notes=s.Type.concat(' ').concat(s.Comments)
        call_log[s.callmade]=cbl
      end
      
      mess=Messages.calllog_resolved_message hrid, date
      mess.each do |m|
        cbl=CallLogBundle.new
        puts 'IN RESOLVED'.concat(m.ts.to_s)
        cbl.ts=m.ts
        cbl.type='Resolved Message'
        cbl.object=''
        if !m.message.index('Pick Up Sign').nil?
          cbl.notes='[Pick Up Sign'
          if !m.jobid.nil? && m.jobid!=''
            j=Job.find m.jobid
            cbl.notes=cbl.notes.concat('-').concat(j.property.address).concat('//').concat(j.property.perly)
          end
          cbl.notes=cbl.notes.concat(']')
        elsif !m.message.index('Written Win/Eaves').nil?
          cbl.notes='[Window Estimate'
          if !m.cfid.nil? && m.cfid!=''
            c=Client.find m.cfid
            cbl.notes=cbl.notes.concat('-').concat(c.address).concat('//').concat(c.perly)
          end
          cbl.notes=cbl.notes.concat(']')
        else    
          if !m.cfid.nil?
            cbl.notes='['.concat(m.cfid).concat(']').concat(m.message)
          else
            cbl.notes=m.message
          end  
        end
        call_log[m.ts]=cbl
      end
      
      mess=Messages.calllog_took_message hrid, date
      mess.each do |m|
        cbl=CallLogBundle.new
        cbl.ts=m.ts
        cbl.type='Took Message'
        cbl.object=''
        if !m.cfid.nil?
          cbl.notes='['.concat(m.cfid).concat(']').concat(m.message)
        else
          cbl.notes=m.message
        end  
        call_log[m.ts]=cbl
      end
      
      jobs=Job.calllog hrid, date
      jobs.each do |j|
        cbl=CallLogBundle.new
        cbl.ts=j.timeSold
        cbl.type='SALE'
        cbl.object=''
        type='Fltr'
        if j.Sdate==j.Fdate
          type='Appt'
        end
        cbl.notes=j.JobID.concat('//').concat(j.property.address).concat('[').concat(type).concat(']').concat(j.JobDesc).concat('   ').concat(j.Sdate.to_s)
        call_log[j.timeSold]=cbl
      end
      
      trans=Transactions.calllog hrid, date
      trans.each do |t|
        cbl=CallLogBundle.new
        cbl.ts=t.updatets
        cbl.type='Transaction'
        cbl.object=''
        cbl.notes=('[').concat(t.JobID).concat(']').concat(t.TranType).concat(' // ').concat(t.TranDesc)
        call_log[t.updatets]=cbl
      end
      
      
      call_log=call_log.sort_by {|ts, cbl| ts.to_s}
      
      tss=[]
      lastts=nil
      newts=nil
      newcl=nil
      lastcl=nil
      i=0
      call_log.each do |k,cl|
        puts k
        cl.class5='ok'
        if i==0
          lastcl=cl
          newcl=cl
        end
        if i!=0
          lastcl=newcl
          newcl=cl
          if((newcl.ts-lastcl.ts)/60>10)
            lastcl.class5='over'
            newcl.class5='over'
          end
        end
        i+=1
      end
      call_log
    end
    
    
    
    
    
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
      if(a==10)
        return num
      end
      b=8-a.to_i
      zero="0"*b
      a=zero + num
      ans=type+a
    end
    
    def self.pad_num2(num)
      num=num.to_s
      a=num.length
      if(a==2)
        return num
      end
      b=2-a.to_i
      zero="0"*b
      a=zero + num
    end

    def self.pad_num3(num)
      num=num.to_s
      a=num.length
      if(a==3)
        return num
      end
      b=3-a.to_i
      zero="0"*b
      a=zero + num
    end

    def self.pad_num5(num)
      num=num.to_s
      a=num.length
      if(a==5)
        return num
      end
      b=5-a.to_i
      zero="0"*b
      a=zero + num
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
          ppr.city=codeToCity(p.postcode)
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

    def self.day_of_week i
      if i==0
        return 'Sun'
      elsif i==1
        return 'Mon'
      elsif i==2
        return 'Tue'
      elsif i==3
        return 'Wed'
      elsif i==4
        return 'Thu'
      elsif i==5
        return 'Fri'
      elsif i==6
        return 'Sat'
      else
        return 'unknown'  
      end
    end

    def self.schedule_bean(d1)    
      eights=Job.search_schedule_times(d1,'8:00 AM')
      as=Apptsched.search_limits d1, '8:00 AM'
      if as.nil?||as.empty?
        lim8='0'
      else
        lim8=as.first.lim
      end
      tens=Job.search_schedule_times(d1,'10:00 AM')
      as=Apptsched.search_limits d1, '10:00 AM'
      if as.nil?||as.empty?
        lim10='0'
      else
        lim10=as.first.lim
      end
      twelves=Job.search_schedule_times(d1,'12:00 PM')
      as=Apptsched.search_limits d1, '12:00 PM'
      if as.nil?||as.empty?
        lim12='0'
      else
        lim12=as.first.lim
      end
      anys=Job.search_schedule_times(d1,'Anytime')
      as=Apptsched.search_limits d1, 'Anytime'
      if as.nil?||as.empty?
        limany='0'
      else
        limany=as.first.lim
      end
       puts d1.to_s,lim12,twelves
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
      if sb.eights.to_i<lim8.to_i
        sb.lim8='blue'
        sb.eights=lim8.to_i-sb.eights.to_i
        sb.eights.to_s
      else  
        sb.lim8='red'
        sb.eights=lim8.to_i-sb.eights.to_i
        sb.eights.to_s
      end
      if sb.tens.to_i<lim10.to_i
        sb.lim10='blue'
        sb.tens=lim10.to_i-sb.tens.to_i
        sb.tens.to_s
      else
        sb.lim10='red'
        sb.tens=lim10.to_i-sb.tens.to_i
        sb.tens.to_s
      end
      if sb.twelves.to_i<lim12.to_i
        sb.lim12='blue'
        sb.twelves=lim12.to_i-sb.twelves.to_i
        sb.twelves.to_s
      else
        sb.lim12='red'
        sb.twelves=lim12.to_i-sb.twelves.to_i
        sb.twelves.to_s
      end
      if sb.anytimes.to_i<limany.to_i
        sb.limany='blue'
        sb.anytimes=limany.to_i-sb.anytimes.to_i
        sb.anytimes.to_s
      else
        sb.limany='red'
        sb.anytimes=limany.to_i-sb.anytimes.to_i
        sb.anytimes.to_s
      end
      return sb
    end

    def self.check_schedule(date,stime)
      if stime.nil?
        stime='eh eh'
      end
      booked=Job.search_schedule_times(date,stime)
      as=Apptsched.search_limits(date, stime)
      if as.nil? || as.empty?
        return true
      end
      if booked.to_i<as.first.lim.to_i
        return true
      else  
        return false
      end
    end
    
    def self.codeToCity(postcode)
      if(postcode.nil?)
        return ""
      end  
      ans=""

    if(postcode.length>=3)
      pc = postcode[0, 3]
      if(pc==("M1B")||pc=="M1X"||pc=="M1C"||pc=="M1E"||pc=="M1G"||pc=="M1H"||pc=="M1J"||pc=="M1K"||pc=="M1L"||pc=="M1M"||pc=="M1N"||pc=="M1P"||pc=="M1R"||pc=="M1S"||pc=="M1T"||pc=="M1W"||pc=="M1V")
        ans="Scarborough[Tuesday]"
      elsif(pc=="L3P"||pc=="L3S"||pc=="L6B"||pc=="L6E")
        ans="Markham[Monday]"
      elsif(pc=="L3R"||pc=="L6C"||pc=="L6G")
        ans="Unionville[Thursday]"
      elsif(pc=="L3T"||pc=="L4J")
        ans="Thornhill[Monday]"
      elsif(pc=="L3X"||pc=="L3Y")
        ans="Newmarket[Monday]"
      elsif(pc=="L4A")
        ans="Stouffville[Monday]"
      elsif(pc=="L4B"||pc=="L4C"||pc=="L4S")
        ans="Richmond Hill[Monday]"
      elsif(pc=="L4E")
        ans="Oak Ridges[Monday}"
      elsif(pc=="L4G")
        ans="Aurora[Tuesday]"
      elsif(pc=="L4H"||pc=="L4L")
        ans="Woodbridge[Monday]"
      elsif(pc=="L4K")
        ans="Concord[Thursday]"
      elsif(pc=="L6A")
        ans="Maple[Thursday]"
      elsif(pc=="L1G"||pc=="L1K"||pc=="L1L"||pc=="L1H"||pc=="L1J")
        ans="Oshawa[Tuesday]"
      elsif(pc=="L1M")
        ans="Brooklin[Monday]"
      elsif(pc=="L1N"||pc=="L1P"||pc=="L1R")
        ans="Whitby[Tuesday]"
      elsif(pc=="L1S"||pc=="L1T"||pc=="L1Z")
        ans="Ajax[Tuesday]"
      elsif(pc=="L1V"||pc=="L1W"||pc=="L1X"||pc=="L1Y")
        ans="Pickering[Tuesday]"
      elsif(pc=="M6S"||pc=="M8V"||pc=="M8W"||pc=="M8Y"||pc=="M8Z"||pc=="M8X"||pc=="M9A"||pc=="M9B"||pc=="M9C"||pc=="M9L"||pc=="M9M"||pc=="M9N"||pc=="M9P"||pc=="M9R"||pc=="M9V"||pc=="M9W")
        ans="Etobicoke"
      elsif(pc=="L4T"||pc=="L4V"||pc=="L5S"||pc=="L5T"||pc=="L4W"||pc=="L4X"||pc=="L4Y"||pc=="L4Z"||pc=="L5R"||pc=="L5A"||pc=="L5B"||pc=="L5C"||pc=="L5E"||pc=="L5G"||pc=="L5H"||pc=="L5J"||pc=="L5K"||pc=="L5L"||pc=="L5M"||pc=="L5N"||pc=="L5W"||pc=="L5V")
        ans="Mississauga[Thursday]"
     #||pc=="L4Z"||pc=="L5R"||pc=="L5A"||pc=="L5B")||pc=="L5C"||pc=="L5E"  
        #||pc=="L5G"||pc=="L5H"||pc=="L5J"||pc=="L5K"||pc=="L5L"||pc=="L5M"||pc=="L5N"||pc=="L5W"||pc=="L5V")
      elsif(pc=="L7L"||pc=="L7N"||pc=="L7M"||pc=="L7P"||pc=="L7R"||pc=="L7S"||pc=="L7T")
        ans="Burlington[Thursday]"
      elsif(pc=="L6H"||pc=="L6J"||pc=="L6K"||pc=="L6L"||pc=="L6M")
        ans="Oakville[Thursday]"
      elsif(pc=="L6P"||pc=="L6R"||pc=="L6S"||pc=="L6T"||pc=="L6V"||pc=="L6W"||pc=="L6X"||pc=="L6Y"||pc=="L6Z"||pc=="L7A")
        ans="Brampton[Thursday]"
      else
        ans="Toronto"
      end
    else
      ans=""
    end
    return ans
   end


  end

    
    
