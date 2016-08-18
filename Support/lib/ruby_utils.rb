module RubyUtils
  module_function

  # Try to find the Ruby executable `name`. Return an array containing the
  # command(s) needed to run the executable, or `nil` if the executable could
  # not be found.
  #
  # Typical usage looks like this:
  #
  #     Dir.chdir(ENV['TM_PROJECT_DIRECTORY']) if ENV['TM_PROJECT_DIRECTORY']
  #     executable = RubyUtils.find_executable('rspec')
  #     if executable
  #       system(*executable, '--some', '--additional', 'args')
  #     else
  #       # Executable not found, so use fallback / display alert / …
  #     end
  #
  # Supports the following cases:
  #
  # 1. If an appropriate `TM_*` environment variable is present and points to an
  #    executable file, its value is returned. (The name of the environment
  #    variable is automatically derived from the executable name, eg. `rspec`
  #    → `TM_RSPEC` etc. Alternatively, you can use the `env_var` argument to
  #    explicitly specify the name.)
  # 2. If a binstub (`bin/name`) exists, it is returned.
  # 3. If a Gemfile.lock exists and has an entry for `name`, `[bundle exec
  #    name]` is returned.
  # 4. If `name` is found in the search path, it is returned. (Special case: If
  #    `name` looks like an rbenv shim, also check if the executable has been
  #    installed for the current Ruby version.)
  #
  def find_executable(name, env_var = nil)
    # Safeguard against invalid names so that we don’t need to care about
    # shell escaping later on
    raise ArgumentError, "Invalid characters found in '#{name}'" unless name =~ /\A[\w_-]+\z/

    env_var ||= 'TM_' + name.gsub(/\W+/, '_').upcase
    if ENV[env_var] && ENV[env_var] != '' && File.executable?(ENV[env_var])
      [ENV[env_var]]

    elsif File.exist?("bin/#{name}")
      ["bin/#{name}"]

    elsif File.exist?('Gemfile.lock') && File.read('Gemfile.lock') =~ /^    #{name} /
      %W(bundle exec #{name})

    elsif (path = `which #{name}`.chomp) != ''
      # rbenv installs shims that are present even if the command has not been
      # installed for the current Ruby version, so we need to also check `rbenv
      # which` in this case.
      return nil if path.include?('rbenv/shims') && !system("rbenv which #{name} &>/dev/null")
      [name]
    end
  end
end
