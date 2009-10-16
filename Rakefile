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
  setup_backupdir
  dotfiles.each do |file|
    back_up file
    link_to file # deletes file if existing!
  end
end
# ===========
# = Helpers =
# ===========
module InstallHelper
  # directories to install (relative path in project)
  def dotfiles
    %w(ruby/autotest ruby/irbrc ruby/gemrc)
  end
  #####################################################################
  # if it's an update, we overwrite config-files, to keep all configs
  # up 2 date. Files that existed prior to this dotfiles will be moved
  # to the '.pre_dotfile_install' directory.
  #####################################################################
  def setup_backupdir
    unless File.exist?(backupdir)
      sh %{mkdir "#{backupdir}"} do |ok,res|
        unless ok
          say("Failed creating #{backupdir} (status = #{res.exitstatus})")
        end
      end
    end
  end
  #####################################################################
  def back_up(file)
    f = split_all(file).last
    target = File.join(ENV['HOME'], ".#{ f }")
    if File.exist?(target)
      nf = "#{Time.now.strftime("%Y%m%d%k%M%S")}-#{f}"
      sh %{mv "#{ target }" "#{File.join(backupdir,nf)}"} do |ok,res|
        unless ok
          say("Failed to backup .#{ f } (status = #{ res.exitstatus })")
        end
      end
    else
      say(".#{ f } didn't exist yet")
    end
  end
  #####################################################################
  # deletes file
  def link_to(file)
    f = split_all(file).last
    from_dir = File.join(Rake.original_dir,file)
    target   = File.join(ENV['HOME'],".#{f}")
    safe_ln(from_dir,target)
  end
  #####################################################################
  def say(what)
    puts("Info: #{what.to_s}.")
  end
  def backupdir
    @@backupdir ||= File.join(ENV['HOME'], ".pre_dotfile_install")
  end
end