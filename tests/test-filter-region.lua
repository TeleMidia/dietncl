-- test-filter-region.lua -- Checks filter.region.
-- Copyright (C) 2013 PUC-Rio/Laboratorio TeleMidia
--
-- This file is part of DietNCL.
--
-- DietNCL is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DietNCL is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DietNCL.  If not, see <http://www.gnu.org/licenses/>.

require ('dietncl')
local filter = require ('dietncl.filter.region')
local util   = require ('util')


-- Single region base; no descriptors.

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <regionBase>
   <region id='r1' top='30%' left='45%'>
    <region id='r2' top='44%'/>
   </region>
  </regionBase>
 </head>
</ncl>
]])

filter.apply (ncl)
assert (ncl:equal (dietncl.parsestring ([[
<ncl>
 <head/>
</ncl>]])))


-- Single region base; single descriptor.

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <regionBase device='3'>
   <region id='r' top='30%' left='33px' height='40' zIndex='4'/>
  </regionBase>
  <descriptorBase>
   <descriptor id='d' region='r'>
    <descriptorParam name='top' value='45%'/>
   </descriptor>
  </descriptorBase>
 </head>
</ncl>
]])

filter.apply (ncl)
assert (util.uequal (ncl, dietncl.parsestring ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d'>
    <descriptorParam name='top' value='45%'/>
    <descriptorParam name='left' value='33px'/>
    <descriptorParam name='height' value='40'/>
    <descriptorParam name='zIndex' value='4'/>
    <descriptorParam name='device' value='3'/>
   </descriptor>
  </descriptorBase>
 </head>
</ncl>
]])))


-- Multiple region bases; no nesting.

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <regionBase device='16'>
   <region id='x' top='50%' left='10%'/>
  </regionBase>
  <regionBase>
   <region id='y' top='10%' left='50%'/>
  </regionBase>
  <connectorBase>
  </connectorBase>
  <regionBase>
   <region id='z' top='5%' left='4%'/>
  </regionBase>
  <descriptorBase>
   <descriptor id='dx' region='x'/>
   <descriptor id='dy' region='y'/>
   <descriptor id='dz' region='z'/>
  </descriptorBase>
 </head>
</ncl>]])

filter.apply (ncl)
assert (util.uequal (ncl, dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase/>
  <descriptorBase>
   <descriptor id='dx'>
    <descriptorParam name='top' value='50%'/>
    <descriptorParam name='left' value='10%'/>
    <descriptorParam name='device' value='16'/>
   </descriptor>
   <descriptor id='dy'>
    <descriptorParam name='top' value='10%'/>
    <descriptorParam name='left' value='50%'/>
   </descriptor>
   <descriptor id='dz'>
    <descriptorParam name='top' value='5%'/>
    <descriptorParam name='left' value='4%'/>
   </descriptor>
  </descriptorBase>
 </head>
</ncl>]])))


-- w,h in pixels: do nothing.

ncl = filter.apply (dietncl.parsestring ([[
<ncl>
 <head>
  <regionBase>
   <region id='x' width='1' height='3px'>
    <region id='y' width='2px' height='2'>
     <region id='z' width='3' height='1'/>
     <region id='w' width='35'/>
    </region>
   </region>
  </regionBase>
  <descriptorBase>
   <descriptor id='dx' region='x'/>
   <descriptor id='dy' region='y'/>
   <descriptor id='dz' region='z'/>
  </descriptorBase>
 </head>
</ncl>]]))

assert (util.uequal (ncl, dietncl.parsestring ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='dx'>
    <descriptorParam name='width' value='1'/>
    <descriptorParam name='height' value='3px'/>
   </descriptor>
   <descriptor id='dy'>
    <descriptorParam name='width' value='2px'/>
    <descriptorParam name='height' value='2'/>
   </descriptor>
   <descriptor id='dz'>
    <descriptorParam name='width' value='3'/>
    <descriptorParam name='height' value='1'/>
   </descriptor>
  </descriptorBase>
 </head>
</ncl>]])))


-- Valid and invalid combinations of t,b,l,r.

local function doapply (attr, dim, regval, parval, dimval)
   return filter.apply (util.parsenclformat ([[
<ncl>
 <head>
  <regionBase>
   <region id='x' %s='%s' %s='%s'>
    <region id='y' %s='%s'/>
   </region>
  </regionBase>
  <descriptorBase>
   <descriptor id='dx' region='x'/>
   <descriptor id='dy' region='y'/>
  </descriptorBase>
 </head>
</ncl>
]], attr, parval, dim, dimval, attr, regval))
end

local function check_success (regval, parval, dimval)
   assert (doapply ('top', 'height', regval, parval, dimval))
   assert (doapply ('bottom', 'height', regval, parval, dimval))
   assert (doapply ('left', 'width', regval, parval, dimval))
   assert (doapply ('right', 'width', regval, parval, dimval))
end

local function check_fail (regval, parval, dimval)
   assert (doapply ('top', 'height', regval, parval, dimval) == nil)
   assert (doapply ('bottom', 'height', regval, parval, dimval) == nil)
   assert (doapply ('left', 'width', regval, parval, dimval) == nil)
   assert (doapply ('right', 'width', regval, parval, dimval) == nil)
end

check_success ('1',  '1',  '1')   -- px px px -> px  (CASE1)
check_success ('1',  '1',  '1%')  -- px px %  -> px  (CASE2)
check_fail    ('1',  '1%', '1')   -- px %  px -> !
check_fail    ('1',  '1%', '1%')  -- px %  %  -> !
check_success ('1%', '1',  '1')   -- %  px px -> px  (CASE3)
check_fail    ('1%', '1',  '1%')  -- %  px %  -> !
check_fail    ('1%', '1%', '1')   -- %  %  px -> !
check_success ('1%', '1%', '1%')  -- %  %  %  -> %   (CASE4)


-- CASE1: t,b,l,r in pixels and w,l in pixels.

fmtin = [[
<ncl>
 <head>
  <regionBase>
   <region id='x' %s='30' height='30px' width='33px'>
    <region id='y' %s='4' height='40px' width='44'/>
   </region>
  </regionBase>
  <descriptorBase>
   <descriptor id='dx' region='x'/>
   <descriptor id='dy' region='y'/>
  </descriptorBase>
 </head>
</ncl>
]]

fmtout = [[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='dx'>
    <descriptorParam name='%s' value='30'/>
    <descriptorParam name='height' value='30px'/>
    <descriptorParam name='width' value='33px'/>
   </descriptor>
   <descriptor id='dy'>
    <descriptorParam name='%s' value='34px'/>
    <descriptorParam name='height' value='40px'/>
    <descriptorParam name='width' value='44'/>
   </descriptor>
  </descriptorBase>
 </head>
</ncl>
]]

for _,a in ipairs ({'top', 'bottom', 'left', 'right'}) do
   ncl = filter.apply (util.parsenclformat (fmtin, a, a))
   out = util.parsenclformat (fmtout, a, a)
   assert (util.uequal (ncl, out))
end


-- CASE2: t,b,l,r in pixels and w,h in %.

fmtin = [[
<ncl>
 <head>
  <regionBase>
   <region id='x' %s='30' width='30%%' height='44%%'>
    <region id='y' %s='4'/>
   </region>
  </regionBase>
  <descriptorBase>
   <descriptor id='dx' region='x'/>
   <descriptor id='dy' region='y'/>
  </descriptorBase>
 </head>
</ncl>
]]

fmtout = [[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='dx'>
    <descriptorParam name='%s' value='30'/>
    <descriptorParam name='width' value='30%%'/>
    <descriptorParam name='height' value='44%%'/>
   </descriptor>
   <descriptor id='dy'>
    <descriptorParam name='%s' value='34px'/>
    <descriptorParam name='width' value='30%%'/>
    <descriptorParam name='height' value='44%%'/>
   </descriptor>
  </descriptorBase>
 </head>
</ncl>
]]

for _,a in ipairs ({'top', 'bottom', 'left', 'right'}) do
   ncl = filter.apply (util.parsenclformat (fmtin, a, a))
   out = util.parsenclformat (fmtout, a, a)
   assert (util.uequal (ncl, out))
end


-- CASE3: child t,b,l,r in %, parent t,b,l,r in pixels, and w,h in pixels.

fmtin = [[
<ncl>
 <head>
  <regionBase>
   <region id='x' %s='30px' width='30px' height='44px'>
    <region id='y' %s='40%%'/>
   </region>
  </regionBase>
  <descriptorBase>
   <descriptor id='dx' region='x'/>
   <descriptor id='dy' region='y'/>
  </descriptorBase>
 </head>
</ncl>
]]

fmtout = [[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='dx'>
    <descriptorParam name='%s' value='30px'/>
    <descriptorParam name='width' value='30px'/>
    <descriptorParam name='height' value='44px'/>
   </descriptor>
   <descriptor id='dy'>
    <descriptorParam name='%s' value='%spx'/>
    <descriptorParam name='width' value='30px'/>
    <descriptorParam name='height' value='44px'/>
   </descriptor>
  </descriptorBase>
 </head>
</ncl>
]]

for _,a in ipairs ({'top', 'bottom', 'left', 'right'}) do
   local d
   if a == 'top' or a == 'bottom' then
      d = 47
   else
      d = 42
   end
   ncl = filter.apply (util.parsenclformat (fmtin, a, a))
   out = util.parsenclformat (fmtout, a, a, d)
   assert (util.uequal (ncl, out))
end


-- CASE4: t,b,l,r in % and w,h in %.

fmtin = [[
<ncl>
 <head>
  <regionBase>
   <region id='x' %s='30%%' width='30%%' height='44%%'>
    <region id='y' %s='40%%'/>
   </region>
  </regionBase>
  <descriptorBase>
   <descriptor id='dx' region='x'/>
   <descriptor id='dy' region='y'/>
  </descriptorBase>
 </head>
</ncl>
]]

fmtout = [[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='dx'>
    <descriptorParam name='%s' value='30%%'/>
    <descriptorParam name='width' value='30%%'/>
    <descriptorParam name='height' value='44%%'/>
   </descriptor>
   <descriptor id='dy'>
    <descriptorParam name='%s' value='%s%%'/>
    <descriptorParam name='width' value='30%%'/>
    <descriptorParam name='height' value='44%%'/>
   </descriptor>
  </descriptorBase>
 </head>
</ncl>
]]

for _,a in ipairs ({'top', 'bottom', 'left', 'right'}) do
   local d
   if a == 'top' or a == 'bottom' then
      d = 47.6
   else
      d = 42
   end
   ncl = filter.apply (util.parsenclformat (fmtin, a, a))
   out = util.parsenclformat (fmtout, a, a, d)
   assert (util.uequal (ncl, out))
end


-- A bigger sample.

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d1' region='r1b' transIn='t1' freeze='true'>
    <descriptorParam name='zIndex' value='8'/>
   </descriptor>
   <descriptorSwitch id='ds'>
    <defaultDescriptor descriptor='dsb'/>
    <descriptor id='dsa' region='r2a' transIn='t2'/>
    <descriptor id='dsb' region='r2b'/>
    <bindRule constituent='dsa' rule='b1'/>
    <bindRule constituent='dsb' rule='b2'/>
   </descriptorSwitch>
  </descriptorBase>
  <regionBase id='rb1' device='1'>
   <region id='r1a' top='35%' left='44px' width='33px' height='50%'>
    <region id='r1b' top='15%' left='13px' width='15%' zIndex='3'/>
   </region>
  </regionBase>
  <transitionBase>
   <transition id='t1' type='barWipe' subtype='clockWipe'/>
   <transition id='t2' type='fade' dur='3s'/>
  </transitionBase>
  <regionBase id='rb2'>
   <region id='r2a' bottom='35%' right='44px' width='33px' height='50%'>
    <region id='r2b' bottom='15%' right='13px' height='30px' zIndex='5'/>
   </region>
  </regionBase>
  <ruleBase>
   <rule id='b1' var='x' comparator='eq' value='30'/>
   <rule id='b2' var='y' comparator='ne' value='35'/>
  </ruleBase>
 </head>
 <body>
  <media id='settings' type='application/x-ncl-settings'>
   <property name='x' value='30'/>
   <property name='y' value='35'/>
  </media>
 </body>
</ncl>
]])
filter.apply (ncl)

assert (util.uequal (ncl, dietncl.parsestring ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d1' transIn='t1' freeze='true'>
    <descriptorParam name='zIndex' value='8'/>
    <descriptorParam name='top' value='42.5%'/>
    <descriptorParam name='left' value='57px'/>
    <descriptorParam name='width' value='4.95px'/>
    <descriptorParam name='height' value='50%'/>
    <descriptorParam name='device' value='1'/>
   </descriptor>
   <descriptorSwitch id='ds'>
    <defaultDescriptor descriptor='dsb'/>
    <descriptor id='dsa' transIn='t2'>
     <descriptorParam name='bottom' value='35%'/>
     <descriptorParam name='right' value='44px'/>
     <descriptorParam name='width' value='33px'/>
     <descriptorParam name='height' value='50%'/>
    </descriptor>
    <descriptor id='dsb'>
     <descriptorParam name='bottom' value='42.5%'/>
     <descriptorParam name='right' value='57px'/>
     <descriptorParam name='zIndex' value='5'/>
     <descriptorParam name='width' value='33px'/>
     <descriptorParam name='height' value='30px'/>
    </descriptor>
    <bindRule constituent='dsa' rule='b1'/>
    <bindRule constituent='dsb' rule='b2'/>
   </descriptorSwitch>
  </descriptorBase>
  <transitionBase>
   <transition id='t1' type='barWipe' subtype='clockWipe'/>
   <transition id='t2' type='fade' dur='3s'/>
  </transitionBase>
  <ruleBase>
   <rule id='b1' var='x' comparator='eq' value='30'/>
   <rule id='b2' var='y' comparator='ne' value='35'/>
  </ruleBase>
 </head>
 <body>
  <media id='settings' type='application/x-ncl-settings'>
   <property name='x' value='30'/>
   <property name='y' value='35'/>
  </media>
 </body>
</ncl>
]])))
