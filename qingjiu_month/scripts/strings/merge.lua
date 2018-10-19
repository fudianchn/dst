local function merge(t1, t2)
	for k,v in pairs(t2) do
		local selftype = type(t1[k])
		if selftype == "nil" then
			t1[k] = v
		elseif type(v) == "table" then
			if selftype ~= "table" then
				t1[k] = {}
			end
			merge(t1[k], v)
		end
	end
	return t1
end

return merge