# Based on Ben Hoskins' 'user exists' dep
dep 'user-exists', :username, :group, :homedir do
  group.default!(username)
  
  requires_when_unmet "group-exists".with(group)

  homedir.default!("/home/#{username}")

  on :osx do
    met? { !shell("dscl . -list /Users").split("\n").grep(username).empty? }
    meet {
      {
        'Password' => '*',
        'UniqueID' => (501...1024).detect {|i| (Etc.getpwuid i rescue nil).nil? },
        'PrimaryGroupID' => group,
        'RealName' => username,
        'NFSHomeDirectory' => homedir,
        'UserShell' => '/bin/bash'
      }.each_pair {|k,v|
        # /Users/... here is a dscl path, not a filesystem path.
        sudo "dscl . -create #{'/Users' / username} #{k} '#{v}'"
      }
      sudo "mkdir -p '#{homedir}'"
      sudo "chown #{username}:#{group} '#{homedir}'"
      sudo "chmod 701 '#{homedir}'"
    }
  end
  on :linux do
    met? { '/etc/passwd'.p.grep(/^#{username}:/) }
    meet {
      sudo "mkdir -p #{homedir}" and
      sudo "useradd -m -s /bin/bash -d #{homedir} -g #{group} #{username}" and
      sudo "chmod 701 #{homedir}"
    }
  end
end

dep 'group-exists', :group do
  on :linux do
    met? { '/etc/group'.p.grep(/^#{group}:/) }
    meet {
      sudo "groupadd #{group}"
    }
  end
end