local isOpen = false
local postsCache = {}
local hasCreatePermission = false

local function openUI()
	if isOpen then return end
	isOpen = true
	SetNuiFocus(true, true)
	SendNUIMessage({ type = 'open', author = GetPlayerName(PlayerId()) })
	TriggerServerEvent('lb_news:requestInitial')
end

local function closeUI()
	if not isOpen then return end
	isOpen = false
	SetNuiFocus(false, false)
	SendNUIMessage({ type = 'close' })
end

RegisterNetEvent('lb_news:open', function()
	openUI()
end)

RegisterNetEvent('lb_news:postsUpdated', function(data)
	local defaultCategories = {}
	if type(data) == 'table' and data.posts then
		postsCache = data.posts or {}
		defaultCategories = data.defaultCategories or {}
	else
		postsCache = data or {}
	end
	SendNUIMessage({ type = 'posts', posts = postsCache, defaultCategories = defaultCategories })
end)

RegisterNetEvent('lb_news:initialData', function(data)
	data = data or {}
	postsCache = data.posts or {}
	hasCreatePermission = data.isReporter or false
	local defaults = data.defaultCategories or {}
	SendNUIMessage({ type = 'permissions', canCreate = hasCreatePermission })
	SendNUIMessage({ type = 'posts', posts = postsCache, defaultCategories = defaults })
end)

RegisterNUICallback('requestPosts', function(_, cb)
	cb({ ok = true, posts = postsCache })
end)

RegisterNUICallback('createPost', function(data, cb)
	TriggerServerEvent('lb_news:createPost', data or {})
	cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
	closeUI()
	cb({ ok = true })
end)

-- Gallery selection hook - to be provided by LB-Phone if available
RegisterNUICallback('selectGallery', function(_, cb)
	TriggerEvent('lb_news:requestGalleryImage')
	cb({ ok = true })
end)

-- Optional: LB-Phone or another resource can send back a selected image URL/base64
RegisterNetEvent('lb_news:setSelectedImage', function(image)
	SendNUIMessage({ type = 'selectedImage', image = image })
end)


-- LB-Phone integration bridge: register app on compatible phones (no hard version dependency)
CreateThread(function()
    Wait(1500)
    if GetResourceState('lb-phone') == 'started' then
        -- Try a generic registration event/name; adjust if your phone uses a different API
        TriggerEvent('lb_phone:registerApp', {
            name = 'lb-news',
            label = 'News',
            icon = 'fa-solid fa-newspaper',
            open = function()
                TriggerEvent('lb_news:open')
            end,
            permission = 'all' -- viewing allowed; creation is enforced server-side by job
        })
    end
end)

