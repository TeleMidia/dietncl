--[[ norm1.lua -- First Normal Form implementation.
     Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia

This file is part of DietNCL.

DietNCL is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your
option) any later version.

DietNCL is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with DietNCL.  If not, see <http://www.gnu.org/licenses/>.  ]]--

-- The NORM1-2 filters simplify links and connectors from a given NCL
-- document. This filter NORM1, under the First Normal Form (NF1), guarantees
-- that for any ABS program S there is an equivalent program S' such that each link L
-- of S' has condition and action degrees zero.
--
-- Depends: PRENORM5.

local filter = {}

local ipairs = ipairs
local print = print

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

function filter.apply (ncl)
	local condition = true

	while condition == true do
		local conn_list = {ncl:match ('causalConnector')}
		condition = false
		for index, conn in ipairs (conn_list) do
			local first_stat

			for first in conn:gmatch ('compound') do
				if first:parent() == conn then
					first_stat = xml.remove (first:parnet(), first)
				end
			end

			if first_stat == nil then
				for first in conn:gmatch ('assessmentStatement') do
					if first:parent() == conn then
						first_stat = xml.remove (first:parent(), first)
					end
				end
			end


			local comp = {conn:match ('compoundCondition')}
			for i, element in ipairs (comp) do
				local copy
				if #element == 3 and element.operator == 'or' then

					local action
					for action_root in conn:gmatch ('compoundAction') do
						if action_root:parent() == conn then
							action = xml.remove (action_root:parent(), action_root)
						end
					end

					if action == nil then
						for action_root in conn:gmatch ('simpleAction') do
							if action_root:parent() == conn then
								action = xml.remove (action_root:parent(), action_root)
							end
						end
					end

					if copy == nil then
						for child in element:gmatch ('compoundStatement') do
							if child:parent() == element then
								copy = xml.remove (child:parent(), child)
							end
						end
					end

					for child in element:gmatch ('assessmentStatement') do
						if child:parent() == element then
							copy = xml.remove (child:parent(), child)
						end
					end

					condition = true

					for compound in element:gmatch ('compoundCondition') do
						if compound:parent() == element then
							compound = xml.remove (compound:parent(), compound)
							compound:insert (copy:clone())

							local statements = {}
							local i = 1
							for statement in compound:gmatch (copy:tag()) do
								if statement:parent() == compound then
									statements[i] = statement
									i = i +1
								end
							end

							if #statements == 2 then
								if copy:tag() == 'assessmentStatement' then
									local new_compound = xml.new ('compoundStatement')
									new_compound.operator = 'eq'
									local transfer = xml.remove (statements[1]:parent(), statements[1])
									new_compound:insert (transfer)
									transfer = xml.remove (statements[2]:parent(), statements[2])
									new_compound:insert (transfer)

									if first_stat then
										if first_stat:tag() == 'assessmentStatement' then
											new_compound:insert (first_stat:clone())
										elseif first_stat:tag() == 'compoundStatement' then
											for index, supreme_stat in ipairs (first_stat) do
												supreme_stat = xml.remove (supreme_stat:parent(), supreme_stat)
												new_compound:insert (supreme_stat)
											end
										end
									end

									compound:insert (new_compound)


								elseif copy:tag() == 'compoundStatement' then
									for i, stats in ipairs (statements[1]) do
										local transfer = xml.remove (stats:parent(), stats)
										statements[2]:insert (transfer)
									end

									if first_stat then
										if first_stat:tag() == 'assessmentStatement' then
											statements[2]:insert (first_stat:clone())
										elseif first_stat:tag() == 'compoundStatement' then
											for index, supreme_stat in ipairs (first_stat) do
												supreme_stat = xml.remove (supreme_stat:parent(), supreme_stat)
												statements[2]:insert (supreme_stat)
											end
										end
									end
								end
							end

							local connector = xml.new ('causalConnector')
							connector.id = aux.gen_id (ncl)
							connector:insert (compound)
							if action then
								connector:insert (action:clone())
							end
							conn:parent():insert (connector)
						end
					end
				end

				if #element == 0 then
					xml.remove (element:parent(), element)
				end

			end

			if #conn == 0 then
				xml.remove (conn:parent(), conn)
			end

		end
	end

	return ncl

end

return filter
