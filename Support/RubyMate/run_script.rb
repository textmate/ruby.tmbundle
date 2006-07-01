require 'open3'
require 'cgi'
require 'fcntl'

$RUBYMATE_VERSION = "$Revision: 3762 $"

def esc(str)
  CGI.escapeHTML(str).gsub(/\n/, '<br>')
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

	def run
		rd, wr = IO.pipe
		rd.fcntl(Fcntl::F_SETFD, 1)
		ENV['TM_ERROR_FD'] = wr.to_i.to_s
		stdin, stdout, stderr = Open3.popen3(@arg0 || 'ruby', '-rcatch_exception.rb', '-rstdin_dialog.rb', @path, *Array(@args))
		Thread.new { stdin.write @content; stdin.close }
		wr.close

		[ stdout, stderr, rd ]
	end

	attr_reader :display_name
end

error = ""
STDOUT.sync = true

script = UserScript.new
map = {
	'SCRIPT_NAME'    		=> script.display_name,
	'RUBY_VERSION'   		=> script.ruby_version_string,
	'RUBYMATE_VERSION'	=> $RUBYMATE_VERSION[/\d+/],
	'BUNDLE_SUPPORT' 		=> "tm-file://#{ENV['TM_BUNDLE_SUPPORT'].gsub(/ /, '%20')}",
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
      print esc(str)
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
<div id="actual_output" style="-khtml-line-break: after-white-space;">
