require 'spec_helper'
require 'fakefs'

def sysfs(cpu_name, attr)
  File.join('/sys/devices/system/cpu/', cpu_name, attr)
end

def mksysfs(cpu_name, attr, value)
  path = sysfs(cpu_name, attr)
  dir  = File.dirname path
  FileUtils.mkdir_p dir
  File.open(path, 'w+') do |f|
    f.write(value)
  end
end

RSpec::Matchers.define :contain do |content|
  match do |path|
    File.read(path) =~ content
  end
end

describe Hyperctl::Sysfs do
  0.upto(15).each do |core_id|
    next if core_id == 0
    mksysfs("cpu#{core_id}", 'online', "1\n")
  end
  0.upto(7).each do |core_id|
    mksysfs("cpu#{core_id}", 'topology/thread_siblings_list', "#{core_id},#{core_id + 8}\n")
  end
  8.upto(15).each do |core_id|
    mksysfs("cpu#{core_id}", 'topology/thread_siblings_list', "#{core_id},#{core_id - 8}\n")
  end

  it do
    expect(File.exists?(sysfs('cpu1', 'online'))).to be true
    expect(File.exists?(sysfs('cpu1', 'topology/thread_siblings_list'))).to be true
  end

  it do
    expect(sysfs('cpu1', 'topology/thread_siblings_list')).to contain(/1,9/)
  end

  it do
    hctl = Hyperctl::Sysfs.new

    info = {}
    0.upto(7).each do |core_id|
      name = "cpu#{core_id}"
      info[name.to_sym] = {
        :core_id              => core_id,
        :online               => true,
        :thread_siblings_list => [ core_id + 8 ],
        :name                 => name,
      }
    end
    8.upto(15).each do |core_id|
      name = "cpu#{core_id}"
      info[name.to_sym] = {
        :core_id              => core_id,
        :online               => true,
        :thread_siblings_list => [ core_id - 8 ],
        :name                 => name,
      }
    end

    expect(hctl.cpu_info).to eq(info)
  end


  it do
    hctl = Hyperctl::Sysfs.new
    hctl.disable_core(15)
    hctl.refresh

    expect(sysfs('cpu15', 'online')).to contain(/^0$/)
  end

  it do
    hctl = Hyperctl::Sysfs.new
    hctl.enable_core(15)
    hctl.refresh

    expect(sysfs('cpu15', 'online')).to contain(/^1$/)
  end

end

