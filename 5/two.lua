local M = {}


-- Read the first lines
function M.mysplit(inputstr, sep)
    if sep == nil then
        sep = "\n\n" -- Default to splitting on empty lines
    end
    local t = {}
    local start = 1
    local sepStart, sepEnd = string.find(inputstr, sep, start)
    while sepStart do
        table.insert(t, string.sub(inputstr, start, sepStart - 1))
        start = sepEnd + 1
        sepStart, sepEnd = string.find(inputstr, sep, start)
    end
    table.insert(t, string.sub(inputstr, start)) -- Add the last segment
    return t
end

function M.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

M.map_range = function(seed_start, seed_end, dest_low, source_low, interval)
    seed_start = tonumber(seed_start)
    seed_end = tonumber(seed_end)
    interval = tonumber(interval)

    local dest_start = tonumber(dest_low)
    local dest_end = dest_start + interval
    local source_start = tonumber(source_low)
    local source_end = source_low + interval - 1

    if not (seed_start and seed_end and interval and dest_start and dest_end and source_start and source_end) then
        return nil, nil
    end

    print("seed interval: " .. seed_start .. "->" .. seed_end)
    print("source interval: " .. source_start .. "->" .. source_end)
    if seed_end < source_start or seed_start > source_end then
        return nil, { seed_start, seed_end - seed_start + 1 }
    end


    local overlap_start = math.max(seed_start, source_start)
    local overlap_end = math.min(seed_end, source_end)


    -- dest_low + (value - source_low)
    local mapped_start = dest_start + (overlap_start - source_start)
    local mapped_end = dest_start + (overlap_end - source_start)
    local mapped_interval = mapped_end - mapped_start + 1

    local mapped = { mapped_start, mapped_interval }
    print("mapped: " .. mapped[1] .. " " .. mapped[2])

    -- check if it's a subset
    if seed_start == overlap_start and seed_end == overlap_end then
        print("we return out of here")
        return mapped, nil
    end

    local unmapped = {}
    if seed_start < overlap_start then
        print("lower exclusion")
        local lower_unmapped = seed_start
        local lower_interval = (overlap_start - seed_start)
        table.insert(unmapped, lower_unmapped)
        table.insert(unmapped, lower_interval)
    end

    if overlap_end < seed_end then
        print("upper exclusion")
        local upper_unmapped = overlap_end + 1
        local upper_interval = (seed_end - upper_unmapped) + 1
        table.insert(unmapped, upper_unmapped)
        table.insert(unmapped, upper_interval)
    end

    print("we are in here")
    return mapped, unmapped
end

M.reconstructUnmapped = function(mapped, start, stop)
    local unmapped = {}
    start = tonumber(start)
    stop = tonumber(stop)

    for i = 1, #mapped, 2 do
        print(mapped[i] .. " " .. mapped[i + 1])
        local mapped_start = mapped[1]
        local mapped_stop = mapped[1] + mapped[2] - 1

        if mapped_start > start then
            local lower_unmapped = start
            -- 1 2 3 4 5
            local lower_interval = mapped_start - start
            table.insert(unmapped, lower_unmapped)
            table.insert(unmapped, lower_interval)
        end
        start = mapped_stop + 1
    end


    local mapped_start = mapped[#mapped] - 1
    local mapped_stop = mapped_start + mapped[#mapped] - 1
    if mapped_stop < stop then
        local upper_unmapped = mapped_stop + 1
        local upper_interval = stop - upper_unmapped + 1
        table.insert(unmapped, upper_unmapped)
        table.insert(unmapped, upper_interval)
    end
    return unmapped
end

M.mapRange = function(current_map, start, stop)
    print("--- mapRange ---")
    local mapped = {}
    local unmapped = {}

    for k = 1, #current_map do
        print("map entry: " .. current_map[k])
        local entry = current_map[k]
        local entry_parts = M.split(entry, " ")
        local entry_mapped, _ = M.map_range(start, stop, entry_parts[1], entry_parts[2],
            entry_parts[3])

        if entry_mapped then
            mapped = M.insertIntoMap(mapped, entry_mapped)
        end
    end

    if #mapped ~= 0 then
        unmapped = M.reconstructUnmapped(mapped, start, stop)
    end


    M.insertIntoMap(mapped, unmapped)

    return mapped, unmapped
end

M.insertIntoMap = function(map, ranges)
    for i = 1, #ranges do
        table.insert(map, ranges[i])
    end
    return map
end

M.solve = function()
    -- get input
    io.input("test_input.txt")

    -- read seed line and get seeds
    local line = io.read()
    line = M.mysplit(line, ":")[2]
    line = string.sub(line, 2)
    local seed_ranges = M.mysplit(line, " ")

    -- skip blank line
    _ = io.read()

    -- read map lines and get all maps
    local file = io.read("*all")

    -- extract and normalize maps
    local maps = M.mysplit(file, "\n\n")
    for i = 1, #maps do
        maps[i] = M.split(maps[i], "\n")
        local fixed_map = {}
        for j = 2, #maps[i] do
            fixed_map[j - 1] = maps[i][j]
        end
        maps[i] = fixed_map
    end

    -- loop over each seed range
    for i = 1, #maps do
        print("map " .. i)
        local mapped = {}
        for j = 1, #seed_ranges, 2 do
            local start = seed_ranges[j]
            local stop = seed_ranges[j] + seed_ranges[j + 1] - 1
            print("performing iterations for seed range " .. start .. " " .. seed_ranges[j + 1])
            local r1_mapped, _ = M.mapRange(maps[i], start, stop)

            if r1_mapped then
                mapped = M.insertIntoMap(mapped, r1_mapped)
            end
        end

        if mapped ~= {} then
            seed_ranges = mapped
        end
    end

    print("final seed ranges")
    -- for i = 1, #seed_ranges, 2 do
    --     print(seed_ranges[i] .. " " .. seed_ranges[i + 1])
    -- end
end

print(M.solve())
-- return M
