require 'set'

dep('firewall-rule-exists', :action, :from, :to_port) do
  action.default!(:allow_in)
  from.default!(:anywhere)

  def parse_ufw_output(output)
    ufw_rules = Set.new
    output.scan(/^\[(?<rule_num>[\s\d]+)\]\s+(?<to_port>\d+\/?\S+)\s+(?<action>\S+\s?\S+)\s+(?<from>.*)$/) do | m | 
      md = Regexp.last_match
      ufw_rules << { 
        to_port: md[:to_port], 
        action: md[:action].gsub(/\s/, '_').downcase.to_sym, 
        from: md[:from].include?('Anywhere') ? :anywhere : md[:from] 
      }
    end

    ufw_rules
  end

  def rule
    { to_port: to_port.current_value, action: action.current_value, from: from.current_value }
  end

  met? {
    parse_ufw_output( sudo('ufw status numbered') ).include?(rule)
  }

  meet {
    action_s = { allow_in: 'allow', deny_in: 'deny' }[action]
    raise "Don't know how to set up ufw for rule: #{rule}"
    cmd = ("ufw #{ } #{ from == :anywhere ? '' : "from #{from}"} to any #{to_port}")
    log cmd
  }
end