require 'shellwords'

module Executable
  class NotFound < RuntimeError; end

  class << self
    # Try to find the Ruby executable `name`. Return an array containing the
    # command(s) needed to run the executable. If the executable could not be
    # found, `Executable::NotFound` is raised with a message describing the
    # problem.
    #
    # Typical usage looks like this:
    #
    #     Dir.chdir(ENV['TM_PROJECT_DIRECTORY']) if ENV['TM_PROJECT_DIRECTORY']
    #     begin
    #       executable = Executable.find('rspec')
    #       system(*executable, '--some', '--additional', 'args')
    #     rescue Executable::NotFound => e
    #       # Executable not found, so use fallback / display alert / …
    #       # `e.message` contains detailed error message.
    #     end
    #
    # Supports the following cases:
    #
    # 1. If an appropriate `TM_*` environment variable is present and points to
    #    an executable file, its value is returned. (The name of the environment
    #    variable is automatically derived from the executable name, eg. `rspec`
    #    → `TM_RSPEC` etc. Alternatively, you can use the `env_var` argument
    #    to explicitly specify the name.)
    # 2. If a binstub (`bin/name`) exists, it is returned.
    # 3. If a Gemfile.lock exists and has an entry for `name`, `[bundle exec
    #    name]` is returned.
    # 4. If `name` is found in the search path, it is returned. (Special case:
    #    If `name` looks like an rbenv shim, also check if the executable has
    #    been installed for the current Ruby version.)
    #
    # Both RVM and rbenv are supported, too:
    #
    # * If RVM is installed, the executable will be run via a small wrapper
    #   shell script that sets up RVM correctly before running the executable.
    #   (Note that this is NOT the case if an appropriate `TM_*` environment
    #   variable is present: In this case, the value of the environment variable
    #   is returned unchanged. )
    #
    # * rbenv just works out of the box as long as your PATH (inside TextMate)
    #   is setup to contain `~/.rbenv/shims`.
    #
    def find(name, env_var = nil)
      # Safeguard against invalid names so that we don’t need to care about
      # shell escaping later on
      raise ArgumentError, "Invalid characters found in '#{name}'" unless name =~ /\A[\w_-]+\z/

      env_var ||= 'TM_' + name.gsub(/\W+/, '_').upcase
      prefix = determine_rvm_prefix || []
      if (cmd = ENV[env_var]) && cmd != ''
        cmd = cmd.shellsplit
        if system('which', '-s', cmd[0])
          cmd
        else
          raise NotFound, "#{env_var} is set to '#{cmd}', but this does not seem to exist."
        end

      elsif File.exist?("bin/#{name}")
        prefix + ["bin/#{name}"]

      elsif File.exist?('Gemfile.lock') && File.read('Gemfile.lock') =~ /^    #{name} /
        prefix + %W(bundle exec #{name})

      elsif (path = `#{prefix.map(&:shellescape).join(' ')} which #{name}`.chomp) != ''
        # rbenv installs shims that are present even if the command has not been
        # installed for the current Ruby version, so we need to also check `rbenv
        # which` in this case.
        if path.include?('rbenv/shims') && !system("rbenv which #{name} &>/dev/null")
          raise NotFound, "rbenv reports that '#{name}' is not installed for the current Ruby version."
        else
          prefix + [name]
        end

      else
        raise NotFound, "Could not find executable '#{name}'."
      end
    end

    private

    # Return appropriate prefix for running commands via RVM if RVM is installed
    # and the current directory contains an RVM project file.
    def determine_rvm_prefix
      rvm = "#{ENV['HOME']}/.rvm/bin/rvm"
      %W(#{ENV['TM_BUNDLE_SUPPORT']}/bin/rvm_wrapper) if File.exist?(rvm)
    end

    def ruby_version_in_gemfile?
      File.exist?('Gemfile.lock') && File.read('Gemfile.lock') =~ /^RUBY_VERSION/
    end
  end
end
