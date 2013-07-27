#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby
# encoding: utf-8

# be smart, dont print something if we already have..
$write_count = 0
def STDOUT.write(what)
   $write_count += 1
   super(what)
end

# execure the code
begin
  # insert a space if input was a selection, if it was a line insert \n
  print(ENV['TM_SELECTED_TEXT'] ? " " : "\n")
  r = eval(STDIN.read)
rescue Object
  r = $!.class.to_s
end

# try to_s, if it doesnt work use inspect
# Array and Hash are shown via inspect because they look better with formating
# do this just if the script did not print anything itself
if $write_count == 1
  print( (r.class != Hash and r.class != Array and not r.nil? and r.respond_to? :to_s) ? r.to_s : r.inspect )
  print( "\n" ) unless ENV.has_key?('TM_SELECTED_TEXT')
end
