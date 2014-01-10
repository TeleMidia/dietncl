-- test-filter-transition.lua -- Checks filter.transition.
-- Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia
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
filter = require ('dietncl.filter.transition')
util   = require ('util')


-- Ignore the content of expanded transitions; i.e., everything between
-- balanced parenthesis.

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d1' transIn='t1;(x()y()z);t2;'/>
  </descriptorBase>
  <transitionBase>
   <transition id='t1' type='barWipe'/>
   <transition id='t2' type='fade'/>
  </transitionBase>
 </head>
</ncl>
]])
filter.apply (ncl)

assert (util.uequal (ncl, dietncl.parsestring ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d1'>
    <descriptorParam name='transIn' value='(barWipe,leftToRight,1s,0,1,forward,black,1,1,0,black);(x()y()z);(fade,crossfade,1s,0,1,forward,black,1,1,0,black)'/>
   </descriptor>
  </descriptorBase>
 </head>
</ncl>]])))


-- A bigger sample.

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <transitionBase>
   <transition id='t1' type='fade' duration='3s'/>
   <transition id='t2' type='barWipe' borderColor='blue'/>
   <transition id='t3' type='snakeWipe' subtype='topLeftHorizontal'/>
  </transitionBase>
  <descriptorBase>
   <descriptor id='d1' transIn='t1;t2' transOut='t2'/>
   <descriptor id='d2' transOut='t3'/>
   <descriptor id='d3' transIn='t2'>
    <descriptorParam name='transIn' value='t3'/>
    <descriptorParam name='transOut' value='(barWipe,topToBottom,1,3,4,backwards,green,1,1,1,red)'/>
   </descriptor>
   <descriptor id='d4'>
    <descriptorParam name='transIn' value='t2'/>
    <descriptorParam name='transOut' value='t3;;t1; t2'/>
   </descriptor>
  </descriptorBase>
 </head>
 <body>
  <port id='p' component='m1'/>
  <media id='m1'>
   <property name='transIn' value='t2;(barWipe,topToBottom,1,3,4,backwards,green,1,1,1,red);t1' />
   <property name='transOut' value='  (snakeWipe,topLeftHorizontal,3,3,4,backwards,green,1,0,1,red);  t3;;' />
  </media>
  <context id='c'>
   <media id='m2'>
    <property name='transIn' value='t1'/>
    <property name='transIn' value='t1'/>
    <property name='transOut' value='t1; (snakeWipe,topLeftHorizontal,3,3,4,backwards,green,1,0,1,green);;;;;;;;;;;;;'/>
   </media>
  </context>
 </body>
</ncl>
]])
filter.apply (ncl)

assert (util.uequal (ncl, dietncl.parsestring ([[<ncl>
 <head>
  <!--
  <transitionBase>
   <transition id='t1' type='fade' duration='3s'/>
   <transition id='t2' type='barWipe' borderColor='blue'/>
   <transition id='t3' type='snakeWipe' subtype='topLeftHorizontal'/>
  </transitionBase>
  -->
  <descriptorBase>
   <descriptor id='d1'>
    <descriptorParam name='transIn' value='(fade,crossfade,1s,0,1,forward,black,1,1,0,black);(barWipe,leftToRight,1s,0,1,forward,black,1,1,0,blue)'/>
    <descriptorParam name='transOut' value='(barWipe,leftToRight,1s,0,1,forward,black,1,1,0,blue)'/>
   </descriptor>
   <descriptor id='d2'>
    <descriptorParam name='transOut' value='(snakeWipe,topLeftHorizontal,1s,0,1,forward,black,1,1,0,black)'/>
   </descriptor>
   <descriptor id='d3'>
    <descriptorParam name='transIn' value='(snakeWipe,topLeftHorizontal,1s,0,1,forward,black,1,1,0,black)'/>
    <descriptorParam name='transOut' value='(barWipe,topToBottom,1,3,4,backwards,green,1,1,1,red)'/>
   </descriptor>
   <descriptor id='d4'>
    <descriptorParam name='transIn' value='(barWipe,leftToRight,1s,0,1,forward,black,1,1,0,blue)'/>
    <descriptorParam name='transOut' value='(snakeWipe,topLeftHorizontal,1s,0,1,forward,black,1,1,0,black);(fade,crossfade,1s,0,1,forward,black,1,1,0,black);(barWipe,leftToRight,1s,0,1,forward,black,1,1,0,blue)'/>
   </descriptor>
  </descriptorBase>
 </head>
 <body>
  <port id='p' component='m1'/>
  <media id='m1'>
   <property name='transIn' value='(barWipe,leftToRight,1s,0,1,forward,black,1,1,0,blue);(barWipe,topToBottom,1,3,4,backwards,green,1,1,1,red);(fade,crossfade,1s,0,1,forward,black,1,1,0,black)' />
   <property name='transOut' value='(snakeWipe,topLeftHorizontal,3,3,4,backwards,green,1,0,1,red);(snakeWipe,topLeftHorizontal,1s,0,1,forward,black,1,1,0,black)' />
  </media>
  <context id='c'>
   <media id='m2'>
    <property name='transIn' value='(fade,crossfade,1s,0,1,forward,black,1,1,0,black)'/>
    <property name='transIn' value='(fade,crossfade,1s,0,1,forward,black,1,1,0,black)'/>
    <property name='transOut' value='(fade,crossfade,1s,0,1,forward,black,1,1,0,black);(snakeWipe,topLeftHorizontal,3,3,4,backwards,green,1,0,1,green)'/>
   </media>
  </context>
 </body>
</ncl>]])))
