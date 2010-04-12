module Delayed
  module ScheduledJob

	  def self.included(base)
	    base.extend(ClassMethods)
	  end
	  
	  module ClassMethods
	    def method_added(name)
	      if name.to_s == "perform" && !@redefined
	        @redefined = true
	        alias_method_chain :perform, :schedule
	      end
	    end
	    
	    def schedule
	      @schedule
	    end
	    
	    def run_every(time)
	      @schedule = time
	    end  
	  end
	  
    def schedule!
      #Delayed::Job.enqueue self, 0, self.class.schedule.from_now if self.class.schedule
      #nitsujri's patch to remove .from_now to be able to schedule any time
      Delayed::Job.enqueue self, 0, self.class.schedule if self.class.schedule
    end

	  def perform_with_schedule
	    perform_without_schedule
      self.schedule!
	  end
  end
end
