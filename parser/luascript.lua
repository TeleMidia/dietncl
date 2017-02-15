-- Script to test the simple lib

xml = require 'simple'
f = require 'simplelib'

for k, v in pairs (xml) do
   print (k, v)
end

local t = f.parse_file 'test1.xml'

local s = xml.str (t)

print ('-----------------------------------------------------------')
print ('- xml.str test, print xml string --------------------------')
print (s)
print ('\n')

print ('-----------------------------------------------------------')
print ('- xml.tag test, return tag of LuaXML object ---------------')
print (xml.tag (t))
print ('\n')

print ('- xml.tag test, set tag of LuaXML object ------------------')
xml.tag (t, "This")
print (t[0])
xml.tag (t, 'zoo')
print ('\n')

print ('-----------------------------------------------------------')
print ('- xml.new test, create new LuaXML object setting its tag --')
print (xml.tag (xml.new ('is')))
print ('\n')

print ('- xml.new test, set metatable of Lua table ----------------')
xml.new (t)
print (t:tag(t:tag('a')))
print ('\n')
t:tag('zoo')

print ('-----------------------------------------------------------')
print ('- xml.append test, append a new subordinate LuaXML object -')
xml.append (t, 'test')
print (xml.tag (t[5]))
print ('\n')

print ('-----------------------------------------------------------')
print ('- xml.find, find a LuaXML object in a table (if it exists)-')
print (xml.find (t, 'lion'))
