require 'spec_helper'

class Job
  attr_accessor :state, :config
  def owner; stub('request', :start => nil, :state => nil, :state= => nil) end
  def update_attributes(*); end
  def save!; end
end

describe Travis::Model::Job::Configure do
  let(:record) { Job.new }
  let(:job)    { Travis::Model::Job::Configure.new(record) }
  let(:config) { { :rvm => 'rbx' } }

  before :each do
    job.owner.stubs(:configure)
  end

  describe 'events' do
    describe 'starting the job' do
      it 'sets the state to :started' do
        job.start
        job.state.should == :started
      end

      it 'propagates the event to the owner' do
        job.owner.expects(:start)
        job.start
      end
    end

    describe 'finishing the job' do
      it 'sets the state to :finished' do
        job.finish(config)
        job.state.should == :finished
      end

      it 'configures the owner' do
        job.owner.expects(:configure).with(config)
        job.finish(config)
      end
    end

    describe 'update_attributes' do
      describe 'given finishing attributes' do
        let(:attributes) { { :config => { :rvm => 'rbx' }, :status => 0 } }

        it 'extracts finishing attributes' do
          job.update_attributes(attributes)
        end

        it 'updates the record with the given attributes' do
          job.record.expects(:update_attributes).with(attributes)
          job.update_attributes(attributes)
        end

        it 'finishes the job' do
          job.update_attributes(attributes)
          job.state.should == :finished
        end
      end
    end
  end
end
