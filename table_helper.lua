local export = {}

function export.flatten(arr)
	local result = { }

	local function flatten(arr)
		for _, v in ipairs(arr) do
			if type(v) == "table" then
				flatten(v)
			else
				table.insert(result, v)
			end
		end
	end

	flatten(arr)
	return result
end

return export
