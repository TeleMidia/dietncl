-- test-filter-import.lua -- Checks filter.import.
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
local filter = require ('dietncl.filter.import')
local util   = require ('util')


--========================================================================--
--            Part I -- Checks the resolution of <importBase>             --
--========================================================================--


-- Invalid 'documentURI' (file not found).

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <importBase alias='x' documentURI='!!!NON_EXISTENT!!!'/>
  </connectorBase>
 </head>
 <body/>
</ncl>]])
ncl, err = filter.apply (ncl)
assert (ncl == nil)
assert (err:match ('!!!NON_EXISTENT!!!'))

tmp = util.tmpfile ([[
<ncl>
 <head>
  <connectorBase>
   <importBase alias='x' documentURI='/!!!NON_EXISTENT!!!'/>
  </connectorBase>
 </head>
 <body/>
</ncl>]])

ncl = util.parsenclformat ([[
<ncl>
 <head>
  <regionBase>
   <importBase alias='x' documentURI='%s'/>
  </regionbAse>
 </head>
 <body/>
</ncl>]], tmp)
ncl, err = filter.apply (ncl)
assert (ncl == nil)
assert (err:match ('/!!!NON_EXISTENT!!!'))
os.remove (tmp)


-- TODO: Circular inclusion.


-- TODO: Multiple inclusions of the same file.


-- Simple resolution (non-recursive).

tmp = util.tmpfile ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d1' transIn=';' transOut='t1;  t2'>
    <descriptorParam name='top' value='30'/>
    <descriptorParam name='left' value='35%'/>
   </descriptor>
   <descriptor id='d2' region='r2'>
    <descriptorParam name='right' value='5'/>
   </descriptor>
   <descriptor id='d3' transIn=' t1;t2;t3 ;  ' transOut='t1 '/>
  </descriptorBase>
  <regionBase>
   <region id='r1' left='13%'/>
   <region id='r2' top='25%'/>
  </regionBase>
  <transitionBase>
  </transitionBase>
 </head>
 <body/>
</ncl>]])

ncl = util.parsenclformat ([[
<ncl>
 <head>
  <regionBase>
   <importBase alias='x' documentURI='%s'/>
  </regionBase>
  <descriptorBase>
   <importBase alias='y' documentURI='%s'/>
  </descriptorBase>
  <transitionBase>
   <importBase alias='z' documentURI='%s'/>
  </transitionBase>
  <connectorBase>
   <importBase alias='w' documentURI='%s'/>
  </connectorBase>
 </head>
</ncl>]], tmp, tmp, tmp, tmp)

ncl = filter.apply (ncl)
assert (ncl:equal (dietncl.parsestring ([[
<ncl>
 <head>
  <regionBase>
   <region id='x#r1' left='13%'/>
   <region id='x#r2' top='25%'/>
  </regionBase>
  <descriptorBase>
   <descriptor id='y#d1' transIn=';' transOut='y#t1;y#t2'>
    <descriptorParam name='top' value='30'/>
    <descriptorParam name='left' value='35%'/>
   </descriptor>
   <descriptor id='y#d2' region='y#r2'>
    <descriptorParam name='right' value='5'/>
   </descriptor>
   <descriptor id='y#d3' transIn='y#t1;y#t2;y#t3;' transOut='y#t1'/>
  </descriptorBase>
  <transitionBase>
  </transitionBase>
  <connectorBase>
  </connectorBase>
 </head>
</ncl>]])))
os.remove (tmp)


-- Simple resolution of external region bases to a local region.

tmp = util.tmpfile ([[
<ncl>
 <head>
  <regionBase id='rb1' device='3'>
   <region id='rb11' top='30%'>
    <region id='rb12' left='44%'/>
   </region>
  </regionBase>
  <regionBase id='rb2'>
   <region id='rb21' width='25%'/>
   <region id='rb22' height='23%'/>
  </regionBase>
  <regionBase id='rb3'>
   <region id='rb31' zIndex='3'/>
   <region id='rb32' zIndex='2'>
    <region id='rb33'/>
   </region>
  </regionBase>
 </head>
 <body/>
</ncl>]])

ncl = util.parsenclformat ([[
<ncl>
 <head>
  <regionBase id='rba'>
   <importBase alias='a' documentURI='%s' baseId='rb1'/>
  </regionBase>
  <regionBase id='rbb'>
   <region id='rbb1'/>
   <region id='rbb2'>
    <region id='rbb3'/>
   </region>
   <importBase alias='b' documentURI='%s' region='rbb3' baseId='rb3'/>
  </regionBase>
  <regionBase id='rbc'>
   <importBase alias='c' documentURI='%s'/>
  </regionase>
 </head>
 <body/>
</ncl>]], tmp, tmp, tmp)

ncl = filter.apply (ncl)
assert (ncl:equal (dietncl.parsestring ([[
<ncl>
 <head>
  <regionBase id='rba'>
   <region id='a#rb11' top='30%'>
    <region id='a#rb12' left='44%'/>
   </region>
  </regionBase>
  <regionBase id='rbb'>
   <region id='rbb1'/>
   <region id='rbb2'>
    <region id='rbb3'>
     <region id='b#rb31' zIndex='3'/>
     <region id='b#rb32' zIndex='2'>
      <region id='b#rb33'/>
     </region>
    </region>
   </region>
  </regionBase>
  <regionBase id='rbc'>
   <region id='c#rb11' top='30%'>
    <region id='c#rb12' left='44%'/>
   </region>
   <region id='c#rb21' width='25%'/>
   <region id='c#rb22' height='23%'/>
   <region id='c#rb31' zIndex='3'/>
   <region id='c#rb32' zIndex='2'>
    <region id='c#rb33'/>
   </region>
  </regionBase>
 </head>
 <body/>
</ncl>]])))
os.remove (tmp)


-- Recursive resolution.

tmp1 = util.tmpfile ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d1' region='r2'>
    <descriptorParam name='top' value='3.5%'/>
   </descriptor>
  </descriptorBase>
  <regionBase>
   <region id='r1' top='34%'>
    <region id='r2' left='44%'/>
   </region>
  </regionBase>
  <connectorBase>
   <causalConnector id='c1'>
    <simpleCondition role='onPause'/>
    <simpleAction role='abort'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body/>
</ncl>]])

tmp2 = util.tmpfile ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c1'>
    <simpleCondition role='onBegin'/>
    <simpleAction role='start'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body/>
</ncl>]])

tmp3 = util.tmpfile (([[
<ncl>
 <head>
  <connectorBase>
   <importBase alias='x' documentURI='%s'/>
   <importBase alias='w' documentURI='%s'/>
  </connectorBase>
  <regionBase device='7'>
   <region id='r3' zIndex='3'/>
   <importBase alias='y' documentURI='%s'/>
  </regionBase>
  <descriptorBase>
   <importBase alias='z' documentURI='%s'/>
  </descriptorBase>
 </head>
 <body/>
</ncl>]]):format (tmp2, tmp1, tmp1, tmp1))

ncl = dietncl.parsestring (([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d2'/>
   <importBase alias='a' documentURI='%s'/>
  </descriptorBase>
  <connectorBase>
   <causalConnector id='c2'>
    <simpleCondition role='onEnd'/>
    <simpleAction role='stop'/>
   </causalConnector>
   <importBase alias='b' documentURI='%s'/>
  </connectorBase>
  <regionBase>
   <importBase alias='c' documentURI='%s'/>
  </regionBase>
 </head>
 <body/>
</ncl>]]):format (tmp1, tmp3, tmp3))

ncl = filter.apply (ncl)
assert (ncl:equal (dietncl.parsestring ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d2'/>
   <descriptor id='a#d1' region='a#r2'>
    <descriptorParam name='top' value='3.5%'/>
   </descriptor>
   <!-- <importBase alias='a' documentURI='%s'/> -->
  </descriptorBase>
  <connectorBase>
   <causalConnector id='c2'>
    <simpleCondition role='onEnd'/>
    <simpleAction role='stop'/>
   </causalConnector>
   <causalConnector id='b#x#c1'>
    <simpleCondition role='onBegin'/>
    <simpleAction role='start'/>
   </causalConnector>
   <causalConnector id='b#w#c1'>
    <simpleCondition role='onPause'/>
    <simpleAction role='abort'/>
   </causalConnector>
   <!-- <importBase alias='b' documentURI='%s'/> -->
  </connectorBase>
  <regionBase>
   <region id='c#r3' zIndex='3'/>
   <region id='c#y#r1' top='34%'>
    <region id='c#y#r2' left='44%'/>
   </region>
   <!-- <importBase alias='c' documentURI='%s'/> -->
  </regionBase>
 </head>
 <body/>
</ncl>
]])))
os.remove (tmp1)
os.remove (tmp2)
os.remove (tmp3)


--========================================================================--
--            Part II -- Checks the resolution of <importNCL>             --
--========================================================================--


-- Invalid 'documentURI' (file not found).

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <importedDocumentBase>
   <importNCL alias='x' documentURI='!!!NON_EXISTENT!!!'/>
  </importedDocumentBase>
 </head>
 <body/>
</ncl>]])
ncl, err = filter.apply (ncl)
assert (ncl == nil)
assert (err:match ('!!!NON_EXISTENT!!!'))

tmp = util.tmpfile ([[
<ncl>
 <head>
  <connectorBase>
   <importBase alias='x' documentURI='/!!!NON_EXISTENT!!!'/>
  </connectorBase>
 </head>
 <body/>
</ncl>]])

ncl = util.parsenclformat ([[
<ncl>
 <head>
  <regionBase>
   <importBase alias='x' documentURI='%s'/>
  </regionbAse>
 </head>
 <body/>
</ncl>]], tmp)
ncl, err = filter.apply (ncl)
assert (ncl == nil)
assert (err:match ('/!!!NON_EXISTENT!!!'))
os.remove (tmp)


-- TODO: Circular inclusion.


-- TODO: Multiple inclusions of the same file.


-- Simple resolution (non-recursive)

tmp = util.tmpfile ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d1' transIn=';' transOut='t1;  t2'>
    <descriptorParam name='top' value='30'/>
    <descriptorParam name='left' value='35%'/>
   </descriptor>
   <descriptor id='d2' region='r2'>
    <descriptorParam name='right' value='5'/>
   </descriptor>
   <descriptor id='d3' transIn=' t1;t2;t3 ;  ' transOut='t1 '/>
  </descriptorBase>
  <regionBase>
   <region id='r1' left='13%'/>
   <region id='r2' top='25%'/>
  </regionBase>
  <transitionBase>
   <transition id='t1' type='barWipe'/>
   <transition id='t2' type='irisWipe'/>
   <transition id='t3' type='fade' dur='5s'/>
  </transitionBase>
  <ruleBase>
   <rule id='r1' var='x' comparator='eq' value='30'/>
   <compositeRule id='r2' operator='and'>
    <rule id='r3' var='x' comparator='ne' value='30'/>
    <rule id='r4' var='y' comparator='eq' value='44'/>
   </compositeRule>
  </ruleBase>
  <regionBase>
   <region id='r3'/>
  </regionBase>
  <connectorBase>
   <causalConnector id='c1'>
    <simpleCondition role='onPause'/>
    <simpleAction role='stop'/>
   </causalConnector>
   <causalConnector id='c2'>
    <simpleCondition role='onEnd'/>
    <simpleAction role='abort'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m1' descriptor='d1'/>
  <context id='m2'>
   <port id='m2p' component='m41'/>
   <switch id='m41'>
    <media id='m411' src='yyy'/>
    <bindRule rule='r4' constituent='m411'/>
   </switch>
  </context>
  <media id='m3' src='xyz'>
   <property top='35px'/>
  </media>
 </body>
</ncl>]])

ncl = util.parsenclformat ([[
<ncl>
 <head>
  <importedDocumentBase>
   <importNCL alias='x' documentURI='%s'/>
  </importedDocumentBase>
  <transitionBase/>
 </head>
 <body>
  <media id='w1' refer='x#m3'/>
  <media id='w2' descriptor='x#d1' refer='w1' instance='gradSame'/>
  <media id='w3' refer='x#m1'/>
  <context id='w4' refer='x#m2'>
  </context>
 </body>
</ncl>]], tmp)

ncl = filter.apply (ncl)
assert (ncl:equal (ncl, dietncl.parsestring ([[
<ncl>
 <head>
  <!-- <importedDocumentBase> -->
   <!-- <importNCL alias='x' documentURI='%s'/> -->
  <!-- </importedDocumentBase> -->
  <transitionBase>
   <transition id='x#t1' type='barWipe'/>
   <transition id='x#t2' type='irisWipe'/>
   <transition id='x#t3' type='fade' dur='5s'/>
  </transitionBase>
  <connectorBase>
   <causalConnector id='x#c1'>
    <simpleCondition role='onPause'/>
    <simpleAction role='stop'/>
   </causalConnector>
   <causalConnector id='x#c2'>
    <simpleCondition role='onEnd'/>
    <simpleAction role='abort'/>
   </causalConnector>
  </connectorBase>
  <descriptorBase>
   <descriptor id='x#d1' transIn=';' transOut='x#t1;x#t2'>
    <descriptorParam name='top' value='30'/>
    <descriptorParam name='left' value='35%'/>
   </descriptor>
   <descriptor id='x#d2' region='x#r2'>
    <descriptorParam name='right' value='5'/>
   </descriptor>
   <descriptor id='x#d3' transIn='x#t1;x#t2;x#t3;' transOut='x#t1'/>
  </descriptorBase>
  <regionBase>
   <region id='x#r1' left='13%'/>
   <region id='x#r2' top='25%'/>
   <region id='x#r3'/>
  </regionBase>
  <ruleBase>
   <rule id='x#r1' var='x' comparator='eq' value='30'/>
   <compositeRule id='x#r2' operator='and'>
    <rule id='x#r3' var='x' comparator='ne' value='30'/>
    <rule id='x#r4' var='y' comparator='eq' value='44'/>
   </compositeRule>
  </ruleBase>
 </head>
 <body>
  <!-- <media id='w1' refer='x#m3'/> -->
  <media id='w1' src='xyz'>
   <property top='35px'/>
  </media>
  <media id='w2' descriptor='x#d1' refer='w1' instance='gradSame'/>
  <!-- <media id='w3' refer='x#m1'/> -->
  <media id='w3' descriptor='x#d1'/>
  <!-- <context id='w4' refer='m2'> -->
  <context id='w4'>
   <port id='x#m2p' component='x#m41'/>
   <switch id='x#m41'>
    <media id='x#m411' src='yyy'/>
    <bindRule rule='x#r4' constituent='x#m411'/>
   </switch>
  </context>
 </body>
</ncl>]])))
os.remove (tmp)
