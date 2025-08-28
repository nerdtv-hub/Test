local resourceName = GetCurrentResourceName()
local posts = {}

local function readFile(path)
	local content = LoadResourceFile(resourceName, path)
	return content
end

local function writeFile(path, data)
	SaveResourceFile(resourceName, path, data, -1)
end

local function ensureDataFile()
	local content = readFile('data/posts.json')
	if not content or content == '' then
		writeFile('data/posts.json', '[]')
	end
end

local function loadPosts()
	ensureDataFile()
	local content = readFile('data/posts.json')
	local ok, decoded = pcall(json.decode, content)
	if ok and type(decoded) == 'table' then
		posts = decoded
	else
		posts = {}
	end
end

local function savePosts()
	-- sort newest first by timestamp
	table.sort(posts, function(a, b)
		return (a.timestamp or 0) > (b.timestamp or 0)
	end)
	writeFile('data/posts.json', json.encode(posts, { indent = true }))
end

AddEventHandler('onResourceStart', function(res)
	if res ~= resourceName then return end
	ensureDataFile()
	loadPosts()
end)

RegisterNetEvent('lb_news:requestPosts', function()
	local src = source
	TriggerClientEvent('lb_news:postsUpdated', src, posts)
end)

local function sanitizeString(s)
	if type(s) ~= 'string' then return '' end
	-- prevent extremely long strings
	if #s > 4000 then
		return s:sub(1, 4000)
	end
	return s
end

RegisterNetEvent('lb_news:createPost', function(data)
	local src = source
	if type(data) ~= 'table' then return end
	local title = sanitizeString(data.title)
	local intro = sanitizeString(data.intro)
	local content = sanitizeString(data.content)
	local category = sanitizeString(data.category)
	local author = sanitizeString(data.author)
	local image = sanitizeString(data.image)

	if title == '' or intro == '' or category == '' or author == '' then
		-- ignore invalid
		return
	end

	local now = os.time()
	local displayTime = os.date('%Y-%m-%d %H:%M', now)
	local post = {
		id = ('%d_%d'):format(now, math.random(1000, 9999)),
		title = title,
		intro = intro,
		content = content,
		category = category,
		author = author,
		image = image,
		timestamp = now,
		time = displayTime
	}

	table.insert(posts, 1, post)
	savePosts()
	TriggerClientEvent('lb_news:postsUpdated', -1, posts)
end)

