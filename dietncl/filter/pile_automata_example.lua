---
-- This is an example of a pile automaton that accepts a non ambiguous
-- CFG (Context Free Grammar). A test code for the parser implementation.
-- The L(P) accepted by the automaton P is L = {wcw^r | w e (0 + 1)*}
---

local string = string
local print = print

_ENV = nil

-- recursive function that implements the automaton functionality
local function automaton (str, pile, half)
   local char = str:sub (1, 1)
   local pile = pile or {}

   if char == 'c' then
      return automaton (str:sub (2), pile, 1)
   end

   if char == '' then
      if #pile == 0 then
         return true
      else
         return false
      end
   end

   if half == nil then
      pile[#pile + 1] = char
   else
      if char == pile[#pile] then
         pile[#pile] = nil
      else
         return false
      end
   end

   return automaton (str:sub (2), pile, half)
end

-- this part is meant to test the automaton coded above
local test = automaton ('100110c011001')
print ('test 1 -->', test)

local test = automaton ('1010101010c1111000011')
print ('test 2 -->', test)

local test = automaton ('111100001010c010100001111')
print ('test 3 -->', test)

local test = automaton ('1010101010c0101010101')
print ('test 4 -->', test)
