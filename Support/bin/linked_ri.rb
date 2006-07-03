#!/usr/bin/env ruby -w

term = ARGV.shift

def link_methods(prefix, methods)
  methods.gsub(/<\/?\w+>/, "").split(/,\s*/).map do |meth|
    "<a href=\"javascript:ri('#{prefix}#{meth}')\">#{meth}</a>"
  end.join(", ")
end

documentation = `ri -Tf html #{term}` rescue "<h1>ri Command Error.</h1>"

if documentation.include? "More than one method matched"
  methods       = documentation.to_a.last.split(/,\s*/)
  list_items    = methods.inject("") do |str, item|
    str + "<li><a href=\"javascript:ri('#{item}')\">#{item}</a></li>\n"
  end
  documentation = "<h1>Multiple Matches:</h1>\n<ul>\n#{list_items}</ul>\n"
elsif documentation.sub!( /\A\s*<b>([A-Z_]\w*)(#|::|\.)/,
                          "<b><a href=\"javascript:ri('\\1')\">\\1</a>\\2" )
  # do nothing--added class/module link
else
  documentation.sub!( /\A\s*(<b>Class: \w* < )([^\s<]+)/,
                            "\\1<a href=\"javascript:ri('\\2')\">\\2</a>" )
  documentation.sub!(/<h2>Includes:<\/h2>\s+(.+)$/) do
    "<h2>Includes:</h2>\n" +
    "<p>" + $1.gsub(/<\/?\w+>/, "").gsub(/([A-Z_]\w*)\(([^)]*)\)/) do |match|
      "<a href=\"javascript:ri('#{$1}')\">#{$1}</a>(" +
      link_methods("#{$1}#", $2) + ")"
    end + "</p>\n"
  end
  documentation.sub!(/<h2>Class methods:<\/h2>\s+(.+)$/) do
    "<h2>Class methods:</h2>\n" +
    "<p>" + link_methods("#{term}::", $1) + "</p>\n"
  end
  documentation.sub!(/<h2>Instance methods:<\/h2>\s+(.+)$/) do
    "<h2>Instance methods:</h2>\n" +
    "<p>" + link_methods("#{term}#", $1) + "</p>\n"
  end
end

puts documentation