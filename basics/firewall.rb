require 'set'


dep('firewall-rule-exists', :action, :from, :to_port) do
  requires {
    on :ubuntu, 'ufw-firewall-rule-exists'.with(action: action, from: from, to_port: to_port)
  }
end

dep('firewall-enabled') do
  requires {
    on :ubuntu, 'ufw-firewall-enabled'
  }
end

def('ufw-firewall-enabled') do

  met? {
    sudo 'ufw status'.include? "Status: active"
  }

  meet {
    sudo 'ufw enable'
  }
  
end

dep('ufw-firewall-rule-exists', :action, :from, :to_port) do
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
    { to_port: to_port.current_value.to_s, action: (action.current_value || :allow_in), from: (from.current_value || :anywhere) }
  end

  def rule_desc(_rule)
    action_s = { allow_in: 'allow', deny_in: 'deny' }[_rule[:action]]
    from_s = ( _rule[:from] == :anywhere ? '' : "from #{_rule[:from]}" )

    "#{ action_s } #{ from_s } to any port #{_rule[:to_port]}"
  end

  met? {
    log "Checking if firewall does #{rule_desc(rule)}..."
    ufw_rules = parse_ufw_output( sudo('ufw status numbered') )

    ufw_rules.include?(rule)
  }

  meet {    
    cmd = "ufw #{ rule_desc(rule) }"

    log_ok "Executing 'sudo #{cmd}'..."

    sudo cmd
  }
end