# purpose:
# exercise constructs with division
#
# division itself      84 / 2
# regexp               /pattern/
#
#
#

def test(obj)
	p obj
end
a, b = 4, 2

# -------------------------------------------
#
# Testarea for division
#
# -------------------------------------------

# singleline numbers
test(84 / 2)

# singleline symbols
test(a / b)

# singleline symbols
test(a / b / 3)   # TODO: not recognize as regexp


# multiline with symbols
=begin # invalid
test(a 
/ b)
=end

# multiline with symbols
test(a / 
b)


# -------------------------------------------
#
# Testarea for regexp
#
# -------------------------------------------

# singleline
test( // )
test( /abc/ )
test( /a\/bc/ )
test [/^F../]
p 'Foobar'[/^F../]
p '42' =~ /42/

# multiline  TODO: color me!
test( /
pattern
/x    )


# multiline  TODO: color me!
test( 
/r
eg
e/x
)