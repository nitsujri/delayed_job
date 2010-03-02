require 'spec_helper'
class ScheduledJob
  include Delayed::ScheduledJob
  run_every 5.minutes
  
  def perform() end
end

class MisconfiguredScheduledJob
  include Delayed::ScheduledJob

  def perform() end
end

class FailedScheduledJob
  include Delayed::ScheduledJob
  run_every 5.minutes
  
  def perform
    raise ArgumentError, "whatevz"
  end
end

describe 'scheduled jobs' do
  describe "with a run every time" do 
    before(:all) do

    end
    
    it "should queue just like a regular job" do
      lambda { 
        Delayed::Job.enqueue ScheduledJob.new
      }.should_not raise_error
    end
    
    it "should create a new job for every perform" do
      lambda {
        ScheduledJob.new.perform
      }.should change(Delayed::Job, :count).by(1)
    end
    
    it "should create the new job ~ 5 minutes in the future" do
      sleep 1
      ScheduledJob.new.perform
      #because milliseconds count
      (Delayed::Job.last(:order => 'created_at').run_at.to_i - 5.minutes.from_now.to_i).abs.should < 10
    end
    
    it "should not schedule a new job if the job fails" do
      sleep 1
      lambda {
        begin
          FailedScheduledJob.new.perform
        rescue
        end
      }.should_not change(Delayed::Job, :count)
    end

    it "should still have a perform method" do
      ScheduledJob.new.respond_to?(:perform).should be_true
    end
  end
  
  describe "without a run every time" do
    it "should run without a hiccup" do
      lambda {
        MisconfiguredScheduledJob.new.perform
      }.should_not raise_error
    end
    
    it "should not create a new job" do
      lambda {
        MisconfiguredScheduledJob.new.perform
      }.should_not change(Delayed::Job, :count)
    end
  end
end