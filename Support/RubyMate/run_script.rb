require "open3"
require 'cgi'

def esc(str)
  CGI.escapeHTML(str).gsub(/\n/, '<br>')
end

html = DATA.read
html.gsub!(/\$\{BUNDLE_SUPPORT\}/, "tm-file://#{ENV['TM_BUNDLE_SUPPORT'].gsub(/ /, '%20')}")
puts html

rd, wr = IO.pipe
ENV['TM_ERROR_FD'] = wr.to_i.to_s
stdin, stdout, stderr = Open3.popen3('ruby', '-rcatch_exception.rb', '-')
stdin.write STDIN.read
stdin.close
wr.close

descriptors = [ stdout, stderr, rd ]
descriptors.each { |fd| fd.fcntl(4, 4) } # F_SETFL, O_NONBLOCK
error = ""
until descriptors.empty?
  select(descriptors).shift.each do |io|
    str = io.read
    if str.to_s.empty? then
      descriptors.delete io
      io.close
    elsif io == stdout
      print esc(str)
    elsif io == stderr
      print "<span style='color: red'>#{esc str}</span>"
    else
      error += str
    end
  end
end

puts '</div></pre></div>'
puts error
puts '<div id="exception_report" class="framed">Program exited.</div>'
puts '</body></html>'

__END__
<html>
  <head>
    <title>RubyMate</title>
    <link rel="stylesheet" href="${BUNDLE_SUPPORT}/pastel.css" type="text/css">
  </head>
<body>
  <div id="script_output" class="framed">
  <pre><strong>RubyMate r${VERSION} running Ruby v${RUBY_VERSION}.</strong>
<strong>>>> ${SCRIPT_NAME}</strong>
<div id="actual_output" style="-khtml-line-break: after-white-space;">
