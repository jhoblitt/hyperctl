require 'spec_helper'
# pp must be required before fakefs
# see: https://github.com/defunkt/fakefs/issues/99
require 'pp'
require 'fakefs'

describe Hyperctl::Sysfs do
  context 'on a 8 physical core w/ HT enabled system' do
    include_context "sysfs_16core_w_ht"
    include_context "cpuinfo_16core_w_ht"
    let(:hctl) { Hyperctl::Sysfs.new }

    context 'fakefs sanity checks' do
      it { expect(File.exists?(sysfs('cpu1', 'online'))).to be true }
      it { expect(File.exists?(sysfs('cpu1', 'topology/thread_siblings_list'))).to be true }
      it { expect(sysfs('cpu1', 'topology/thread_siblings_list')).to contain(/1,9/) }
    end

    describe '#new' do
      it 'finds all the cores' do
        expect(hctl.cpu_info).to eq(info)
      end
    end

    describe '#disable_core' do
      it 'disbles core_id 15' do
        hctl.disable_core(15)
        hctl.refresh

        expect(sysfs('cpu15', 'online')).to contain(/^0$/)
      end
    end

    describe '#enable_core' do
      # note that this context is highly coupled with the #disable_core context
      it 'enables core_id 15' do
        hctl.enable_core(15)
        hctl.refresh

        expect(sysfs('cpu15', 'online')).to contain(/^1$/)
      end
    end
  end # on a 8 physical core w/ HT enabled system
end

