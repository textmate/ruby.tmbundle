# -------------------------------------------
# Testarea for classes
# -------------------------------------------

# singleline
class F; end
class F end
(class F end)


class Foo; @@a = 1; end
class Foo::Bar < M::Baz; @@a = 1; end
class A class B end end
class A; class B; end; end

# multiline
class Foo
  @@var = 1
  
  $class = "myclass"
  @@module = "mymodule"
  class_name = "class_name"
  module_name = "module_name"
  self.class.methods
  self::class::methods

  def module
    nil
  end

  def class
    nil
  end
end

Foo.new.module
Foo.new::module
Foo.new.class
Foo.new::class

# -------------------------------------------
# Testarea for classes
# -------------------------------------------

# singleline
module Mod; @a = 1; end
module ModOne::ModTwo; @a = 1; end
module M module N end end
module M; module N end end
(module M module N end end)

# multiline
module Bar
  $class = "myclass"
  @module = "mymodule"
  class_name = "class_name"
  module_name = "module_name"
  class Foo
    @@var = 1
  end
end

# -------------------------------------------
# Testarea for method without arguments
# -------------------------------------------

# singleline
def a; puts "a"; end
def b; def c; puts "c"; end; end
def d; puts self.end; end
def method; hello, world = [1,2] end # test comment

# multiline
def e
  puts "e"
end

def f
  def g
    puts "g"
  end
end

def h
  puts self.end
end

def i
  end?       # self.end?
  end!       # self.end!
end

def method # test comment
  hello, world = [1,2]
end

# -------------------------------------------
# Testarea for method with arguments
# -------------------------------------------

# singleline
def a(arg); puts arg; end
def b; def c(arg); puts arg; end; end
def d(arg); puts arg.end; end
def method_with_parentheses(*a, **b, &c) hello, world = [1,2] end # test comment
def method_with_parentheses(a, b, c = [foo,bar,baz]) hello, world = [1,2] end # test comment

# multiline
def e(arg)
  puts arg
end

def f
  def g(arg)
    puts arg
  end
end

def h(arg)
  puts arg.end
end

def i(arg)
  end?       # self.end?
  end!       # self.end!
end

def method_with_parentheses(a, b, c = [foo,bar,baz]) # test comment
  hello, world = [1,2]
end

def method_with_parentheses(a, b = "hello", c = ["foo", "bar"], d = (2 + 2) * 2, e = {}) # test comment
  hello, world = [1,2]
  do_something1
  do_something2
end

def method_with_parentheses(a,
                            b = hello, # test comment
                            c = ["foo", bar, :baz],
                            d = (2 + 2) * 2,
                            e = {})
  hello, world = [1,2]
  do_something1
  do_something2
end

# -------------------------------------------
# Testarea for method with arguments without parenthesis
# -------------------------------------------

# singleline
def a arg; puts arg; end
def b; def c arg; puts arg; end; end
def d arg; puts arg.end; end
def method_without_parentheses a, b, c = [foo,bar,baz]; hello, world = [1,2] end # test comment
def method_without_parentheses *a, **b, &c; hello, world = [1,2] end # test comment

# multiline
def e arg
  puts arg
end

def f
  def g arg
    puts arg
  end
end

def h arg
  puts arg.end
end

def i arg
  end?       # self.end?
  end!       # self.end!
end

def method_without_parentheses a, b, c = [foo,bar,baz] # test comment
  hello, world = [1,2]
end

def method_without_parentheses a, b = "hello", c = ["foo", "bar"], d = (2 + 2) * 2, e = "" # test comment
  hello, world = [1,2]
  do_something1
  do_something2
end

def method_without_parentheses a,    
                               b = "hello"  , # test comment
                               c = ["foo", bar, :baz],
                               d = (2 + 2) * 2,
                               e = proc { |e| e + e }  
  hello, world = [1,2]
  do_something1
  do_something2
end

def method_without_parentheses *a, **b, &c # test comment
  hello, world = [1,2]
end

# -------------------------------------------
# Testarea for begin-block
# -------------------------------------------

# singleline
begin puts "foo" end
begin puts "foo"; begin puts "bar" end end
begin puts self.end end
begin puts self.end; end
begin puts end? end
begin puts end!; end
if begin true end then true else false end
1..begin 10 end
1...begin 10 end

self.begin puts "foo" end               #shouldn't work
self::begin puts "foo" end              #shouldn't work
begin? puts "foo" end                   #shouldn't work
begin! puts "foo" end                   #shouldn't work

# multiline
begin
  puts "foo"
end

begin
  puts self.end
end

begin
  puts end?
  puts end!
end

begin
  puts "foo"
  begin
    puts "bar"
  end
end

# -------------------------------------------
# Testarea for do-block
# -------------------------------------------

# singleline
3.times.map do 1 end
3.times.map do || 1 end
3.times.map do |e, x=1| e + x end
[(0..10), (10..20)].map do |r| r.end end
any_method do? 1 end                        #shouldn't work
any_method do! 1 end                        #shouldn't work
self.do 1 end                               #shouldn't work
self::do 1 end                              #shouldn't work

# multiline
[1,2,3].map do |element|
  element + 1
end

[[1],[2],[3]].each do |element|
  element.each do |subelement|
    puts subelement
  end
end

[(0..10), (10..20)].map do |r|
  r.end
end

[].each do |e|
  e + end? - end!
end

3.times do
  puts "foo"
end

3.times do ||
  puts "bar"
end

def test
  @do ||= {}
end

# -------------------------------------------
# Testarea for for-loop
# -------------------------------------------

# singleline
for i in for j in [[1,2]] do break j; end do puts i; end
for i in for j in [[1,2]] do break j; end do [i].map do |e| e end; end
for i in for j in [[1,2]]; break j; end; [i].map do |e| e end; end
for i in for j in if true then [[1,2]] else [[3,4]] end; break j; end; [i].map do |e| e end; end
for i in for j in if true; [[1,2]] else [[3,4]] end; break j; end; [i].map do |e| e end; end
for i in [(0..10), (10..20)] do break i.end end
for i in [] do puts end?; puts end! end
1..for i in [1,2,3] do break i if i == 2; end
1...for i in [1,2,3] do break i if i == 2; end
10 / for i in [1,2,3] do break i if i == 2; end
[for i in [1,2,3] do break i if i == 2 end]
[ for i in [1,2,3] do break i if i == 2 end, for i in [1,2,3] do break i if i == 3 end]
{for i in [1,2,3] do break i if i == 2 end => 1}
{ for i in [1,2,3] do break i if i == 2 end => 1 }
{foo: for i in [1,2,3] do break i if i == 2 end}
{ foo: for i in [1,2,3] do break i if i == 2 end, bar: for i in [1,2,3] do break i if i == 3 end }
{:foo => for i in [1,2,3] do break i if i == 2 end}
{ :foo => for i in [1,2,3] do break i if i == 2 end, :bar=>for i in [1,2,3] do break i if i == 3 end }
(for i in [1,2,3] do break i if i == 2 end)
( for i in [1,2,3] do break i if i == 2 end )

#you cant use do-end blocks inside in statement
for i in 3.times.map do 1 end do puts i; end                     # shouldn't work
for? i in [1,2,3]                                                # shouldn't work
for! i in [1,2,3]                                                # shouldn't work
self.for i in [1,2,3]                                            # shouldn't work

# multiline
for i in [1,2,3]
  puts i
end

for i in [(0..10), (10..20)] do
  puts i.end
end

for i in []
  puts end?
  puts end!
end

for i in for j in [[1,2]] do break j; end do
  r = [i].map do |e|
    e
  end
  p r
end

# -------------------------------------------
# Testarea for while/until
# -------------------------------------------

# singleline block
i = 0
while i < 10; i += 1; end
while i < 10 do i += 1; end
a = while i < 10 do break i if i == 5; i += 1; end
false || while i < 10 do break i if i == 5; i += 1; end
false or while i < 10; break i if i == 5; i += 1; end
true && while i < 10; break i if i == 5; i += 1; end
true and while i < 10 do break i if i == 5; i += 1; end
1..while i < 10 do break i if i == 5; i += 1; end
1...while i < 10 do break i if i == 5; i += 1; end
true ? while i < 10; break i if i == 5; i += 1; end : while i < 10; break i if i == 5; i += 1; end
!while i < 10; break i if i == 5; i += 1; end
! while i < 10; break i if i == 5; i += 1; end
true && !while i < 10; break i if i == 5; i += 1; end
true && ! while i < 10; break i if i == 5; i += 1; end
while i < while j < 10; break j if j == 5; j+=1; end; break i if i > 3; i += 1; end
while i < while j < 10 do break j if j == 5; j+=1; end; break i if i > 3; i += 1; end
while i < while j < 10; break j if j == 5; j+=1; end do break i if i > 3; i += 1; end
while i < while j < 10 do break j if j == 5; j+=1; end do break i if i > 3; i += 1; end
while false do [1,2,3].each do |e| puts e end; end
while false do [(0..10), (10..20)].each do |r| puts r.end end end
while false do puts end?; puts end! end
[while i < 10 do break i if i == 5; i += 1; end]
[ while i < 10 do break i if i == 5; i += 1 end, while i < 10 do break i if i == 6; i += 1 end ]
{while i < 10 do break i if i == 5; i += 1 end => 1}
{ while i < 10 do break i if i == 5; i += 1 end => 1 }
{foo: while i < 10 do break i if i == 5; i += 1 end}
{ foo: while i < 10 do break i if i == 5; i += 1 end, bar:while i < 10 do break i if i == 6; i += 1 end }
{:foo => while i < 10 do break i if i == 5; i += 1 end}
{ :foo => while i < 10 do break i if i == 5; i += 1 end, :bar=>while i < 10 do break i if i == 6; i += 1 end }
(while i < 10 do break i if i == 5; i += 1 end)
( while i < 10 do break i if i == 5; i += 1 end )

# singleline modifier
foo::while false                              # shouldn't work
while? false                                  # shouldn't work
while! false                                  # shouldn't work
foo.while false                               # shouldn't work
acc = 0
acc += 10 while acc < 1000
a = /regex/ while acc < 10
{} while false
[] while false
"foo" while false
'foo' while false
(expression) while false
foo! while false
foo? while false
method_without_args while false
method(with, args) while false
method with, args while false
`ls` while false

# multiline block
while i < 10
  i += 1
end
 
while i < 10 do
  i += 1
end
 
10 / while i < 10 do
  break i if i == 5
  i += 1
end

while false do
  [(0..10), (10..20)].each do |r|
    puts r.end
  end
end

while false do
  puts end?
  puts end!
end

begin
  i += 1
end; while i < 100 do i += 1; end
 
# multiline modifier
begin
  i += 1
end while i < 100

# -------------------------------------------
# Testarea for if/unless
# -------------------------------------------

# singleline block
1..if true; 10 else 20 end
1...if true then 10 else 20 end
if while i < 10 do break i if i == 5; i += 1; end < 10 then true else false end
if true then 1 else 2 end
true ? if true then true else false end : if true then true else false end
if if true then true else false end; 1 else 0 end
if if true then true else false end then 1 else 0 end
if if true; true else false end then 1 else 0 end
if if true; true else false end; 1 else 0 end
20 / if true then 10 else 5 end
20 / if true; 10 else 5 end
!if true then true else false end
! if true then true else false end
true && !if true then true else false end
true && ! if true then true else false end
a = /hello/; 20 / if true then 1 else 2 end
a = /hello/; if true then 1 else 2 end
if true then puts (1..10).end else puts (1..20).end end
if true then puts end? else puts end! end
[if true then 1 else 2 end]
[ if true then 1 else 2 end, if true then 2 else 3 end]
{if true then :foo else :bar end => 1}
{ if true then :foo else :bar end => 1 }
{foo: if true then 1 else 2 end}
{ foo: if true then 1 else 2 end, bar: if true then 2 else 3 end }
{:foo => if true then 1 else 2 end}
{ :foo => if true then 1 else 2 end, :bar=>if true then 2 else 3 end }
(if true then 1 else 2 end)
( if true then 1 else 2 end )

# singleline modifier
foo::if something                                                 # shouldn't work
foo.if something                                                  # shouldn't work
if? something                                                     # shouldn't work
if! something                                                     # shouldn't work
foo! if true
foo? if true
return {} if something
return [] if something
(expression) if something
method_without_args if something
method(with, args) if something
method with, args if somethign
a = /regexp/ if something
"hello".scan /[eo]/ if something
`ls` if true

# singleline mix
%w(hello, world, foo).map { |e| e.scan /[oeiua]/ } * if true; 2 else 0 end
%w(hello, world, foo).map { |e| e.scan /[oeiua]/ if true } * if true then 2 else 0 end
e.scan /[oeiua]/ if true; if true then 2 else 0 end

# multiline block
if something then
  if true
    foo
  else
    bar
  end
else
  baz
end

if true 
  puts (1..10).end
else
  puts (1..20).end
end

if true
  puts end?
else
  puts end!
end

begin
  1
end; if true; true else false end

# multiline modifier
begin
  1
end if true

# -------------------------------------------
# Testarea for case
# -------------------------------------------

# singleline
case 15 when 0..50 then "foo" when 51..100 then "bar" else "baz" end
case x = rand(1..100) when 0..50 then case x when 0..25 then 1 else 2 end when 51..100 then case x when 51..75 then 3 else 4 end end
1..case 15 when 0..50 then 10 when 51..100 then 20 else 30 end
1...case 15 when 0..50 then 10 when 51..100 then 20 else 30 end
case x = rand(1..100) when 0..50 then puts (1..10).end when 51..100 then puts (1..20).end end
case x = rand(1..100) when 0..50 then puts end? when 51..100 then puts end! end
[case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end]
[ case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end, case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end]
{case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end => 1}
{ case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end => 1 }
{foo: case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end}
{ foo: case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end, bar: case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end }
{:foo => case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end}
{ :foo => case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end, :bar=>case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end }
(case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end)
( case x = rand(1..100) when 0..50 then (1..10).end when 51..100 then (1..20).end end )

self.case 15 when 0..50 then "foo" when 51..100 then "bar" else "baz" end          # shouldn't work
self::case 15 when 0..50 then "foo" when 51..100 then "bar" else "baz" end         # shouldn't work
case? 15 when 0..50 then "foo" when 51..100 then "bar" else "baz" end              # shouldn't work
case! 15 when 0..50 then "foo" when 51..100 then "bar" else "baz" end              # shouldn't work

# multiline
case 15
when 0..50
  "foo"
when 51..100
  "bar"
else
  "baz"
end

case x = rand(1..100)
when 0..50 then
  puts (1..10).end
when 51..100 then
  puts (1..20).end
end

case x = rand(1..100)
when 0..50 then
  puts end?
when 51..100 then
  puts end!
end


case if [true, false].sample then 25 else 75 end
when 0..50
  "foo"
when 51..100
  "bar"
else
  "baz"
end

case x = rand(1..100)
when 0..50 then
  case x
  when 0..25 then
    1
  else
    2
  end
when 51..100 then
  case x
  when 51..75 then
    3
  else
    4
  end
end

# -------------------------------------------
# Testarea for rescue & ensure
# -------------------------------------------

# singleline
some_method rescue handle_error
some_method rescue SomeException

self.rescue handle_error                            # shouldn't work
self::rescue handle_error                           # shouldn't work
some_method rescue? handle_error                    # shouldn't work
some_method rescue! SomeException                   # shouldn't work

# multiline
begin
  some_method
rescue
  handle_error
ensure
  close_connection
end

begin
  some_method
rescue SomeException
  handle_error
ensure
  close_connection
end

def method1
  some_method
rescue
  handle_error
ensure
  close_connection
end

def method2
  some_method
rescue SomeException => e
  log(e)
  handle_error
ensure
  close_connection
end

def method3
  some_method
rescue? SomeException => e                        # shouldn't work
  log(e)
  handle_error
ensure?                                           # shouldn't work
  close_connection
end

def method4
  some_method
rescue! SomeException => e                        # shouldn't work
  log(e)
  handle_error
ensure!                                           # shouldn't work
  close_connection
end

def method5
  some_method
.rescue SomeException => e                        # shouldn't work
  log(e)
  handle_error
.ensure                                           # shouldn't work
  close_connection
end

def method6
  some_method
::rescue SomeException => e                        # shouldn't work
  log(e)
  handle_error
::ensure                                           # shouldn't work
  close_connection
end

# -------------------------------------------
# Testarea for symbols that looks like keyword
# -------------------------------------------

{
  class: 1,
  module: 1,
  if: 1,
  unless: 1,
  while: 1,
  until: 1,
  end: 1,
  for: 1,
  begin: 1,
  or: 1,
  not: 1,
  in: 1,
  when: 1,
  then: 1,
  case: 1,
  else: 1,
  do: 1,
  rescue: 1,
  ensure: 1,
  elsif: 1,
  def: 1
}

{class: 1,module: 1,if: 1,unless: 1,while: 1,until: 1,end: 1,for: 1,begin: 1,or: 1,not: 1,in: 1,when: 1,then: 1,case: 1,else: 1,do: 1,rescue: 1,ensure: 1,elsif: 1,def: 1}
{ class: 1, module: 1, if: 1, unless: 1, while: 1, until: 1, end: 1, for: 1, begin: 1, or: 1, not: 1, in: 1, when: 1, then: 1, case: 1, else: 1, do: 1, rescue: 1, ensure: 1, elsif: 1, def: 1 }

{
  :class => 1,
  :module => 1,
  :if => 1,
  :unless => 1,
  :while => 1,
  :until => 1,
  :end => 1,
  :for => 1,
  :begin => 1,
  :or => 1,
  :not => 1,
  :in => 1,
  :when => 1,
  :then => 1,
  :case => 1,
  :else => 1,
  :do => 1,
  :rescue => 1,
  :ensure => 1,
  :elsif => 1,
  :def => 1,
}

[
  :class,
  :module,
  :if,
  :unless,
  :until,
  :end,
  :for,
  :begin,
  :or,
  :not,
  :in,
  :when,
  :then,
  :case,
  :else,
  :do,
  :rescue,
  :ensure,
  :elsif,
  :def
]

[:class,:module,:if,:unless,:until,:end,:for,:begin,:or,:not,:in,:when,:then,:case,:else,:do,:rescue,:ensure,:elsif,:def]
[ :class, :module, :if, :unless, :until, :end, :for, :begin, :or, :not, :in, :when, :then, :case, :else, :do, :rescue, :ensure, :elsif, :def ]
