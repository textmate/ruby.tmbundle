require "#{ENV["TM_SUPPORT_PATH"]}/lib/escape"

require 'open3'
require 'cgi'
require 'fcntl'

$RUBYMATE_VERSION = "$Revision$"

def esc(str)
  str = CGI.escapeHTML(str).gsub(/\n/, '<br/>')
  str.reverse.gsub(/ (?= |$)/, ';psbn&').reverse
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
  'TM_SUPPORT_PATH'   => ENV['TM_SUPPORT_PATH'],
  'TM_HTML_LANG'      => ENV['TM_MODE'],
  'TM_HTML_TITLE'     => 'RubyMate',
  'TM_EXTRA_HEAD'     => '',
  'TM_CSS'            => `cat "${TM_SUPPORT_PATH}/css/webpreview.css" | sed "s|TM_SUPPORT_PATH|${TM_SUPPORT_PATH}|"`,
}
# $TM_SUPPORT_PATH = ENV['TM_SUPPORT_PATH']
# $TM_HTML_LANG =    ENV['TM_MODE']
# $TM_HTML_TITLE =   'RubyMate'
# $TM_EXTRA_HEAD =   ''
# $TM_CSS =          `cat "${TM_SUPPORT_PATH}/css/webview.css" | sed "s|TM_SUPPORT_PATH|${TM_SUPPORT_PATH}|"`


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
puts '</div>'
puts '</body></html>'

__END__
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-type" content="text/html; charset=utf-8" />
   <title>RubyMate — ${SCRIPT_NAME}</title>
	<style type="text/css" media="screen">
		${TM_CSS}
	</style>
	<script src="file://${TM_SUPPORT_PATH}/script/default.js" type="text/javascript" language="javascript" charset="utf-8"></script>
	<script src="file://${TM_SUPPORT_PATH}/script/webpreview.js" type="text/javascript" language="javascript" charset="utf-8"></script>
	${TM_EXTRA_HEAD}
</head>
<body id="tm_webpreview_body">
	<div id="tm_webpreview_header">
		<p class="headline">${TM_HTML_TITLE}</p>
		<p class="type">${TM_HTML_LANG}</p>
		<img class="teaser" src="file://${TM_SUPPORT_PATH}/images/gear2.png" alt="teaser" />
		<div id="theme_switcher">
			<form action="#" onsubmit="return false;">
				Theme: 
				<select onchange="selectTheme(this.value);" id="theme_selector">
					<option>bright</option>
					<option>dark</option>
					<option value="default">no colors</option>
				</select>
			</form>
		</div>
	</div>
	<div id="tm_webpreview_content" class="bright">
	<div class="rubymate">
		
		<div><!-- first box containing version info and script output -->
			<pre><strong>RubyMate r${RUBYMATE_VERSION} running Ruby v${RUBY_VERSION}</strong>
<strong>>>> ${SCRIPT_NAME}</strong>

<div style="white-space: normal; -khtml-nbsp-mode: space; -khtml-line-break: after-white-space;"> <!-- Script output -->