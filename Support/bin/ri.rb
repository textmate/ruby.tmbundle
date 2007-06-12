#!/usr/bin/env ruby -w

require "#{ENV["TM_SUPPORT_PATH"]}/lib/exit_codes"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/escape"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/web_preview"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/ui"

LINKED_RI = "#{ENV["TM_BUNDLE_SUPPORT"]}/bin/linked_ri.rb"

# first escape for use in the shell, then escape for use in a JS string
def e_js_sh(str)
(e_sh str).gsub("\\", "\\\\\\\\")
end

my_term = nil

def ri(term)
documentation = `#{e_sh LINKED_RI} '#{term}' 2>&1` \
                rescue "<h1>ri Command Error.</h1>"
if documentation =~ /Nothing known about /
  TextMate.exit_show_tool_tip(documentation)
elsif documentation.sub!(/\A>>\s*/, "")
  choices = documentation.split
  choice  = TextMate::UI.menu(choices)
  exit if choice.nil?
  ri(choices[choice])
else
  documentation
end
end

term = STDIN.read.strip
TextMate.exit_show_tool_tip("Please select a term to look up.") if term.empty?

documentation = ri(term)

html_header("Documentation for ‘#{term}’", "RDoc", <<-HTML)
<script type="text/javascript" charset="utf-8">
  function ri (arg, _history) {
  TextMate.isBusy = true;
  var res = TextMate.system("RUBYLIB=#{e_js_sh "#{ENV['TM_SUPPORT_PATH']}/lib"} #{e_js_sh LINKED_RI} 2>&1 '" + arg + "'", null).outputString;
  document.getElementById("actual_output").innerHTML = res;
  TextMate.isBusy = false;
  if(!_history)
  {
    var history = document.getElementById('search_history');
    var new_option = document.createElement('option');
    new_option.setAttribute('value', arg);
    new_option.appendChild(document.createTextNode(arg));
    history.appendChild(new_option);
  }
}
</script>
HTML
puts <<-HTML
<select id="search_history" style="float: right;">
  <option value="#{term}" selected="selected">#{term}</option>
</select>
<script type="text/javascript" charset="utf-8">
  document.getElementById('search_history').addEventListener('change', function(e) {
    ri(document.getElementById('search_history').value, true);
  }, false);
</script>
<div id="actual_output">#{documentation}</div>
HTML
html_footer
TextMate.exit_show_html