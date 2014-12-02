require 'hyperctl'

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

# 2.6.32-431.5.1.el6.x86_64
# 2 x Intel(R) Xeon(R) CPU E5-2643 0 @ 3.30GHz
RSpec.shared_context 'sysfs_8core_w_ht' do
  before do
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
  end
end

RSpec.shared_context 'cpuinfo_8core_w_ht' do
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

  let(:info) { info }
end

# 2.6.32-431.5.1.el6.x86_64
# 2 x Intel(R) Xeon(R) CPU           X5675  @ 3.07GHz
RSpec.shared_context 'sysfs_12core_wo_ht' do
  before do
    0.upto(11).each do |core_id|
      mksysfs("cpu#{core_id}", 'topology/thread_siblings_list', "#{core_id}\n")
      next if core_id == 0
      mksysfs("cpu#{core_id}", 'online', "1\n")
    end
    12.upto(23).each do |core_id|
      mksysfs("cpu#{core_id}", 'online', "0\n")
    end
  end
end

RSpec.shared_context 'cpuinfo_12core_wo_ht' do
  info = {}
  0.upto(11).each do |core_id|
    name = "cpu#{core_id}"
    info[name.to_sym] = {
      :core_id              => core_id,
      :online               => true,
      :name                 => name,
    }
  end
  12.upto(23).each do |core_id|
    name = "cpu#{core_id}"
    info[name.to_sym] = {
      :core_id              => core_id,
      :online               => false,
      :name                 => name,
    }
  end

  let(:info) { info }
end
