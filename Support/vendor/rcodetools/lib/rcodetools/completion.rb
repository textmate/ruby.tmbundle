require 'rcodetools/xmpfilter'
require 'enumerator'
# Common routines for XMPCompletionFilter/XMPDocFilter
module ProcessParticularLine
  def fill_literal!(expr)
    [ "\"", "'", "`" ].each do |q|
      expr.gsub!(/#{q}(.+)#{q}/){ '"' + "x"*$1.length + '"' }
    end
    expr.gsub!(/(%([wWqQxrs])?(\W))(.+?)\3/){
      percent = $2 == 'x' ? '%'+$3 : $1 # avoid executing shell command
      percent + "x"*$4.length + $3
    }
    [ %w[( )], %w[{ }], %w![ ]!, %w[< >] ].each do |b,e|
      rb, re = [b,e].map{ |x| Regexp.quote(x)}
      expr.gsub!(/(%([wWqQxrs])?(#{rb}))(.+)#{re}/){
        percent = $2 == 'x' ? '%'+$3 : $1 # avoid executing shell command
        percent + "x"*$4.length + e
      }
    end
  end

  module ExpressionExtension
    attr_accessor :eval_string
    attr_accessor :meth
  end
  OPERATOR_CHARS = '\|^&<>=~\+\-\*\/%\['
  def set_expr_and_postfix!(expr, column, &regexp)
    expr.extend ExpressionExtension

    @postfix = ""
    expr_orig = expr.clone
    column ||= expr.length
    last_char = expr[column-1]
    expr.replace expr[ regexp[column] ]
    debugprint "expr_orig=#{expr_orig}", "expr(sliced)=#{expr}"
    right_stripped = Regexp.last_match.post_match
    _handle_do_end right_stripped
    aref_or_aset = aref_or_aset? right_stripped, last_char
    debugprint "aref_or_aset=#{aref_or_aset.inspect}"
    set_last_word! expr, aref_or_aset
    fill_literal! expr_orig
    _handle_brackets expr_orig, expr
    expr << aref_or_aset if aref_or_aset
    _handle_keywords expr_orig, column
    debugprint "expr(processed)=#{expr}"
    expr
  end

  def _handle_do_end(right_stripped)
    right_stripped << "\n"
    n_do = right_stripped.scan(/[\s\)]do\s/).length
    n_end = right_stripped.scan(/\bend\b/).length
    @postfix = ";begin" * (n_do - n_end)
  end

  def _handle_brackets(expr_orig, expr)
    [ %w[{ }], %w[( )], %w![ ]! ].each do |left, right|
      n_left  = expr_orig.count(left)  - expr.count(left)
      n_right = expr_orig.count(right) - expr.count(right)
      n = n_left - n_right
      @postfix << ";#{left}" * n if n >= 0
    end
  end

  def _handle_keywords(expr_orig, column)
    %w[if unless while until for].each do |keyw|
      pos = expr_orig.index(/\b#{keyw}\b/)
      @postfix << ";begin" if pos and pos < column # if * xxx

      pos = expr_orig.index(/;\s*#{keyw}\b/)
      @postfix << ";begin" if pos and column < pos # * ; if xxx
    end
  end

  def aref_or_aset?(right_stripped, last_char)
    if last_char == ?[
      case right_stripped
      when /\]\s*=/: "[]="
      when /\]/:     "[]"
      end
    end
  end

  def set_last_word!(expr, aref_or_aset=nil)
    debugprint "expr(before set_last_word)=#{expr}"
    if aref_or_aset
      opchars = "" 
    else
      opchars = expr.slice!(/\s*[#{OPERATOR_CHARS}]+$/)
      debugprint "expr(strip opchars)=#{expr}"
    end
    
    expr.replace(if expr =~ /[\"\'\`]$/      # String operations
                   "''"
                 else
                   fill_literal! expr
                   phrase = current_phrase(expr)
                   if aref_or_aset
                     expr.eval_string = expr[0..-2]
                     expr.meth = aref_or_aset
                   elsif phrase.match( /^(.+)\.(.*)$/ )
                     expr.eval_string, expr.meth = $1, $2
                   elsif opchars != ''
                     expr
                   end
                   debugprint "expr.eval_string=#{expr.eval_string}", "expr.meth=#{expr.meth}"
                   phrase
                 end << (opchars || '')) # ` font-lock hack
    debugprint "expr(after set_last_word)=#{expr}"
  end

  def current_phrase(expr)
    paren_level = 0
    start = 0
    (expr.length-1).downto(0) do |i|
      c = expr[i,1]
      if c =~ /[\)\}\]]/
        paren_level += 1
        next
      end
      if paren_level > 0
        next if c =~ /[, ]/
      else
        break (start = i+1) if c =~ /[ ,\(\{\[]/
      end
      if c =~ /[\(\{\[]/
        paren_level -= 1
        break (start = i+1) if paren_level < 0
      end
    end
    expr[start..-1]
  end

  def add_BEGIN
    <<XXX
BEGIN {
class Object
  def method_missing(meth, *args, &block)
    # ignore NoMethodError
  end
end
}
XXX
  end

  class RuntimeDataError < RuntimeError; end
  class NewCodeError < Exception; end
  def runtime_data_with_class(code, lineno, column=nil)
    newcode = code.to_a.enum_with_index.map{|line, i|
      i+1==lineno ? prepare_line(line.chomp, column) : line
    }.join
    newcode << add_BEGIN if @ignore_NoMethodError
    debugprint "newcode", newcode, "-"*80
    stdout, stderr = execute(newcode)
    output = stderr.readlines
    debugprint "stdout", output, "-"*80
    output = output.reject{|x| /^-:[0-9]+: warning/.match(x)}
    runtime_data = extract_data(output)
    if exception = /^-:[0-9]+:.*/m.match(output.join)
      raise NewCodeError, exception[0].chomp
    end
    begin
      dat = runtime_data.results[1][0]
      [dat[0], dat[1..-1].to_s]
    rescue
      raise RuntimeDataError, runtime_data.inspect
    end
  end

  def runtime_data(code, lineno, column=nil)
    runtime_data_with_class(code, lineno, column)[1]
  end

end

# Nearly 100% accurate completion for any editors!!
#  by rubikitch <rubikitch@ruby-lang.org>
class XMPCompletionFilter < XMPFilter
  include ProcessParticularLine

  # String completion begins with this.
  attr :prefix

  def self.run(code, opts)
    new(opts).completion_code(code, opts[:lineno], opts[:column])
  end

  def prepare_line(expr, column)
    set_expr_and_postfix!(expr, column){|c| /^.{#{c}}/ }
    @prefix = expr
    case expr
    when /^\$\w+$/              # global variable
      __prepare_line 'global_variables'
    when /^@@\w+$/              # class variable
      __prepare_line 'Module === self ? class_variables : self.class.class_variables'
    when /^@\w+$/               # instance variable
      __prepare_line 'instance_variables'
    when /^([A-Z].*)::(.*)$/    # nested constants / class methods
      @prefix = $2
      __prepare_line "#$1.constants | #$1.methods(true)"
    when /^[A-Z]\w*$/           # normal constants
      __prepare_line 'Module.constants'
    when /^::(.+)::(.*)$/       # toplevel nested constants
      @prefix = $2
      __prepare_line "::#$1.constants | ::#$1.methods"
    when /^::(.*)/              # toplevel constant
      @prefix = $1
      __prepare_line 'Object.constants'
    when /^(:[^:.]*)$/          # symbol
      __prepare_line 'Symbol.all_symbols.map{|s| ":" + s.id2name}'
    when /\.([^.]*)$/           # method call
      @prefix = $1
      __prepare_line "(#{Regexp.last_match.pre_match}).methods(true)"
    else                        # bare words
      __prepare_line "methods | private_methods | local_variables | self.class.constants"
    end
  end

  def __prepare_line(all_completion_expr)
    v = "#{VAR}"
    idx = 1
    oneline_ize(<<EOC)
#{v} = (#{all_completion_expr}).grep(/^#{Regexp.quote(@prefix)}/)
$stderr.puts("#{MARKER}[#{idx}] => " + #{v}.class.to_s  + " " + #{v}.join(" ")) || #{v}
exit
EOC
  end

  # Array of completion candidates.
  def candidates(code, lineno, column=nil)
    methods = runtime_data(code, lineno, column) rescue ""
    methods.split.sort
  end

  # Completion code for editors.
  def completion_code(code, lineno, column=nil)
    candidates(code, lineno, column).join("\n")
  end
end

class XMPCompletionEmacsFilter < XMPCompletionFilter
  def completion_code(code, lineno, column=nil)
    elisp = "(progn\n"
    elisp <<  "(setq rct-method-completion-table '("
    begin
      candidates(code, lineno, column).each do |meth|
        elisp << format('("%s") ', meth)
      end
    rescue Exception => err
      return %Q[(error "#{err.message}")]
    end
    elisp << "))\n"
    elisp << %Q[(setq pattern "#{prefix}")\n]
    elisp << %Q[(try-completion pattern rct-method-completion-table nil)\n]
    elisp << ")"                # /progn
  end
end

class XMPCompletionEmacsIciclesFilter < XMPCompletionFilter
  def candidates(code, lineno, column=nil)
    klass, methods = runtime_data_with_class(code, lineno, column) rescue ["", ""]
    @klass = klass
    methods.split.sort
  end

  def completion_code(code, lineno, column=nil)
    elisp = "(progn\n"
    elisp <<  "(setq rct-method-completion-table '("
    begin
      candidates(code, lineno, column).each do |meth|
        elisp << format('("%s") ', meth)
      end
    rescue Exception => err
      return %Q[(error "#{err.message}")]
    end
    elisp << "))\n"
    elisp << %Q[(setq pattern "#{prefix}")\n]
    elisp << %Q[(setq klass "#{@klass}")\n]
    elisp << ")"                # /progn
  end
end

