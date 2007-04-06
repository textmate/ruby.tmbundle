require "ui"

class TextMateSTDIN < IO
  def gets(sep = nil)
    TextMate::UI.request_string( :prompt  => "Script is Requesting Input:",
                           :button1 => "Send" ) + "\n"
  end
end

$TM_STDIN = TextMateSTDIN.new(STDIN.fileno)
STDIN.reopen($TM_STDIN)
def gets(sep = nil)
  $TM_STDIN.gets(sep)
end
