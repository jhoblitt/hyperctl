class Hyperctl::Sysfs
  attr_accessor :cpu_info

  def initialize
    @cpu_info = refresh
  end

  def refresh
    info = {}

    # get a listing of all cpu cores
    cpu_dirs = Dir.glob('/sys/devices/system/cpu/cpu[0-9]*')

    cpu_dirs.each do |d|
      # find the "name" of the cpu based on the sysfs dir. Eg, cpu15
      cpu_name = File.basename d
      cpu_idx = cpu_name.to_sym
      info[cpu_idx] = { :name => cpu_name }

      # find the numeric core_id. Eg, 15 in sysfs as
      # /sys/devices/system/cpu/cpu3/topology/core_id but we can parse it from
      # the path
      core_id = cpu_name.match(/cpu(\d+)/)[1].to_i
      info[cpu_idx][:core_id] = core_id

      # is the cpu online?
      # if a CPU is online, /sys/devices/system/cpu/cpu1/online will be 1,
      # otherwise 0.  cpu0 appears to be special and does not have the online
      # sysfs entry on any of the systems I inspected. I suspect that it might
      # get this attribute if CONFIG_BOOTPARAM_HOTPLUG_CPU0 is enabled per
      # https://www.kernel.org/doc/Documentation/cpu-hotplug.txt
      path = File.join(d, 'online')
      online = false
      if File.exist?(path)
        online = to_bool(File.read(path).chomp)
      elsif core_id == 0
        # cpu0 gets a special pass if the online attr is missing
        online = true
      end
      info[cpu_idx][:online] = online

      next unless online

      # does the cpu have any [SMT] siblings?
      # The attr /sys/devices/system/cpu/cpu6/topology/thread_siblings_list
      # will list all siblings including the cpu's own core_id This attr is not
      # present if the cpu is offline This attr is not present under EL5.x
      # (2.6.18-164.el5PAE) on the one system I inspected that appears to have
      # HT disabled in the bios (/proc/cpuinfo shows the ht cpu flag but
      # there's no siblings list)
      path = File.join(d, 'topology/thread_siblings_list')
      if File.exist?(path)
        sibs = File.read(path).chomp.split(',')
        # convert core_id(s) to be numeric
        sibs.map! {|s| s.to_i }
        # remove the cpu's core_id from the list
        sibs = sibs - [ core_id ]
        unless sibs.empty?
          info[cpu_idx][:thread_siblings_list] = sibs
        end
      end
    end

    @cpu_info = info
  end

  def cores
    cores = []
    cpu_info.each_key.sort_by {|k| cpu_info[k][:core_id] }.each do |k|
      cores << cpu_info[k][:core_id]
    end

    return cores
  end

  def online_cores
    cores = []
    cpu_info.each_key.sort_by {|k| cpu_info[k][:core_id] }.each do |k|
      core_id = cpu_info[k][:core_id]
      if cpu_info[k][:online] == true
        cores << core_id
      end
    end

    return cores
  end

  def offline_cores
    cores = []
    cpu_info.each_key.sort_by {|k| cpu_info[k][:core_id] }.each do |k|
      core_id = cpu_info[k][:core_id]
      if cpu_info[k][:online] == false
        cores << core_id
      end
    end

    return cores
  end

  def sibling_cores
    cores = []
    checked_cores = []
    cpu_info.each_key.sort_by {|k| cpu_info[k][:core_id] }.each do |k|
      cpu = cpu_info[k]
      checked_cores << cpu[:core_id]

      if cpu.has_key?(:thread_siblings_list)
        (cpu[:thread_siblings_list] - checked_cores).each do |core_id|
          # check to see if the core is already disabled
          # XXX this probably isn't nessicary as a disabled core appears to #
          # never be listed as a sibiling
          if cpu_info[k][:online] == true
            cores << core_id
          end
        end
      end
    end

    return cores
  end

  def all_cores_enabled?
    cores.count == online_cores.count
  end

  def self.enable_core(core_id)
    set_core(core_id, '1')
  end

  def self.disable_core(core_id)
    set_core(core_id, '0')
  end

  private

  def to_bool(s)
    return true if s =~ /^1$/
    return false
  end

  def self.set_core(core_id, state)
    path = File.join('/sys/devices/system/cpu', "cpu#{core_id.to_s}", 'online')
    # doesn't work in ruby 1.8.7: File.write(path, '0')
    File.open(path, 'w') do |f|
      f.write(state)
    end
  end
end # class Hyperctl::Sysfs
