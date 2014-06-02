require 'hyperctl/sysfs'

module Hyperctl
  def self.status(cpu_info)
    # ruby 1.8.7 symbols don't work with <=>
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
