-- test-nclaux-gen-id.lua -- Checks nclaux.gen_id.
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
aux = require ('dietncl.nclaux')
ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <regionBase>
   <region id='region0'/>
   <region id='region1'/>
   <region id='region2'/>
  </regionBase>
 </head>
 <body>
  <port id='port0' component='media0'/>
  <media id='xxxxxxxxxx'/>
 </body>
</ncl>]])

aux.gen_id (ncl)

prefix = ncl:getuserdata ('gen-id-prefix')
assert (#prefix == string.len ('xxxxxxxxxx') + 1)

for i=1,999 do
   assert (aux.gen_id (ncl) == prefix..i)
end
