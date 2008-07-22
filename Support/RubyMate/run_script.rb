require ENV["TM_SUPPORT_PATH"] + "/lib/tm/executor"
require ENV["TM_SUPPORT_PATH"] + "/lib/tm/save_current_document"
require 'pathname'

TextMate.save_current_document

is_test_script = ENV["TM_FILEPATH"] =~ /(?:\b|_)(?:tc|ts|test)(?:\b|_)/ or
  File.read(ENV["TM_FILEPATH"]) =~ /\brequire\b.+(?:test\/unit|test_helper)/

cmd = [ENV['TM_RUBY'] || 'ruby', '-rcatch_exception']

if is_test_script and not ENV['TM_FILE_IS_UNTITLED']
  path_ary = (ENV['TM_ORIG_FILEPATH'] || ENV['TM_FILEPATH']).split("/")
  if index = path_ary.rindex("test")
    test_path = File.join(*path_ary[0..-2])
    lib_path  = File.join( *( path_ary[0..-2] +
                              [".."] * (path_ary.length - index - 1) ) +
                              ["lib"] )
    if File.exist? lib_path
      cmd << "-I#{lib_path}:#{test_path}"
    end
  end
end

cmd << ENV["TM_FILEPATH"]

TextMate::Executor.run(cmd, :version_args => ["--version"]) do |str, type|
  case type
  when :out
    if is_test_script and str =~ /\A[.EF]+\Z/
      htmlize(str).gsub(/[EF]+/, "<span style=\"color: red\">\\&</span>") +
            "<br style=\"display: none\"/>"
    elsif is_test_script
      out = str.map do |line|
        if line =~ /^(\s+)(\S.*?):(\d+)(?::in\s*`(.*?)')?/
          indent, file, line, method = $1, $2, $3, $4
          url, display_name = '', 'untitled document';
          unless file == "-"
            indent += " " if file.sub!(/^\[/, "")
            file = Pathname.new(file).realpath.to_s
            url = '&amp;url=file://' + e_url(file)
            display_name = File.basename(file)
          end
          "#{indent}<a class='near' href='txmt://open?line=#{line + url}'>" +
          (method ? "method #{CGI::escapeHTML method}" : '<em>at top level</em>') +
          "</a> in <strong>#{CGI::escapeHTML display_name}</strong> at line #{line}<br/>"
        elsif line =~ /(\[[^\]]+\]\([^)]+\))\s+\[([\w\_\/\.]+)\:(\d+)\]/
          spec, file, line = $1, $2, $3, $4
          file = Pathname.new(file).realpath.to_s
          "<span><a style=\"color: blue;\" href=\"txmt://open?url=file://#{e_url(file)}&amp;line=#{line}\">#{spec}</span>:#{line}<br/>"
        elsif line =~ /([\w\_]+).*\[([\w\_\/\.]+)\:(\d+)\]/
          method, file, line = $1, $2, $3
          file = Pathname.new(file).realpath.to_s
          "<span><a style=\"color: blue;\" href=\"txmt://open?url=file://#{e_url(file)}&amp;line=#{line}\">#{method}</span>:#{line}<br/>"
        elsif line =~ /^\d+ tests, \d+ assertions, (\d+) failures, (\d+) errors\b.*/
          "<span style=\"color: #{$1 + $2 == "00" ? "green" : "red"}\">#{$&}</span><br/>"
        else
          htmlize(line)
        end
      end
      out.join()
    else
      htmlize(str)
    end    
  when :err
    "<span style=\"color: red\">#{htmlize str}</span>"
  end
end