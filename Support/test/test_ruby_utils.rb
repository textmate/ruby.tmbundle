require 'minitest/autorun'
require "#{__dir__}/../lib/ruby_utils"

class TestRubyUtilsFindExecutable < Minitest::Test
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
    assert_raises(ArgumentError){ RubyUtils.find_executable('foo bar') }
    assert_raises(ArgumentError){ RubyUtils.find_executable('') }
    assert_raises(ArgumentError){ RubyUtils.find_executable(nil) }
    assert_raises(ArgumentError){ RubyUtils.find_executable('special;characters') }
    assert_raises(ArgumentError){ RubyUtils.find_executable('not\ ok') }
    assert_raises(ArgumentError){ RubyUtils.find_executable('"quoted"') }

    # None of these should raise:
    RubyUtils.find_executable('rspec')
    RubyUtils.find_executable('foo-bar')
    RubyUtils.find_executable('some_tool')
  end

  def test_use_env_var
    rspec_path = "#{__dir__}/attic/sample_project/other/rspec"
    with_env('TM_RSPEC' => rspec_path) do
      assert_equal [rspec_path], RubyUtils.find_executable('rspec')
    end
  end

  def test_use_custom_env_var
    rspec_path = "#{__dir__}/attic/sample_project/other/rspec"
    with_env('TM_RSPEC' => rspec_path) do
      assert_equal [rspec_path], RubyUtils.find_executable('rspec-special', 'TM_RSPEC')
    end
  end

  def test_use_env_var_with_missing_executable
    with_env('TM_NONEXISTING_EXECUTABLE' => "#{__dir__}/attic/sample_project/other/nonexisting") do
      assert_nil RubyUtils.find_executable('nonexisting', 'TM_NONEXISTING_EXECUTABLE')
    end
  end

  def test_find_binstub
    assert_equal %w(bin/rspec), RubyUtils.find_executable('rspec')
  end

  def test_find_in_gemfile
    assert_equal %w(bundle exec rubocop), RubyUtils.find_executable('rubocop')
  end

  def test_find_in_path
    # Of course `ls` is not a Ruby executable, but for this test this makes no difference
    assert_equal %w(ls), RubyUtils.find_executable('ls')
  end

  def test_missing_executable
    assert_nil RubyUtils.find_executable('nonexisting_executable')
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
      assert_nil RubyUtils.find_executable('rbenv_installed_shim')
    end
  end
end
