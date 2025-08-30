LB News – News App für LB-Phone (FiveM)

Überblick
- Dunkelgrau/Orange News-App mit Header und breitem Logo
- Beiträge erstellen mit Bild, Kategorie, Autor und Uhrzeit
- Einträge werden im einfachen Block-Design gelistet (neueste zuerst)
- Dropdown-Filter nach Kategorie
- Persistenz als JSON-Datei auf dem Server

Inhalt
- Ressourcenname: `lb-news`
- Client: `client/main.lua`
- Server: `server/main.lua`
- NUI: `html/index.html`, `html/style.css`, `html/app.js`, `html/logo.svg`
- Daten: `data/posts.json`

Installation
1) Ordner `lb-news` in deinen FiveM resources-Ordner kopieren.
2) In der `server.cfg` sicherstellen:
   ensure lb-news
3) Server neu starten.
4) Im Spiel mit Taste F7 oder Befehl `/news` öffnen.

Funktionen
- Beiträge: Titel, Einleitung, Kategorie, Autor, optional Bild-URL/Base64
- Zeitstempel: automatisch (z. B. 2025-08-28 14:35)
- Sortierung: neueste Beiträge oben
- Filter: Dropdown „Alle Kategorien“ oder spezifische Kategorie
- Galerie: Button „Aus Galerie wählen“ triggert Event zum Abruf eines Bildes vom Phone

Persistenz
- Server speichert Beiträge in `data/posts.json` im Ressourcenordner.
- Datei wird automatisch angelegt, falls nicht vorhanden.

Integration mit LB-Phone
Öffnen der App aus dem Phone
- Der Client-Event `lb_news:open` öffnet die News-Oberfläche.
- Beispiel (Client, irgendwo in deinem Phone-„App öffnen“-Handler):
```lua
-- Öffnet die News-App
TriggerEvent('lb_news:open')
```

Bild aus Galerie/Kamera an die News-App übergeben
- Wenn der Nutzer in der News-App „Aus Galerie wählen“ klickt, sendet die App eine NUI-Callback-Anfrage, die auf Clientseite das Event `lb_news:requestGalleryImage` auslöst.
- Dein Phone-/Galerie-Resource sollte dieses Event abfangen, Bild auswählen und dann das Bild an die News-App zurückgeben:
```lua
-- Beispiel (Client) – Pseudocode, an dein Phone-Framework anpassen
AddEventHandler('lb_news:requestGalleryImage', function()
	-- 1) Galerie/Kamera deines Phones öffnen
	-- 2) Bild-URL oder Base64 ermitteln, z. B. imageData
	local imageData = nil
	-- imageData = exports['dein-phone']:SelectImage() -- PSEUDO
	-- imageData = 'https://server/pfad/zu/bild.jpg' oder 'data:image/png;base64,...'
	if imageData then
		TriggerEvent('lb_news:setSelectedImage', imageData)
	end
end)
```

Berechtigungen (optional)
- Standardmäßig kann jeder Spieler Beiträge erstellen.
- Um dies einzuschränken (z. B. nur Job „Weazel“), erweitere im Server-Skript `lb_news:createPost` die Prüfung des Spielers (Framework-spezifisch ESX/QBCore).

Styling
- Farbschema: Dunkelgrau (#121212/#1a1a1a) mit Orange (#ff7a00).
- Header mit horizontalem Logo über die gesamte Breite.

Tastenbelegung ändern
- Der Befehl `news` ist einer Keybinding-Aktion zugewiesen: `RegisterKeyMapping('news', 'Open News App', 'keyboard', 'F7')`.
- Im FiveM Keybindings-Menü kann die Taste geändert werden.

Events & NUI-Callbacks (Kurzreferenz)
- Client-Events
  - `lb_news:open`: Öffnet die App
  - `lb_news:postsUpdated` (server -> client): Aktualisiert Post-Liste
  - `lb_news:requestGalleryImage` (client, von NUI ausgelöst): Bitte ein Bild liefern
  - `lb_news:setSelectedImage` (client): Übergibt ein Bild zurück an die NUI
- Server-Events
  - `lb_news:requestPosts` (client -> server): Posts abrufen
  - `lb_news:createPost` (client -> server): Post erstellen/speichern
- NUI-Callbacks
  - `requestPosts`, `createPost`, `close`, `selectGallery`

Hinweise
- Für reines Standalone-Testing kann `html/index.html` im Browser geöffnet werden (eingeschränkter Modus ohne FiveM-Funktionen).
- In Produktion Bilder möglichst via URL oder Phone-Galerie/Base64 zuliefern.