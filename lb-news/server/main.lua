local resourceName = GetCurrentResourceName()
local posts = {}
local Config = Config or {}

-- framework handles
local ESX
local QBCore

local function detectFramework()
	if not ESX and GetResourceState('es_extended') == 'started' then
		if exports and exports['es_extended'] and exports['es_extended'].getSharedObject then
			ESX = exports['es_extended']:getSharedObject()
		else
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		end
	end
	if not QBCore and GetResourceState('qb-core') == 'started' then
		if exports and exports['qb-core'] and exports['qb-core'].GetCoreObject then
			QBCore = exports['qb-core']:GetCoreObject()
		end
	end
end

local function playerIsReporter(src)
	detectFramework()
	local wanted = (Config.ReporterJobName or 'reporter')
	if QBCore then
		local player = QBCore.Functions.GetPlayer(src)
		if player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name then
			return string.lower(player.PlayerData.job.name) == string.lower(wanted)
		end
	end
	if ESX then
		local xPlayer = ESX.GetPlayerFromId(src)
		if xPlayer and xPlayer.job and xPlayer.job.name then
			return string.lower(xPlayer.job.name) == string.lower(wanted)
		end
	end
	return false
end

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
	TriggerClientEvent('lb_news:postsUpdated', src, { posts = posts, defaultCategories = (Config.DefaultCategories or {}) })
end)

RegisterNetEvent('lb_news:requestInitial', function()
	local src = source
	local isReporter = playerIsReporter(src)
	TriggerClientEvent('lb_news:initialData', src, { posts = posts, isReporter = isReporter, defaultCategories = (Config.DefaultCategories or {}) })
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
	if not playerIsReporter(src) then return end
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
	TriggerClientEvent('lb_news:postsUpdated', -1, { posts = posts, defaultCategories = (Config.DefaultCategories or {}) })
end)

