require 'minitest/autorun'
require "#{__dir__}/../lib/executable"

class TestExecutableFind < Minitest::Test
  def setup
    Dir.chdir("#{__dir__}/attic/sample_project")
  end

  def with_env(env_vars)
    original_env = ENV.to_h
    ENV.update(env_vars)
    yield
  ensure
    ENV.replace(original_env)
  end

  def test_validate_name
    assert_raises(ArgumentError){ Executable.find('foo bar') }
    assert_raises(ArgumentError){ Executable.find('') }
    assert_raises(ArgumentError){ Executable.find(nil) }
    assert_raises(ArgumentError){ Executable.find('special;characters') }
    assert_raises(ArgumentError){ Executable.find('not\ ok') }
    assert_raises(ArgumentError){ Executable.find('"quoted"') }

    # None of these should raise:
    Executable.find('rspec')
    Executable.find('foo-bar')
    Executable.find('some_tool')
  end

  def test_use_env_var
    rspec_path = "#{__dir__}/attic/sample_project/other/rspec"
    with_env('TM_RSPEC' => rspec_path) do
      assert_equal [rspec_path], Executable.find('rspec')
    end
  end

  def test_use_custom_env_var
    rspec_path = "#{__dir__}/attic/sample_project/other/rspec"
    with_env('TM_RSPEC' => rspec_path) do
      assert_equal [rspec_path], Executable.find('rspec-special', 'TM_RSPEC')
    end
  end

  def test_use_env_var_with_executable_in_path
    with_env('PATH' => "#{__dir__}/attic/bin:#{ENV['PATH']}", 'TM_SAMPLE' => 'sample-executable') do
      assert_equal %w(sample-executable), Executable.find('sample')
    end
  end

  def test_use_env_var_with_missing_executable
    with_env('TM_NONEXISTING_EXECUTABLE' => "#{__dir__}/attic/sample_project/other/nonexisting") do
      assert_nil Executable.find('nonexisting', 'TM_NONEXISTING_EXECUTABLE')
    end
  end

  def test_find_binstub
    assert_equal %w(bin/rspec), Executable.find('rspec')
  end

  def test_find_in_gemfile
    assert_equal %w(bundle exec rubocop), Executable.find('rubocop')
  end

  def test_find_in_path
    # Of course `ls` is not a Ruby executable, but for this test this makes no difference
    assert_equal %w(ls), Executable.find('ls')
  end

  def test_missing_executable
    assert_nil Executable.find('nonexisting_executable')
  end

  def test_missing_executable_with_rbenv_and_shim
    # Setup an environment where our fake implementation of `rbenv` is in the
    # path, as well as our fake shim  (`rbenv_installed_shim`). Note that the
    # fake implentation of `rbenv` will return an “not found” error if run
    # as `rbenv which rbenv_installed_shim`
    with_env('PATH' => "#{__dir__}/attic/fake_rbenv:#{__dir__}/attic/fake_rbenv/shims:#{ENV['PATH']}") do
      assert_equal "#{__dir__}/attic/fake_rbenv/rbenv", `which rbenv`.chomp
      assert system('which -s rbenv_installed_shim')

      # Now for the actual test
      assert_nil Executable.find('rbenv_installed_shim')
    end
  end
end
