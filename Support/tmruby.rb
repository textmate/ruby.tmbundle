#!/usr/bin/ruby
#
# TM-Ruby v0.1, 12-08-2005.
# By Sune Foldager.
#


# Input override.
class MyStdIn

  def getLine(info)
    s = `\"#{ENV['TM_SUPPORT_PATH']}/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog\" inputbox --title Input --informative-text '#{info}' --button1 Ok --button2 '^D' --button3 'Abort'`
    case (a = s.split)[0].to_i
    when 1: a[1] + "\n" if a[1]
    when 2: nil
    when 3: nil # <- for now.
    end
  end

  def gets(sep = nil)
    getLine('Line input.')
  end

end
$stdin = MyStdIn.new


# Helper to dump files to stdout.
def dump_file(name)
  File.open(name) {|f| f.each_line {|l| print l} }
end



# Prepare some values for later.
myFile = __FILE__
myDir = File.dirname(myFile) + '/'


# Headers...

print <<EOF
<html>
<head>
<title>Ruby TextMate Runtime</title>
<style type="text/css">
EOF

dump_file(myDir + 'pastel.css')

print <<EOF
</style>
</head>
<body>
<div id="script_output">
<pre><strong>TM-Ruby v0.1 running Ruby v#{RUBY_VERSION}.</strong>
<strong>&gt;&gt;&gt #{ARGV[0]}</strong>

EOF


# Load and execute the user code.
STDERR.reopen(STDOUT)
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


# Footer.
print <<EOF
</pre>
</div>
</body>
</html>
EOF

