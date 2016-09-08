require 'minitest/autorun'
require 'shellwords'
require "#{__dir__}/../lib/executable"

class TestExecutableFind < Minitest::Test
  def setup
    Dir.chdir("#{__dir__}/fixtures/sample_project")

    # Set $HOME to a directory controlled by us to make sure `$HOME/.rvm` does
    # not exist even if the user running these tests has rvm actually installed.
    # Also, clear out all `TM_*` env vars so they won’t interfere with our
    # tests.
    @original_env = ENV.to_h
    ENV['HOME'] = "#{__dir__}/fixtures/sample_project"
    ENV.delete_if{ |name, _value| name.start_with?('TM_') }
  end

  def teardown
    ENV.replace(@original_env)
  end

  def with_env(env_vars)
    original_env = ENV.to_h
    ENV.update(env_vars)
    yield
  ensure
    ENV.replace(original_env)
  end

  def with_rvm_installed
    with_env('HOME' => "#{__dir__}/fixtures/fake_rvm_home") do
      yield
    end
  end
  
  def with_rvm_project_file
    with_env('PRETEND_RVM_RUBY' => '2.1.0') do
      yield
    end
  end

  def test_validate_name
    assert_raises(ArgumentError){ Executable.find('foo bar') }
    assert_raises(ArgumentError){ Executable.find('') }
    assert_raises(ArgumentError){ Executable.find(nil) }
    assert_raises(ArgumentError){ Executable.find('special;characters') }
    assert_raises(ArgumentError){ Executable.find('not\ ok') }
    assert_raises(ArgumentError){ Executable.find('"quoted"') }
  end

  def test_use_env_var
    rspec_path = "#{__dir__}/fixtures/sample_project/other/rspec"
    with_env('TM_RSPEC' => rspec_path.shellescape) do
      assert_equal [rspec_path], Executable.find('rspec')
    end
  end

  # Even if RVM is installed, if an env var is set for the executable it should
  # be used unchanged (i.e. it should not be prefixed with `rvm . do`).
  def test_use_env_var_with_rvm
    rspec_path = "#{__dir__}/fixtures/sample_project/other/rspec"
    with_env('TM_RSPEC' => rspec_path.shellescape) do
      assert_equal [rspec_path], Executable.find('rspec')
    end
  end

  def test_use_custom_env_var
    rspec_path = "#{__dir__}/fixtures/sample_project/other/rspec"
    with_env('TM_RSPEC' => rspec_path.shellescape) do
      assert_equal [rspec_path], Executable.find('rspec-special', 'TM_RSPEC')
    end
  end

  # Setting TM_FOO to eg. `bundle exec foo` should be possible, too.
  def test_use_env_var_with_executable_with_spaces
    with_env('PATH' => "#{__dir__}/fixtures/bin:#{ENV['PATH']}", 'TM_SAMPLE' => 'sample-executable with options') do
      assert_equal %w(sample-executable with options), Executable.find('sample')
    end
  end

  def test_use_env_var_with_missing_executable
    with_env('TM_NONEXISTING_EXECUTABLE' => 'nonexisting-executable') do
      assert_raises(Executable::NotFound){ Executable.find('nonexisting-executable', 'TM_NONEXISTING_EXECUTABLE') }
    end
  end

  def test_find_binstub
    assert_equal %w(bin/rspec), Executable.find('rspec')
  end

  def test_find_binstub_with_rvm
    with_rvm_installed do
      assert_equal %w(bin/rspec), Executable.find('rspec')
      with_rvm_project_file do
        assert_equal %w(rvm . do bin/rspec), Executable.find('rspec')
      end
    end
  end
  
  def test_find_in_gemfile
    assert_equal %w(bundle exec rubocop), Executable.find('rubocop')
  end

  def test_find_in_gemfile_with_rvm
    with_rvm_installed do
      assert_equal %w(bundle exec rubocop), Executable.find('rubocop')
      with_rvm_project_file do
        assert_equal %w(rvm . do bundle exec rubocop), Executable.find('rubocop')
      end
    end
  end

  # def test_find_with_rvm_without_ini_file
  #   with_env('HOME' => "#{__dir__}/fixtures/fake_rvm_home") do
  #     # With no rvm ini file in place, rvm detection should NOT take place
  #     assert_raises(Executable::NotFound){ Executable.find('sample_executable_from_rvm') }
  #   end
  # end

  def test_find_in_path
    # Of course `ls` is not a Ruby executable, but for this test this makes no difference
    assert_equal %w(ls), Executable.find('ls')
  end

  def test_find_in_path_with_rvm
    # Of course `ls` is not a Ruby executable, but for this test this makes no difference
    with_rvm_installed do
      assert_equal %w(ls), Executable.find('ls')
      with_rvm_project_file do
        assert_equal %w(rvm . do ls), Executable.find('ls')
      end
    end
  end

  def test_missing_executable
    assert_raises(Executable::NotFound){ Executable.find('nonexisting-executable') }
  end

  def test_missing_executable_with_rbenv_and_shim
    # Setup an environment where our fake implementation of `rbenv` is in the
    # path, as well as our fake shim  (`rbenv_installed_shim`). Note that the
    # fake implentation of `rbenv` will return an “not found” error if run
    # as `rbenv which rbenv_installed_shim`
    with_env('PATH' => "#{__dir__}/fixtures/fake_rbenv:#{__dir__}/fixtures/fake_rbenv/shims:#{ENV['PATH']}") do
      assert_equal "#{__dir__}/fixtures/fake_rbenv/rbenv", `which rbenv`.chomp
      assert system('which -s rbenv_installed_shim')

      # Now for the actual test
      assert_raises(Executable::NotFound){ Executable.find('rbenv_installed_shim') }
    end
  end

  def test_find_precedence
    # Make sure we start with a directory with no Gemfile or binstubs, and also with no environment variable.
    Dir.mktmpdir do |dir|
      Dir.chdir(dir)

      # Using search path has lowest precedence
      with_env('PATH' => "#{__dir__}/fixtures/bin:#{ENV['PATH']}") do
        assert_equal %w(rspec), Executable.find('rspec')

        # Using a Gemfile comes next
        FileUtils.cp(Dir.glob("#{__dir__}/fixtures/sample_project/Gemfile.*"), dir)
        assert_equal %w(bundle exec rspec), Executable.find('rspec')

        # Using a binstub has an even higher precedence
        FileUtils.cp_r("#{__dir__}/fixtures/sample_project/bin", dir)
        assert_equal %w(bin/rspec), Executable.find('rspec')

        # Finally, using an environment variable has highest precedence
        with_env('TM_RSPEC' => 'ls') do
          assert_equal %w(ls), Executable.find('rspec')
        end
      end
    end
  end
end
