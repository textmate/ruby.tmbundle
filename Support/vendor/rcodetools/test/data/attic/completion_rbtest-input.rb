#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby
=begin test_bar
assert_equal "BAR", bar("bar")
=end
def bar(s)
  s.upca
end
