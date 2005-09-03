#!/usr/bin/ruby
#
# RubyMate v1.0, 03-09-2005.
# By Sune Foldager.
#
# v1.0 (03-09-2005): Proper HTML encoding and exit report. General code cleanup. Renamed.
# v0.2 (13-08-2005): Exception backtrace with links implemented. Correctly handles threads and DATA.
# v0.1 (12-08-2005): Initial version.
#
# TODO:
# • Co-ordinate with PyMate.
# • Perhabs indicate errors in foreign files differently.
#


# We need this for HTML escaping.
require 'cgi'
$KCODE = 'u'


# Input override.
class MyStdIn < IO

  def getLine(info)
    s = `\"#{ENV['TM_SUPPORT_PATH']}/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog\" inputbox --title Input --informative-text '#{info}' --button1 Ok --button2 '^D' --button3 'Abort'`
    case (a = s.split)[0].to_i
    when 1: a[1] + "\n" if a[1]
    when 2: nil
    when 3: abort
    end
  end

  def gets(sep = nil)
    getLine('Line input.')
  end

end
$myIn = MyStdIn.new(STDIN.fileno)
STDIN.reopen($myIn)
def gets(sep = nil)
  $myIn.gets(sep)
end


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
<pre><strong>RubyMate v1.0 running Ruby v#{RUBY_VERSION}.</strong>
<strong>&gt;&gt;&gt #{ARGV[0]}</strong>

EOF


# Fork in preparation for user code.
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
        real_write(esc(thing.to_s).gsub("\n", '<br />'))
      end
    end
    STDOUT.flush
    STDOUT.sync = true

    # Execute user code, and fix up STDOUT afterwards.
    load ARGV[0]
    STDOUT.sync = false
    class << STDOUT
      alias unreal_write write
      alias write real_write
    end
    puts '</pre></div>'

  # We had an error!
  rescue Exception => e

    # Fix up STDOUT.
    STDOUT.sync = false
    class << STDOUT
      alias unreal_write write
      alias write real_write
    end
    puts '</pre></div>'

    # If the user code simply called 'exit', don't treat it as an error.
    exit(e.status) if e.instance_of?(SystemExit)

    # Exception header and message.
    puts '<div id="exception_report">'
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

    # This magic value indicates an exception to the parent process.
    exit 0xff

  end
end


# Wait for user threads to complete and create an exit report, if needed.
Process.wait
if (code = $?.exitstatus) != 0xff
  puts '<div id="exception_report">'
  print 'Program exited ', (code == 0) ? 'normally.' : "with return code #{code}."
  puts '</div>'
end


# Footer.
print <<EOF
</body>
</html>
EOF

