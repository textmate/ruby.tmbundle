require "#{ENV["TM_SUPPORT_PATH"]}/lib/scriptmate"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/escape"
require "cgi"


$SCRIPTMATE_VERSION = "$Revision$"

class RubyScript < UserScript

  @@execmatch = "ruby"
  @@execargs = ['-rcatch_exception', '-rstdin_dialog']

  def executable
    @arg0 || ENV['TM_RUBY'] || 'ruby'
  end

  def version_string
    res = "Ruby r" + %x{ #{executable} -e 'print RUBY_VERSION' }
    res + " (#{executable})"
  end
  
  def test_script?
    @path    =~ /(?:\b|_)(?:tc|ts|test)(?:\b|_)/ or
    @content =~ /\brequire\b.+(?:test\/unit|test_helper)/
  end

  def filter_args(args)
    if test_script?
      path_ary = @path.split("/")
      if index = path_ary.rindex("test")
        test_path = File.join(*path_ary[0..-2])
        lib_path  = File.join( *( path_ary[0..-2] +
                                  [".."] * (path_ary.length - index - 1) ) +
                                  ["lib"] )
        if File.exist? lib_path
          args.insert(1, "-I#{e_sh lib_path}:#{e_sh test_path}")
        end
      end
    end
    args
  end
end

class RubyMate < ScriptMate
  @@matename = "RubyMate" # eg. RubyMate, PyMate, PerlMate...
  @@langname = "Ruby" # eg. Python, Ruby, Perl...

  def filter_stdout(str)
    if @script.test_script? and str =~ /\A[.EF]+\Z/
      return htmlize(str).gsub(/[EF]+/, "<span style=\"color: red\">\\&</span>") +
            "<br style=\"display: none\"/>"
    else
      if @script.test_script?
        return ( str.map do |line|
          if line =~ /^(\s+)(\S.*?):(\d+)(?::in\s*`(.*?)')?/
            indent, file, line, method = $1, $2, $3, $4
            url, display_name = '', 'untitled document';
            unless file == "-"
              indent += " " if file.sub!(/^\[/, "")
              url = '&amp;url=file://' + e_url(file)
              display_name = File.basename(file)
            end
            "#{indent}<a class='near' href='txmt://open?line=#{line + url}'>" +
            (method ? "method #{CGI::escapeHTML method}" : '<em>at top level</em>') +
            "</a> in <strong>#{CGI::escapeHTML display_name}</strong> at line #{line}<br/>"
          elsif line =~ /([\w\_]+).*\[([\w\_\/\.]+)\:(\d+)\]/
            method, file, line = $1, $2, $3
            "<span><a style=\"color: blue;\" href=\"txmt://open?url=file://#{e_url(file)}&amp;line=#{line}\">#{method}</span>:#{line}<br/>"
          elsif line =~ /^\d+ tests, \d+ assertions, (\d+) failures, (\d+) errors/
            "<span style=\"color: #{$1 + $2 == "00" ? "green" : "red"}\">#{$&}</span><br/>"
          else
            htmlize(line)
          end
        end.join )
      else
        return htmlize(str)
      end
    end
  end
end

RubyMate.new(RubyScript.new).emit_html
