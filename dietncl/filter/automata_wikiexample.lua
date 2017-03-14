---
-- This is an example of an automaton that accepts strings that are
-- represented by the following regular expression: 0*(11* + 1(01*0)*1).
-- Meaning strings that are multiples of 3.
---

local print = print
local string = string

_ENV = nil

-- table containing state links to each entry
local t = {
   [0] = {['0'] = 0, ['1'] = 1},
   [1] = {['0'] = 2, ['1'] = 0},
   [2] = {['0'] = 1, ['1'] = 2}
}

-- recursive function that iterates over string chars
local function automata (str, state)
   local char = str:sub (1, 1)
   local state = state or 0

   if char == '' then
      if state == 0 then
         return true
      else
         return false
      end
   end

   state = t[state][char]

   return automata (str:sub (2), state)
end

local test = automata ('1011101')
print ('test 1 -->', test)

test = automata ('10111011')
print ('test 2 -->', test)

test = automata ('000100011111101')
print ('test 3 -->', test)

test = automata ('00000000101111101')
print ('test 4 -->', test)
