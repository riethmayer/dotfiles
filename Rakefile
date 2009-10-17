# (cc) 2009 Jan Riethmayer
# http://creativecommons.org/licenses/by-sa/3.0/
# ===========
# = Default =
# ===========

DOTFILES = %w(ruby/autotest ruby/irbrc ruby/gemrc)

task :default => [:usage]
task :usage do
  description = <<-DOC
    Usage: rake install
    Install the dotfiles to the current user's home directory.
    Files that existed prior to this dotfiles will be moved
    to the '.pre_dotfile_install' directory with a timestamp.
DOC
  puts description
end
# ===========
# = Install =
# ===========
task :install do
  include InstallHelper
  setup_backupdir unless File.exist?(backupdir)
  DOTFILES.each do |file|
    back_up file
    link_to file # deletes file if existing!
  end
end
# ===========
# = Helpers =
# ===========
module InstallHelper
  def setup_backupdir
    sh %{mkdir "#{backupdir}"} do |ok,res|
      unless ok
        say("Failed creating #{backupdir} (status = #{res.exitstatus})")
      end
    end
  end

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

  def link_to(file)
    f = split_all(file).last
    from_dir = File.join(Rake.original_dir,file)
    target   = File.join(ENV['HOME'],".#{f}")
    safe_ln(from_dir,target) unless File.exist?(target)
  end

  def say(what_what)
    puts("Info: #{what_what.to_s}.")
  end

  def backupdir
    @@backupdir ||= File.join(ENV['HOME'], ".pre_dotfile_install")
  end
end