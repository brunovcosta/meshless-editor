local export = {}

function export.points(points)
	local p = #points

	local cross = function(p, q, r)
		return (q[2] - p[2]) * (r[1] - q[1]) - (q[1] - p[1]) * (r[2] - q[2])
	end

	table.sort(points, function(a, b)
		return a[1] == b[1] and a[2] > b[2] or a[1] > b[1]
	end)

	local lower = {}
	for i = 1, p do
		while (#lower >= 2 and cross(lower[#lower - 1], lower[#lower], points[i]) <= 0) do
			table.remove(lower, #lower)
		end

		table.insert(lower, points[i])
	end

	local upper = {}
	for i = p, 1, -1 do
		while (#upper >= 2 and cross(upper[#upper - 1], upper[#upper], points[i]) <= 0) do
			table.remove(upper, #upper)
		end

		table.insert(upper, points[i])
	end

	table.remove(upper, #upper)
	table.remove(lower, #lower)
	for _, point in ipairs(lower) do
		table.insert(upper, point)
	end

	return upper
end

return export
