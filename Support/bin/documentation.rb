#!/usr/bin/env ruby -w

require "#{ENV["TM_SUPPORT_PATH"]}/lib/exit_codes"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/escape"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/web_preview"

# first escape for use in the shell, then escape for use in a JS string
def e_js_sh(str)
  (e_sh str).gsub("\\", "\\\\\\\\")
end

term = STDIN.read.strip
TextMate.exit_show_tool_tip("Please select a term to look up.") if term.empty?

linked_ri     = "#{ENV["TM_BUNDLE_SUPPORT"]}/bin/linked_ri.rb"
documentation = `#{e_sh linked_ri} 2>&1 #{e_sh term}` rescue "<h1>ri Command Error.</h1>"
TextMate.exit_show_tool_tip(documentation) if documentation =~ /Nothing known about /

html_header("Documentation for ‘#{term}’", "RDoc", <<-HTML)
  <script type="text/javascript" charset="utf-8">
    function ri (arg) {
			var res = TextMate.system("RUBYLIB=#{e_js_sh "#{ENV['TM_SUPPORT_PATH']}/lib"} #{e_js_sh linked_ri} 2>&1 '" + arg + "'", null).outputString;
			document.getElementById("actual_output").innerHTML = res;
			window.location.hash = "actual_output";
		}
  </script>
HTML
puts <<-HTML
  <pre><div id="actual_output">#{documentation}</div></pre>
HTML
html_footer
TextMate.exit_show_html