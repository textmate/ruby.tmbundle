#!/usr/bin/ruby
#
# RubyMate v1.2, 2005-09-26.
# By Sune Foldager.
#
# v1.2    (2005-09-26): Added link to toggle wrapping for script output
# v1.1    (2005-09-08): Now links for syntax errors work as well.
# v1.0    (2005-09-03): Proper HTML encoding and exit report. General code cleanup. Renamed.
# v0.2    (2005-08-13): Exception backtrace implemented. Correctly handles threads and DATA.
# v0.1    (2005-08-12): Initial version.
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
    case (a = s.split("\n"))[0].to_i
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
print <<-EOF
<html>
<head>
<title>Ruby TextMate Runtime</title>
<style type="text/css">
EOF
dump_file(myDir + 'pastel.css')
print <<-HTML
</style>
<script>
function toggle_ws () {
	// change style sheet property
	var style = document.getElementById('actual_output').style;
	var switchToPre = style.whiteSpace == 'normal';
	style.whiteSpace = switchToPre ? 'pre' : 'normal';

	// toggle link text
	var elm = document.getElementById('reflow_link');
	elm.innerHTML = switchToPre ? 'Wrap output' : 'Unwrap output';

	// store new value in defaults
	TextMate.system("defaults write org.cyanite.rubymate wrapOutput " + (switchToPre ? "0" : "1"), null);
}
</script>
</head>
<body #{'onLoad="javascript:toggle_ws()"' if(%x{defaults read org.cyanite.rubymate wrapOutput 2>/dev/null} == "1\n")}>
<div id="script_output" class="framed">
<div style="float: right;"><a href="javascript:toggle_ws()" id="reflow_link">Wrap output</a></div>
<pre><strong>RubyMate v1.2 running Ruby v#{RUBY_VERSION}.</strong>
<strong>&gt;&gt;&gt #{ARGV[0].sub(ENV['HOME'], '~')}</strong>
<div id="actual_output">
HTML


# Fork in preparation for user code.
Process.fork do
  begin

    # Prepare STDOUT.
    class << STDOUT
      alias real_write write
      def write(thing)
        real_write(esc(thing.to_s).gsub("\n", '<br />'))
      end
    end
    STDOUT.flush
    STDOUT.sync = true

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

    # Execute user code, and fix up STDOUT afterwards.
    load ARGV[0]
    STDOUT.sync = false
    class << STDOUT
      alias unreal_write write
      alias write real_write
    end
    puts '</div></pre></div>'

  # We had an error!
  rescue Exception => e

    # Fix up STDOUT.
    STDOUT.sync = false
    class << STDOUT
      alias unreal_write write
      alias write real_write
    end
    puts '</div></pre></div>'

    # If the user code simply called 'exit', don't treat it as an error.
    exit(e.status) if e.instance_of?(SystemExit)

    # Syntax errors need special treatment also.
    if e.kind_of? SyntaxError

      # Construct a backtrace entry, and set message to empty.
      bt = [e.message]
      msg = ''

    else

      # Filter backtrace and grab exception message.
      bt = e.backtrace
      bt = bt[0...(bt.each_index {|i| break i if bt[i].index(__FILE__) == 0 })]
      msg = e.message

    end

    # Exception header and message.
    puts '<div id="exception_report" class="framed">'
    print '<p id="exception"><strong>', esc(e.class.name), '</strong>: ', esc(msg), "</p>\n"

    # If there is anything, display it.
    if bt.size > 0
      puts '<blockquote><table border="0" cellspacing="0" cellpadding="0">'
      bt.each {|b|

        next unless b =~ /(.*?):(\d+)(?::in\s*`(.*?)')?/
        print '<tr><td><a class="near" title="in ', esc($1), '" href="txmt://open?url=file://'
        print esc($1), '&line=', esc($2), '">', ($3 ? "method #{esc($3)}" :
          ((e.kind_of? SyntaxError) ? '<em>error</em>' : '<em>at top level</em>')), '</a></td>'
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
  puts '<div id="exception_report" class="framed">'
  print 'Program exited ', (code == 0) ? 'normally.' : "with return code #{code}."
  puts '</div>'
end


# Footer.
print <<-EOF
</body>
</html>
EOF

