# = Standard Heredocs ==========================================================

<<DOC
Interpolated Heredoc #{ x = 1 }
DOC

<<DOC.split("\n").map(&:join)
Interpolated Heredoc #{ x = 1 }
DOC

x = <<DOC
Interpolated Heredoc #{ x = 1 }
DOC

x = <<DOC.split("\n").map(&:join)
Interpolated Heredoc #{ x = 1 }
DOC

<<"DOC"
Interpolated Heredoc #{ x = 1 }
DOC

<<"DOC".split("\n").map(&:join)
Interpolated Heredoc #{ x = 1 }
DOC

x = <<"DOC"
Interpolated Heredoc #{ x = 1 }
DOC

x = <<"DOC".split("\n").map(&:join)
Interpolated Heredoc #{ x = 1 }
DOC

<<'DOC'
x = 1
Uninterpolated Heredoc #{ x = 1 }
DOC

<<'DOC'.split("\n").map(&:join)
Uninterpolated Heredoc #{ x = 1 }
DOC

x = <<'DOC'
Uninterpolated Heredoc #{ x = 1 }
DOC

x = <<'DOC'.split("\n").map(&:join)
Uninterpolated Heredoc #{ x = 1 }
DOC

<<-DOC
Interpolated Heredoc #{ x = 1 }
DOC

<<-DOC.split("\n").map(&:join)
Interpolated Heredoc #{ x = 1 }
DOC

x = <<-DOC
Interpolated Heredoc #{ x = 1 }
DOC

x = <<-DOC.split("\n").map(&:join)
Interpolated Heredoc #{ x = 1 }
DOC

<<-"DOC"
Interpolated Heredoc #{ x = 1 }
DOC

<<-"DOC".split("\n").map(&:join)
Interpolated Heredoc #{ x = 1 }
DOC

x = <<-"DOC"
Interpolated Heredoc #{ x = 1 }
  DOC

x = <<-"DOC".split("\n").map(&:join)
Interpolated Heredoc #{ x = 1 }
  DOC

<<-'DOC'
Uninterpolated Heredoc #{ x = 1 }
DOC

<<-'DOC'.split("\n").map(&:join)
Uninterpolated Heredoc #{ x = 1 }
DOC

x = <<-'DOC'
Uninterpolated Heredoc #{ x = 1 }
DOC

x = <<-'DOC'.split("\n").map(&:join)
Uninterpolated Heredoc #{ x = 1 }
DOC

# = Heredoc with backtics ======================================================

<<`SH`
ls *
SH

# = Heredoc with embeded language ==============================================

<<SQL
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<SQL.split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<SQL
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<SQL.split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<"SQL"
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<"SQL".split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<"SQL"
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<"SQL".split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<'SQL'
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<'SQL'.split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<'SQL'
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<'SQL'.split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<-SQL
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<-SQL.split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<-SQL
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<-SQL.split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<-"SQL"
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<-"SQL".split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<-"SQL"
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<-"SQL".split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<-'SQL'
SELECT * FROM products WHERE id = #{ "24" };
SQL

<<-'SQL'.split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<-'SQL'
SELECT * FROM products WHERE id = #{ "24" };
SQL

x = <<-'SQL'.split("\n").map(&:join)
SELECT * FROM products WHERE id = #{ "24" };
SQL

# Other

<<DOC

end not here DOC
DOC

p <<end
print me!
end

p <<-end
print me!
end

<<-DOC.test(:me)

end not here DOC
DOC

a = <<b
test
b

puts(<<-ONE, <<-TWO)
content for heredoc one
ONE
content for heredoc two
TWO

# Not Heredocs

<<-"DOC
test
DOC"

<<"DOC
test
DOC"

<<'DOC
test
DOC'

<<-'DOC
test
DOC'

a = "1"
b = "2"
a <<b
b
a << b
