def method; hello, world = [1,2] end # test comment

def method_with_parentheses(a, b, c = [foo,bar,baz]); hello, world = [1,2] end # test comment

def method_without_parentheses a, b, c = [foo,bar,baz]; hello, world = [1,2] end # test comment

def method # test comment
  hello, world = [1,2]
end

def method_with_parentheses(a, b, c = [foo,bar,baz]) # test comment
  hello, world = [1,2]
end

def method_without_parentheses a, b, c = [foo,bar,baz] # test comment
  hello, world = [1,2]
end

def method_with_parentheses(a, b = "hello", c = ["foo", "bar"], d = (2 + 2) * 2, e = {}) # test comment
  hello, world = [1,2]
  do_something1
  do_something2
end

def method_without_parentheses a, b = "hello", c = ["foo", "bar"], d = (2 + 2) * 2, e = "" # test comment
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

def method_without_parentheses a,    
                               b = "hello"   , # test comment
                               c = ["foo", bar, :baz],
                               d = (2 + 2) * 2,
                               e = proc { |e| e + e }  
  hello, world = [1,2]
  do_something1
  do_something2
end

def method_without_parentheses a,    
                               b: hello   , # test comment
                               c: ["foo", bar, :baz],
                               d: (2 + 2) * 2, 
                               e: proc { |e| e + e }  
  hello, world = [1,2]
  do_something1
  do_something2
end

# double splat, splat, and & opearator
def method_with_parentheses(*a, **b, &c); hello, world = [1,2] end # test comment

def method_without_parentheses *a, **b, &c; hello, world = [1,2] end # test comment

def method_with_parentheses(*a, **b, &c) # test comment
  hello, world = [1,2]
end

def method_without_parentheses *a, **b, &c # test comment
  hello, world = [1,2]
end
