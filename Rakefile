# (cc) 2009 Jan Riethmayer
# http://creativecommons.org/licenses/by-sa/3.0/
# ===========
# = Default =
# ===========
task :default => [:usage]
task :usage do
  puts("Usage: rake install (your config files get backed up to ~/.pre_dotfile_install)")
end
# ===========
# = Install =
# ===========
desc "Install the dotfiles to the current user's home directory"
task :install do
  include InstallHelper
  override = dotfile_update?
  dotfiles.each do |file|
    back_up file unless override
    link_to(file,override)
  end
end
# ===========
# = Helpers =
# ===========
module InstallHelper
  # directories to install (relative path in project)
  def dotfiles
    ["zsh/zshrc", "zsh/zshenv", "ruby/autotest", "ruby/irbrc"]
  end
  #####################################################################
  # if it's an update, we overwrite config-files, to keep all configs
  # up 2 date. Files that existed prior to this dotfiles will be moved
  # to the '.pre_dotfile_install' directory.
  #####################################################################
  def dotfile_update?
    dirname = File.join(ENV['HOME'], ".pre_dotfile_install")
    unless File.exist?(dirname)
      sh %{mkdir "#{dirname}"} do |ok,res|
        unless ok
          say("Failed creating #{dirname} (status = #{res.exitstatus})")
        end
      end
      false
    else
      true
    end
  end
  #####################################################################
  def back_up(file)
    f = File.join(ENV['HOME'], ".#{ split_all(file).last }")
    backup_dir = File.join(ENV['HOME'], ".pre_dotfile_install")
    if File.exist?(f)
      sh %{mv "#{ f }" "#{backup_dir}"} do |ok,res|
        unless ok
          say("Failed to backup #{ f } (status = #{ res.exitstatus })")
        end
      end
    else
      say("#{ f } didn't exist yet")
    end
  end
  #####################################################################
  def link_to(file,override)
    f = split_all(file).last
    from_dir = File.join(Rake.original_dir,file)
    to_dir   = File.join(ENV['HOME'],".#{f}")
    if File.exist?(to_dir)
      if override
        sh %{rm "#{ to_dir }"}
        safe_ln(from_dir,to_dir)
      end
    else
      safe_ln(from_dir,to_dir)
    end
  end
  #####################################################################
  def say(what)
    puts("Info: #{what.to_s}.")
  end
end