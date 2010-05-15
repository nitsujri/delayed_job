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

	    #Uses Chronic the natural language parser
	    def run(time)
	      @schedule = time
	    end

       #An attempt at using :run_at => "8 am", :run_every => 1.days
       #ultimately it'll be like Time.parse("8 am").1.day.from_now <- Doesn't work, lol.
#      def run(args)
#        @schedule = args
#      end
	  end

    def schedule!
      #nitsujri's patch to remove .from_now to be able to schedule any time, relies on Chronic
      Delayed::Job.enqueue self, 0, Chronic.parse(self.class.schedule) if self.class.schedule
    end

	  def perform_with_schedule
	    perform_without_schedule
      self.schedule!
	  end
  end
end

