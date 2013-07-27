#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby -wKU

minimize = ENV["TM_MINIMIZE_PARENS"].to_s =~ /\byes\b/i

case ARGV.shift.to_s =~ /\bend\b/i ? :end : :start
when :start
  print(minimize ? " " : "(")
when :end
  print ")" unless minimize
end
