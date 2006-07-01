STDOUT.sync = true
STDERR.sync = true

at_exit do
  if (e = $!) && !e.instance_of?(SystemExit)
    io = IO.for_fd(ENV['TM_ERROR_FD'].to_i)

    io.write "<div id='exception_report' class='framed'>\n"
    io.write "<p id='exception'><strong>#{e.class.name}:</strong> #{e.message.sub(/`(\w+)'/, '‘\1’')}</p>\n"

    io.write "<blockquote><table border='0' cellspacing='0' cellpadding='0'>\n"
    
    e.backtrace.each do |b|
      if b =~ /(.*?):(\d+)(?::in\s*`(.*?)')?/ then
        file, line, method = $1, $2, $3
        io.write "<tr><td><a class='near' href='txmt://open?line=#{line}'>"
        io.write(method ? "method #{method.gsub(/</, '&lt;').gsub(/&/, '&amp;')}" : ((e.kind_of? SyntaxError) ? '<em>error</em>' : '<em>at top level</em>'))
        io.write "</a></td>\n<td>in <strong>#{File.basename(file).gsub(/</, '&lt;').gsub(/&/, '&amp;')}</strong> at line #{line}</td></tr>\n"
      end
    end
    
    io.write "</table></blockquote></div>"
    io.flush

    exit!
  end
end
