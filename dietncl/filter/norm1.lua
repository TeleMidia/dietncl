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

local function collect_statements (parent, collection, count)
	if parent:parent() then
		for element in parent:parent():gmatch ('assessmentStatement') do
			if element:parent() == parent:parent() then
				collection[count] = element:clone()
				count = count + 1
			end
		end

		if collection[count-1] then
			return collect_statements (parent:parent(), collection, count)
		end

		return collection, count
	else
		return collection, count
	end

end

function filter.apply (ncl)
	local condition = true

	while condition == true do
		local conn_list = {ncl:match ('causalConnector')}
		condition = false
		for index, conn in ipairs (conn_list) do
			local first_stat

			--[==[for first in conn:gmatch ('compoundStatement') do
				if first:parent() == conn then
					first_stat = xml.remove (first:parent(), first)
				end
			end

			if first_stat == nil then
				for first in conn:gmatch ('assessmentStatement') do
					if first:parent() == conn then
						first_stat = xml.remove (first:parent(), first)
					end
				end
			end]==]--

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

			local comp = {conn:match ('compoundCondition')}
			local control = 0
			for i, element in ipairs (comp) do
				if #element == 2 and element:parent().operator == 'or' and (element[1]:tag() == 'simpleCondition' or element[2]:tag() == 'simpleCondition') then
					local collection = {}
					local count = 1

					for child in element:parent():gmatch ('compoundStatement') do
						if child:parent() == element:parent() then
							if control == 1 then
								collection[count] = xml.remove (child:parent(), child)
								control = 0
							else
								collection[count] = child
								control = control + 1
						--	end
						end
					end

					for child in element:parent():gmatch ('assessmentStatement') do
						if child:parent() == element:parent() then
							--if control == 1 then
								collection[count] = xml.remove (child:parent(), child)
								--control = 0
							--else
								--collection[count] = child
								--control = control + 1
							--end
						end
					end

					collection, count = collect_statements (element:parent(), collection, count)

					condition = true

					element = xml.remove (element:parent(), element)

					for index, stats in ipairs (collection) do
						element:insert (stats:clone())
					end

					print(element)

					local statements = {}
					local i = 1
					for statement in element:gmatch ('assessmentStatement') do
						if statement:parent() == element or statement:parent():parent() == element then
							if #statement:parent() == 1 then
								statements[i] = xml.remove (statement:parent(), statement)
								xml.remove (statement:parent())
							else
								statements[i] = xml.remove (statement:parent(), statement)
							end
							i = i + 1
						end
					end

					if #statements > 1 then
						local new_compound = xml.new ('compoundStatement')
						new_compound.operator = 'eq'
						for index, stats in ipairs (statements) do
							new_compound:insert (stats)
						end

						--[==[if first_stat then
							if first_stat:tag() == 'assessmentStatement' then
								new_compound:insert (first_stat:clone())
							elseif first_stat:tag() == 'compoundStatement' then
								for index, supreme_stat in ipairs (first_stat) do
									supreme_stat = xml.remove (supreme_stat:parent(), supreme_stat)
									new_compound:insert (supreme_stat)
								end
							end
						end
						]==]--

						element:insert (new_compound)

						--[==[elseif copy:tag() == 'compoundStatement' then
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
						]==]--
					elseif #statements == 1 then
						local new_compound = xml.new ('compoundStatement')
						new_compound.operator = 'eq'
						new_compound:insert (statements[1])
						element:insert (new_compound)
					end

					local connector = xml.new ('causalConnector')
					connector.id = aux.gen_id (ncl)
					connector:insert (element)
					if action then
						connector:insert (action:clone())
					end
					conn:parent():insert (connector)
				end

				if #element == 0 then
					xml.remove (element:parent():parent(), element:parent())
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

