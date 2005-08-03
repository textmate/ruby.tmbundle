# purpose:
# exercise constructs with questionmark
#
# numeric letters      ?x
# ternary operator     condition ? case1 : case2
#
#
#

def test(v)
	puts "#{v.inspect} => #{v.chr}"
end
def z(v)
	v
end



# -------------------------------------------
#
# Testarea for numeric letters
#
# -------------------------------------------

# normal letters
test( ?a )
test( ?A )
test( ?0 )

# misc symbols
test( ?* )
test( ?**2 )


# symbol '#'
test( ?# ); p 'im not a comment' 

# symbol '?'
test( ?? )    
test(??)

# symbol '\\'
test( ?\\ )

# escaped as hex
test( ?\x61 )

# escaped as octal
test( ?\0 )
test( ?\07 )
test( ?\017 )
#test( ?\0173 )   #invalid
test( ?\1 )
test( ?\7 )
test( ?\a )
test( ?\f )

# standard escapings
test( ?\n )  # newline
test( ?\b )  # backspace

# escaped misc letters/symbols
test( ?\8 )
test( ?\9 )
test( ?\_ )


# -------------------------------------------
#
# Testarea for ternary operator
#
# -------------------------------------------
a, b, val = 42, 24, true
p(val ? 0 : 2)

p [
 val ? (a) : z(b)    ,
 val ? 'a' : 'b'
]

