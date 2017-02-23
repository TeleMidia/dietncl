-- Script to test the xmllib file parser

f = require ('dietncl.xmlsugar')

for k, v in pairs (f) do
   print (k, v)
end

local t = f.parse_file ('ncl-simple.xml')

-- ncl
print (t[0].tag)

-- head
print (t[1][0].tag)

-- body
print (t[2][0].tag)
