require 'hyperctl/sysfs'

module Hyperctl
  def self.disable(cpu_info)
    checked_core = []
    disable_core = []
    cpu_info.each_key.sort_by {|k| cpu_info[k][:core_id] }.each do |k|
      cpu = cpu_info[k]
      checked_core << cpu[:core_id]

      if cpu.has_key?(:thread_siblings_list)
        (cpu[:thread_siblings_list] - checked_core).each do |core_id|
          # check to see if the core is already disabled
          if cpu_info["cpu#{core_id}".to_sym][:online] == true
            disable_core << core_id
          end
        end
      end
    end

    disable_core.each {|core_id| Hyperctl::Sysfs.disable_core(core_id) }
  end

  def self.status(cpu_info)
    text = ""
    cpu_info.each_key.sort_by {|k| cpu_info[k][:core_id] }.each do |k|
      cpu = cpu_info[k]
      state = cpu[:online] ? 'enabled' : 'disabled'
      ht = cpu.has_key?(:thread_siblings_list) ? 'enabled' : 'disabled'
      text << "#{sprintf('%-5s',k.to_s)}: #{sprintf('%-8s', state)}"
      text << " - hypertheading: #{ht}\n"
    end

    return text
  end
end # module Hyperctl
