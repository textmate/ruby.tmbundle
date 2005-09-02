#!/usr/bin/ruby
#
# TM-Ruby v0.2, 13-08-2005.
# By Sune Foldager.
#
# v0.2 (13-08-2005): Exception backtrace with links implemented. Correctly handles threads and DATA.
# v0.1 (12-08-2005): Initial version.
#


# We need this for HTML escaping.
require 'cgi'
$KCODE = 'u'


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


# HTML escaping function.
def esc(str)
  CGI.escapeHTML(str)
end


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

    # Prepare STDOUT.
    class << STDOUT
      alias real_write write
      def write(thing)
        real_write(esc(thing.to_s))
      end
    end
    STDOUT.flush

    # Execute user code, and fix up STDOUT afterwards.
    load ARGV[0]
    class << STDOUT
      alias unreal_write write
      alias write real_write
    end

  # We had an error!
  rescue Exception => e

    # Fix up output.
    class << STDOUT
      alias unreal_write write
      alias write real_write
    end

    # Don't show backtrace if child simply called exit.
    # Also, end the block if we're not exiting 0.
    if e.instance_of?(SystemExit)
      puts '</pre></div>' if e.status != 0
      raise
    end
    
    # Exception header and message.
    puts '</pre></div><div id="exception_report">'
    print '<p id="exception"><strong>', esc(e.class.name), '</strong>: ', esc(e.message), "</p>\n"

    # Filter backtrace.
    bt = e.backtrace
    bt = bt[0...(bt.each_index {|i| break i if bt[i].index(__FILE__) == 0 })]

    # If there is anything, display it.
    if bt.size > 0
      puts '<blockquote><table border="0" cellspacing="0" cellpadding="0">'
      bt.each {|b|

        next unless b =~ /(.*?):(\d+)(?::in\s*`(.*?)')?/
        print '<tr><td><a class="near" title="in ', esc($1), '" href="txmt://open?url=file://'
        print esc($1), '&line=', esc($2), '">', ($3 ? "method #{esc($3)}" : '<em>at top level</em>'),
          '</a></td>'
        print '<td>in <strong>', esc(File.basename($1)), '</strong> at line ', esc($2), '</td></tr>'

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

