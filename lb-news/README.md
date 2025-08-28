LB News – Integration in LB-Phone

Icons & Home Grid Entry
- Füge in deiner LB-Phone App-Registry eine neue App mit Icon hinzu, die beim Öffnen folgendes auslöst:
```lua
-- Beispiel: In deiner Phone-App-Liste
{
	label = 'News',
	name = 'lb-news',
	icon = 'fa-solid fa-newspaper', -- oder eigenes Icon
	action = function()
		TriggerEvent('lb_news:open')
	end
}
```

Permissions
- Erstellen ist nur für Spieler mit Job `reporter` (konfigurierbar in `config.lua`).
- Nicht-Reporter sehen nur Beiträge und die Kategorieauswahl, der Button „Neuer Beitrag“ wird ausgeblendet.

Galerie/Kamera
- Wenn der Nutzer „Aus Galerie wählen“ klickt, feuert Client-Event `lb_news:requestGalleryImage`.
- Übergib danach das gewählte Bild zurück:
```lua
-- Dein Phone/Galerie-Resource
AddEventHandler('lb_news:requestGalleryImage', function()
	-- öffne Galerie/Kamera deines Phones und erhalte Bild als URL/Base64
	local image = nil -- z. B. exports['phone']:PickImage()
	if image then
		TriggerEvent('lb_news:setSelectedImage', image)
	end
end)
```

Hinweise
- Default-Kategorien: Events, Werbung, News, Jobanzeigen (konfigurierbar).
- Die App ist nicht mehr via Command/Keybind erreichbar, sondern nur über das Phone-Event `lb_news:open`.
