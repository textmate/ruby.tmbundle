#!/usr/bin/ruby
#
# TM-Ruby v0.2, 13-08-2005.
# By Sune Foldager.
#
# v0.2 (13-08-2005): Exception backtrace with links implemented. Correctly handles threads and DATA.
# v0.1 (12-08-2005): Initial version.
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
<pre><strong>TM-Ruby v0.2 running Ruby v#{RUBY_VERSION}.</strong>
<strong>&gt;&gt;&gt #{ARGV[0]}</strong>

EOF


# Fork in preparation for user code.
STDOUT.flush
Process.fork do
  begin

    # Set up DATA environment, if appropriate.
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

    # Execute user code.
    load ARGV[0]

  # We had an error!
  rescue Exception => e
    if e.instance_of?(SystemExit)
      # Don't show backtrace if child simply called `exit`
      # also, end the block if we're not exiting 0
      puts '</pre></div>' if e.status != 0
      raise
    end
    
    # Exception header and message.
    puts '</pre></div><div id="exception_report">'
    print '<p id="exception"><strong>', e.class.name, '</strong>: ', e.message, "</p>\n"

    # Filter backtrace.
    bt = e.backtrace
    bt = bt[0...(bt.each_index {|i| break i if bt[i].index(__FILE__) == 0 })]

    # If there is anything, display it.
    if bt.size > 0
      puts '<blockquote><table border="0" cellspacing="0" cellpadding="0">'
      bt.each {|b|

        # FIXME: Entity encode stuff.
        next unless b =~ /(.*?):(\d+)(?::in\s*`(.*?)')?/
        print '<tr><td><a class="near" title="in ', $1, '" href="txmt://open?url=file://'
        print $1, '&line=', $2, '">', ($3 ? "method #{$3}" : '<em>at top level</em>'), '</a></td>'
        print '<td>in <strong>', File.basename($1), '</strong> at line ', $2, '</td></tr>'

      }
      puts '</table></blockquote>'
    end

    puts '</div>'
    
    # The non-zero exit signals the parent not to close the block, that we're handling it
    exit 1

  end
end


# Wait for user threads to complete, and flush output.
Process.wait
STDOUT.flush
# close the HTML block, unless the child exited non-zero
puts '</pre></div>' if $?.exitstatus == 0


# Footer.
print <<EOF
</body>
</html>
EOF

