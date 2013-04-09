# encoding: utf-8

STDOUT.sync = true
STDERR.sync = true

require 'pathname'
require "cgi"

at_exit do
  if (e = $!) && !e.instance_of?(SystemExit)
    require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
    io = IO.for_fd(ENV['TM_ERROR_FD'].to_i)

    io.write "<div id='exception_report' class='framed'>\n"
    io.write "<p id='exception'><strong>#{e.class.name}:</strong> #{CGI.escapeHTML e.message.sub(/`(\w+)'/, '‘\1’').sub(/ -- /, ' — ')}</p>\n"

    io.write "<blockquote><table border='0' cellspacing='4' cellpadding='0'>\n"

    dirs = [ '.', ENV['TM_PROJECT_DIRECTORY'], ENV['TM_DIRECTORY'] ]
    e.backtrace.each do |b|
      if b =~ /(.*?):(\d+)(?::in\s*`(.*?)')?/ then
        file, line, method = $1, $2, $3
        url, display_name = '', file

        path = dirs.map{ |dir| File.expand_path(file, dir) }.find{ |filename| File.file? filename }
        unless path.nil?
          url, display_name = '&amp;url=file://' + e_url(path), File.basename(path)
        end

        io << "<tr><td><a class='near' href='txmt://open?line=#{line + url}'>"
        io << (method ? "method #{CGI::escapeHTML method}" : '<em>at top level</em>')
        io << "</a></td>\n<td>in <strong>#{CGI::escapeHTML display_name}</strong> at line #{line}</td></tr>\n"
      end
    end
    
    io.write "</table></blockquote></div>"
    io.flush

    exit!
  end
end
