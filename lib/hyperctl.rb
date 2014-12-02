require 'hyperctl/sysfs'

module Hyperctl
  # Enable all sibling cores
  #
  # @param hctl [Hyperctl::Sysfs] object
  # @api public
  def self.enable(hctl)
    # as far as I can tell, there's no way to discover the topology information
    # for which cores and siblings if either of them is disabled.  So we are
    # just trying to enable everything that is disabled...
    cores = hctl.offline_cores
    cores.each {|core_id| Hyperctl::Sysfs.enable_core(core_id) }
  end

  # Disable all sibling cores
  #
  # @param hctl [Hyperctl::Sysfs] object
  # @api public
  def self.disable(hctl)
    cores = hctl.sibling_cores
    cores.each {|core_id| Hyperctl::Sysfs.disable_core(core_id) }
  end

  # Generate a pretty formatted string of sibling core status
  #
  # @param hctl [Hyperctl::Sysfs] object
  # @return [String] the generated string
  # @api public
  def self.status(hctl)
    cpu_info = hctl.cpu_info
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
