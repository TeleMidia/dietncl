-- Script to test the simple lib

f = require ('dietncl.xmlsugar')

for k, v in pairs (f) do
   print (k, v)
end

local t = f.parse_file ('test1.xml')

print (t[0])

print (t[1][0])

print (t[1][1][0])
print (t[1]["noise"])

print (t[2][1][0])
print (t[2]["noise"])

print (t[3][1][0])
print (t[3]["noise"])

print (t[4][0])
