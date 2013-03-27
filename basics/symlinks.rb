dep('symlink', :symlink_to, :symlink_path, :create_as) do
  create_as.default!(ENV['USER'])

  requires 'matrix data dir', 'matrix expanded'.with(matrix_version: matrix_version), 'user-exists'.with(username: create_as)
  

  def symlink
    symlink_path.p
  end

  def symlink_points_to_target?
    symlink_target = symlink.realpath.to_s
    log "Symlink at '#{symlink}' pointing to: '#{symlink_target}'"
  
    symlink_target.eql?( symlink_to.p.realpath.to_s )
  end
  
  met? { 
     symlink.exists? && symlink_points_to_target?
  }
  
  meet {
    shell "ln -sf #{symlink_to} #{symlink}", as: create_as
    log_ok "Set symlink '#{symlink}' -> '#{symlink_to}'"
  }
end