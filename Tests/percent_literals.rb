# Default – Interpolated
%(The quick #{color} fox jumps over the #{temperment} dog)
%[The quick #{color} fox jumps over the #{temperment} dog]
%{The quick #{color} fox jumps over the #{temperment} dog}
%<The quick #{color} fox jumps over the #{temperment} dog>
%:The quick #{color} fox jumps over the #{temperment} dog:

%(The quick #{color} fox (jumps over the #{temperment} dog))
%[The quick #{color} fox [jumps over the #{temperment} dog]]
%{The quick #{color} fox {jumps over the #{temperment} dog}}
%<The quick #{color} fox <jumps over the #{temperment} dog>>


# Non-interpolated
%q(The quick brown fox jumps over the lazy dog)
%q[The quick brown fox jumps over the lazy dog]
%q{The quick brown fox jumps over the lazy dog}
%q<The quick brown fox jumps over the lazy dog>
%q:The quick brown fox jumps over the lazy dog:

%q(The quick brown fox (jumps over the lazy dog))
%q[The quick brown fox [jumps over the lazy dog]]
%q{The quick brown fox {jumps over the lazy dog}}
%q<The quick brown fox <jumps over the lazy dog>>


# Interpolated
%Q(The quick #{color} fox\njumps over the #{temperment} dog)
%Q[The quick #{color} fox\njumps over the #{temperment} dog]
%Q{The quick #{color} fox\njumps over the #{temperment} dog}
%Q<The quick #{color} fox\njumps over the #{temperment} dog>
%Q:The quick #{color} fox\njumps over the #{temperment} dog:

%Q(The quick #{color} fox\n(jumps over the #{temperment} dog))
%Q[The quick #{color} fox\n[jumps over the #{temperment} dog]]
%Q{The quick #{color} fox\n{jumps over the #{temperment} dog}}
%Q<The quick #{color} fox\n<jumps over the #{temperment} dog>>

%Q:The quick #{color} fox\n}jumps over the #{temperment} dog:         # Don't let a stray closing
                                                                      #  character end string

# Regular expression
%r(The quick brown fox jumps over the lazy dog)i
%r[The quick brown fox jumps over the lazy dog]i
%r{The quick brown fox jumps over the lazy dog}i
%r<The quick brown fox jumps over the lazy dog>i
%r:The quick brown fox jumps over the lazy dog:i

%r(The quick #{color} fox (jumps over the lazy dog))i
%r[The quick #{color} fox [jumps over the lazy dog]]i
%r{The quick #{color} fox {jumps over the lazy dog}}i
%r<The quick #{color} fox <jumps over the lazy dog>>i


# Symbol Array – Non-interpolated
%i(afgan akita azawakh)
%i[afgan akita azawakh]
%i{afgan akita azawakh}
%i<afgan akita azawakh>
%i:afgan akita azawakh:

%i(afgan akita (azawakh))                               # Symbol should include the punctuation
%i[afgan akita [ azawakh]]                              # [ Should be it's own separate symbol
%i{afgan akita {azawakh}}
%i<afgan akita\< az<awakh>>                             # \< Should be included in symbol and escaped


# Symbol Array – Interpolated
%I(afgan akita #{breed})
%I[afgan akita #{breed}]
%I{afgan akita #{breed}}
%I<afgan akita #{breed}>
%I:afgan akita #{breed}:

%I(afgan akita (#{breed}))
%I[afgan akita [#{breed}]]
%I{afgan akita {#{breed}}}
%I<afgan akita <#{breed}>>


# Array – Non-interpolated
%w(cheetah leopard mountain\ lion)                      # mountain lion should be a single string
%w[cheetah leopard mountain\ lion]
%w{cheetah leopard mountain\ lion}
%w<cheetah leopard mountain\ lion>
%w:cheetah leopard mountain\ lion:

%w(cheetah leopard (mountain\ lion))
%w[cheetah leopard [mountain\ lion]]
%w{cheetah leopard {mountain\ lion}}
%w<cheetah leopard <mountain\ lion>>


# Array – Interpolated
%W(cheetah leopard #{codename})
%W[cheetah leopard #{codename}]
%W{cheetah leopard #{codename}}
%W<cheetah leopard #{codename}>
%W:cheetah leopard #{codename}:

%W(cheetah leopard (#{codename}))
%W[cheetah leopard [#{codename}]]
%W{cheetah leopard {#{codename}}}
%W<cheetah leopard <#{codename}>>


# Shell Command – Interpolated
%x(mate Bundles/#{name}.tmbundle)
%x[mate Bundles/#{name}.tmbundle]
%x{mate Bundles/#{name}.tmbundle}
%x<mate Bundles/#{name}.tmbundle>
%x:mate Bundles/#{name}.tmbundle:

%x(mate Bundles/(ruby).tmbundle)
%x[mate Bundles/[ruby].tmbundle]
%x{mate Bundles/{ruby}.tmbundle}
%x<mate Bundles/<ruby>.tmbundle>


# Symbol – Non-interpolated
%s(avian)
%s[avian]
%s{avian}
%s<avian>
%s:avian:

%s(text(mate))
%s[text[mate]]
%s{text{mate}}
%s<text<mate>>
