require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "io/wait"

class TextMateSTDIN < IO
  def gets(*args)
    return super if ready?
    TextMate::UI.request_string( :prompt  => "Script is Requesting Input:",
                                 :button1 => "Send" ) + "\n"
  end
end

$TM_STDIN = TextMateSTDIN.new(STDIN.fileno)
STDIN.reopen($TM_STDIN)
def gets(*args)
  $TM_STDIN.gets(*args)
end
