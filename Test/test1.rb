# Ruby syntax test file for stuff we've gotten wrong in the past or are currently getting wrong

#########
#basics

module samwi_78se
	
	class dubya < slime

	end
end

class gallo_way8 < kni9_ght

	def sl_9ay(beast)
		
	end
end


def hot?(cold)

end

def w00t!
	
	unless l33t
		sysbeep
	end
	
end

###########
# method names

# method names can be keywords and should not be highlighted if they appear as explicit method invocations
br = m.end(0) + b1
x, y = b2vxay(m.begin(0) + b1)
stream.next
self.class

############
# numbers

data += 0.chr
99.downto(0)

0xCAFEBABE022409ad802046
23402
4.232


###########
# strings 

'hello #{42} world'		# no interpolationm

# double quoted string (allows for interpolation):
"hello #{42} world"	  #->  "hello 42 world"
"hello #@ivar world"  #->  "hello 42 world"
"hello #@@cvar world" #->  "hello 42 world"
"hello #$gvar world"  #->  "hello 42 world"

# escapes
"hello #$gvar \"world"  #->  "hello 42 \"world"

# execute string (allows for interpolation):
%x{ls #{dir}}	 #-> ".\n..\nREADME\nmain.rb"
`ls #{dir}`   #-> ".\n..\nREADME\nmain.rb"

if (data.size % 2) == 1
line << ('%3s ' % str)


###########
# regexp

/matchmecaseinsensitive/i
/matchme/
/ matchme /
%r{matchme}

32/23	#division, not regexp

32 / 32 #division, not regexp

gsub!(/ +/, '')  #regexp, not division

###########
# symbols

:BIG  :aBC	:AbC9  :symb  :_asd	 :_9sd	:__=  :f00bar  :abc!
			:abc?  :abc=  :<<  :<  :>>	:>	:<=>  :<=  :>=	:%	:*	:**
			:+	:-	:&	:|	:~	:=~	 :==  :===	:`	:[]=  :[]  :/  :-@
			:+@	 :@aaa	:@@bbb

# else clause of ternary logic should not highlight as symbol
val?(a):p(b)
val?'a':'b'
M[1]?(a+b):p(c+d)

############
#literal capable of interpolation:	 
%W(a b#{42}c) #-> ["a", "b42c"]
%W(ab c\nd \\\)ef)

%(#{42})  #->  "42"



############
#literal incapable of interpolation
%w(a b#{42}c) 					#-> ["a", "b#{42}c"]############
%w(ab c\nd \\\)ef)				# heredoc tests

append << not_heredoc;

heredoc = <<END # C heredoc

void LoveMyCarpet( bool forReal )
{
	forReal = 56;
}

END

assert_equal(2**i, 1<<i)


##########
# end marker

__END__

def nothing_here_should_be_highlighted!( at all )

end
