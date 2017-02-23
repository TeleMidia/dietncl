-- Script to test the xmllib string parser

f = require ('dietncl.xmlsugar')

for k, v in pairs (f) do
   print (k, v)
end

local t = f.parse_string ([[
<this>
  <is>
    <a>
      <test/>
    </a>
  </is>
</this>
]])

print ('>>>>>>>>>>>>', t)
print (t[0].tag)
print (t[1][0].tag)
print (t[1][1][0].tag)
print (t[1][1][1][0].tag)

local t = f.parse_string ([[
<root>
  <x/>
  <y>
    <a/>
    <b/>
    <c>
      <r>
        <s/>
      </r>
    </c>
  </y>
  <z/>
  <w/>
</root>
]])

print ('>>>>>>>>>>>>', t)
print (t[0].tag) -- root
print (t[1][0].tag) -- x
print (t[2][0].tag) -- y
print (t[2][1][0].tag) -- a
print (t[2][2][0].tag) -- b
print (t[2][3][0].tag) -- c
print (t[2][3][1][0].tag) -- r
print (t[2][3][1][1][0].tag) -- s
print (t[3][0].tag) -- z
print (t[4][0].tag) -- w
