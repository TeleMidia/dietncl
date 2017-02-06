-- Script to test the simple2 lib

f = require 'simple2'

local t = f'simple.xml'

print (t[0])

print (t[1][0])

print (t[1][1][0])
print (t[1]["noise"])

print (t[2][1][0])
print (t[2]["noise"])

print (t[3][1][0])
print (t[3]["noise"])

print (t[4][0])
