#!/usr/bin/ruby

# Load and execute the user code.
begin
  data = File.new(ARGV[0])
  begin
    loop do
      if data.readline.chomp == "__END__"
        DATA = data
        break
      end
    end
  rescue EOFError
  end
  load ARGV[0]
rescue Exception => e
  raise if e.instance_of?(SystemExit)

  # For now.
  puts e.message
  puts e.inspect.sub('<', '&lt;').sub('>', '&gt;')

  # Filter backtrace.
  bt = e.backtrace
  bt = bt[0...(bt.each_index {|i| break i if bt[i].index(__FILE__) == 0 })]
  puts bt.join("\n")

end