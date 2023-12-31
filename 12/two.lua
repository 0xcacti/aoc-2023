function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function parseInput()
    io.input("input.txt")

    lines = {}
    for line in io.lines() do
        split = mysplit(line, " ")
        originalChunks = mysplit(split[2], ",")

        lastI = 1
        len = #originalChunks * 5
        local chunks = {}
        for i = 1, len do
            local chunk = originalChunks[(i - 1) % #originalChunks + 1]
            chunks[i] = tonumber(chunk)
            print(i, chunk)
        end
        print()
        local line = ""
        for i = 1, 4 do
            line = line .. split[1] .. "?"
        end
        line = line .. split[1] .. "."
        print(line)
        for i = 1, #chunks do
            io.write(chunks[i] .. " ")
        end
        print()
        table.insert(lines, { line, chunks })
    end
    return lines
end

function getNewGroup(group)
    if group == nil or #group <= 1 then -- Adjusted to check for single-element group
        return nil
    end

    newGroup = {}
    for i = 2, #group do
        table.insert(newGroup, group[i])
    end
    return newGroup
end

local memo = {}
local function createKey(line, groups, size)
    local groupsKey = table.concat(groups or {}, ",")
    return line .. ":" .. groupsKey .. ":" .. tostring(size)
end

function recurse(line, groups, size)
    size = size or 0
    local key = createKey(line, groups, size)
    if memo[key] then
        return memo[key]
    end


    if line == "" or line == nil then
        if (groups == nil or #groups == 0) and (size == 0) then
            memo[key] = 1
            return 1
        else
            memo[key] = 0
            return 0
        end
    end

    local lineSolutions = 0
    local symbols = (line:sub(1, 1) == '?') and { '.', '#' } or { line:sub(1, 1) }

    for _, sym in ipairs(symbols) do
        if sym == '#' then
            lineSolutions = lineSolutions + recurse(line:sub(2), groups, size + 1)
        else
            if size > 0 then
                if groups and #groups > 0 and groups[1] == size then
                    lineSolutions = lineSolutions + recurse(line:sub(2), getNewGroup(groups), 0)
                end
            else
                lineSolutions = lineSolutions + recurse(line:sub(2), groups, 0)
            end
        end
    end
    memo[key] = lineSolutions
    return lineSolutions
end

function solve()
    print("Solving...")
    local lines = parseInput()
    local count = 0
    for i, line in ipairs(lines) do
        ret = recurse(line[1], line[2], 0)
        print(ret)
        count = count + ret
    end
    return count
end

print(solve())
