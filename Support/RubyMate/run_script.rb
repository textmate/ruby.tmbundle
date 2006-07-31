require "#{ENV["TM_SUPPORT_PATH"]}/lib/escape"

require 'open3'
require 'cgi'
require 'fcntl'

$RUBYMATE_VERSION = "$Revision$"

def esc(str)
  CGI.escapeHTML(str).gsub(/\n/, '<br/>')
end

class UserScript
  def initialize
    @content = STDIN.read
    @arg0 = $1       if @content =~ /\A#!([^ \n]+\/ruby\b)/
    @args = $1.split if @content =~ /\A#!.*?\bruby[ \t]+(.*)$/

    if ENV.has_key? 'TM_FILEPATH' then
      @path = ENV['TM_FILEPATH']
      @display_name = File.basename(@path)
      # save file
      open(@path, "w") { |io| io.write @content }
    else
      @path = '-'
      @display_name = 'untitled'
    end
  end

  def ruby_version_string
    # ideally we should get this back from the script we execute
    res = %x{ #{@arg0 || 'ruby'} -e 'print RUBY_VERSION' }
    res + " (#{@arg0 || `which ruby`.chomp})"
  end
  
  def test_script?
    @path    =~ /(?:\b|_)(?:tc|ts|test)(?:\b|_)/ or
    @content =~ /\brequire\b.+(?:test\/unit|test_helper)/
  end

  def run
    rd, wr = IO.pipe
    rd.fcntl(Fcntl::F_SETFD, 1)
    ENV['TM_ERROR_FD'] = wr.to_i.to_s
    args = add_test_path( *[ @arg0 || 'ruby',
                             '-rcatch_exception', '-rstdin_dialog',
                             Array(@args), @path ].flatten )
    stdin, stdout, stderr = Open3.popen3(*args)
    Thread.new { stdin.write @content; stdin.close } unless ENV.has_key? 'TM_FILEPATH'
    wr.close

    [ stdout, stderr, rd ]
  end

  attr_reader :display_name, :path
  
  private
  
  def add_test_path(*args)
    if test_script?
      path_ary = @path.split("/")
      if index = path_ary.rindex("test")
        test_path = File.join(*path_ary[0..-2])
        lib_path  = File.join( *( path_ary[0..-2] +
                                  [".."] * (path_ary.length - index - 1) ) +
                                  ["lib"] )
        if File.exist? lib_path
          args.insert(1, "-I#{lib_path}:#{test_path}")
        end
      end
    end
    args
  end
end

error = ""
STDOUT.sync = true

script = UserScript.new
map = {
  'SCRIPT_NAME'       => script.display_name,
  'RUBY_VERSION'      => script.ruby_version_string,
  'RUBYMATE_VERSION'  => $RUBYMATE_VERSION[/\d+/],
  'BUNDLE_SUPPORT'    => "tm-file://#{ENV['TM_BUNDLE_SUPPORT'].gsub(/ /, '%20')}",
}
puts DATA.read.gsub(/\$\{([^}]+)\}/) { |m| map[$1] }

stdout, stderr, stack_dump = script.run
descriptors = [ stdout, stderr, stack_dump ]

descriptors.each { |fd| fd.fcntl(Fcntl::F_SETFL, Fcntl::O_NONBLOCK) }
until descriptors.empty?
  select(descriptors).shift.each do |io|
    str = io.read
    if str.to_s.empty? then
      descriptors.delete io
      io.close
    elsif io == stdout then
      if script.test_script? and str =~ /\A[.EF]+\Z/
        print esc(str).gsub(/[EF]+/, "<span style=\"color: red\">\\&</span>") +
              "<br style=\"display: none\"/>"
      else
        if script.test_script?
          print( str.map do |line|
            if line =~ /^(\s+)(\S.*?):(\d+)(?::in\s*`(.*?)')?/
              indent, file, line, method = $1, $2, $3, $4

              url, display_name = '', 'untitled document';
              unless file == "-"
                indent += " " if file.sub!(/^\[/, "")
                url = '&url=file://' + e_url(file)
                display_name = File.basename(file)
              end

              "#{indent}<a class='near' href='txmt://open?line=#{line + url}'>" +
              (method ? "method #{CGI::escapeHTML method}" : '<em>at top level</em>') +
              "</a> in <strong>#{CGI::escapeHTML display_name}</strong> at line #{line}<br/>"
            elsif line =~ /([\w\_]+).*\[([\w\_\/\.]+)\:(\d+)\]/
              method, file, line = $1, $2, $3
              "<span><a style=\"color: blue;\" href=\"txmt://open?url=file://#{e_url(file)}&line=#{line}\">#{method}</span>:#{line}<br/>"
            elsif line =~ /^\d+ tests, \d+ assertions, (\d+) failures, (\d+) errors/
              "<span style=\"color: #{$1 + $2 == "00" ? "green" : "red"}\">#{$&}</span><br/>"
            else
              esc(line)
            end
          end.join )
	      else
	        print esc(str)
        end
      end
    elsif io == stderr then
      print "<span style='color: red'>#{esc str}</span>"
    elsif io == stack_dump then
      error << str
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
    <title>RubyMate — ${SCRIPT_NAME}</title>
    <link rel="stylesheet" href="${BUNDLE_SUPPORT}/pastel.css" type="text/css">
  </head>
<body>
  <div id="script_output" class="framed">
  <pre><strong>RubyMate r${RUBYMATE_VERSION} running Ruby v${RUBY_VERSION}</strong>
<strong>>>> ${SCRIPT_NAME}</strong>
<div id="actual_output" style="word-wrap: break-word;">
