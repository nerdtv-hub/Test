local isOpen = false
local postsCache = {}

local function openUI()
	if isOpen then return end
	isOpen = true
	SetNuiFocus(true, true)
	SendNUIMessage({ type = 'open', author = GetPlayerName(PlayerId()) })
	TriggerServerEvent('lb_news:requestPosts')
end

local function closeUI()
	if not isOpen then return end
	isOpen = false
	SetNuiFocus(false, false)
	SendNUIMessage({ type = 'close' })
end

RegisterCommand('news', function()
	if isOpen then
		closeUI()
	else
		openUI()
	end
end)

RegisterKeyMapping('news', 'Open News App', 'keyboard', 'F7')

RegisterNetEvent('lb_news:open', function()
	openUI()
end)

RegisterNetEvent('lb_news:postsUpdated', function(posts)
	postsCache = posts or {}
	SendNUIMessage({ type = 'posts', posts = postsCache })
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

