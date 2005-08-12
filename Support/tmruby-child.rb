#!/usr/bin/ruby

# Load and execute the user code.
begin
  load ARGV[0]
rescue Exception => e

  # For now.
  puts e.message
  puts e.inspect.sub('<', '&lt;').sub('>', '&gt;')

  # Filter backtrace.
  bt = e.backtrace
  bt = bt[0...(bt.each_index {|i| break i if bt[i].index(__FILE__) == 0 })]
  puts bt.join("\n")

end