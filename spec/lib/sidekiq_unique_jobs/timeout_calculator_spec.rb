require 'spec_helper'

RSpec.describe SidekiqUniqueJobs::TimeoutCalculator do
  shared_context 'undefined worker class' do
    subject { described_class.new('class' => 'test') }
  end

  shared_context 'item not scheduled' do
    subject { described_class.new('class' => 'MyUniqueJob') }
  end

  describe 'public api' do
    subject { described_class.new(nil) }
    it { is_expected.to respond_to(:time_until_scheduled) }
    it { is_expected.to respond_to(:worker_class_queue_lock_expiration) }
    it { is_expected.to respond_to(:worker_class_run_lock_expiration) }
    it { is_expected.to respond_to(:worker_class) }
    it { is_expected.to respond_to(:seconds) }
  end

  describe '.for_item' do
    it 'initializes a new calculator' do
      expect(described_class).to receive(:new).with('WAT')
      described_class.for_item('WAT')
    end
  end

  describe '#time_until_scheduled' do
    it_behaves_like 'item not scheduled' do
      its(:time_until_scheduled) { is_expected.to eq(0) }
    end

    subject { described_class.new('class' => 'MyUniqueJob', 'at' => schedule_time) }
    let(:schedule_time) { Time.now.utc.to_i + 24 * 60 * 60 }
    let(:now_in_utc) { Time.now.utc.to_i }

    its(:time_until_scheduled) do
      Timecop.travel(Time.at(now_in_utc)) do
        is_expected.to be_within(1).of(schedule_time - now_in_utc)
      end
    end
  end

  describe '#worker_class_queue_lock_expiration' do
    it_behaves_like 'undefined worker class' do
      its(:worker_class_queue_lock_expiration) { is_expected.to eq(nil) }
    end

    subject { described_class.new('class' => 'MyUniqueJob') }
    its(:worker_class_queue_lock_expiration) { is_expected.to eq(7_200) }
  end

  describe '#worker_class_run_lock_expiration' do
    it_behaves_like 'undefined worker class' do
      its(:worker_class_run_lock_expiration) { is_expected.to eq(nil) }
    end

    subject { described_class.new('class' => 'LongRunningJob') }
    its(:worker_class_run_lock_expiration) { is_expected.to eq(7_200) }
  end

  describe '#worker_class' do
    it_behaves_like 'undefined worker class' do
      its(:worker_class) { is_expected.to eq('test') }
    end

    subject { described_class.new('class' => 'MyJob') }
    its(:worker_class) { is_expected.to eq(MyJob) }
  end
end
