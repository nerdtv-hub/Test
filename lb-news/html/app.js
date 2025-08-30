const root = document.getElementById('root');
const postsContainer = document.getElementById('posts');
const newPostBtn = document.getElementById('newPostBtn');
const closeBtn = document.getElementById('closeBtn');
const newPostCard = document.getElementById('newPost');
const cancelPostBtn = document.getElementById('cancelPost');
const postForm = document.getElementById('postForm');
const categoryFilter = document.getElementById('categoryFilter');
const categoriesList = document.getElementById('categoriesList');
const galleryBtn = document.getElementById('galleryBtn');

let allPosts = [];
let currentAuthor = '';
let canCreate = false;

function nuiSend(name, data) {
	if (typeof GetParentResourceName === 'function') {
		fetch(`https://${GetParentResourceName()}/${name}`, {
			method: 'POST',
			headers: { 'Content-Type': 'application/json; charset=UTF-8' },
			body: JSON.stringify(data || {})
		});
	}
}

function renderCategories(defaults) {
	const categories = Array.from(new Set([
		...(Array.isArray(defaults) ? defaults : []),
		...allPosts.map(p => p.category).filter(Boolean)
	])).filter(Boolean).sort();
	categoryFilter.innerHTML = '<option value="">Alle Kategorien</option>' + categories.map(c => `<option value="${c}">${c}</option>`).join('');
	categoriesList.innerHTML = categories.map(c => `<option value="${c}">`).join('');
}

function renderPosts() {
	const filter = categoryFilter.value;
	let items = allPosts.slice();
	if (filter) items = items.filter(p => p.category === filter);
	items.sort((a, b) => (b.timestamp || 0) - (a.timestamp || 0));
	postsContainer.innerHTML = items.map(post => `
		<article class="post">
			${post.image ? `<img class="image" src="${post.image}" alt="${post.title}">` : ''}
			<div class="body">
				<div class="meta">
					<span class="badge">${post.category || 'Allgemein'}</span>
					<span>${post.author || 'Unbekannt'}</span>
					<span>•</span>
					<span>${post.time || ''}</span>
					${canCreate ? `<span style="margin-left:auto"></span><button class="btn subtle tiny danger" data-delete="${post.id}">Löschen</button>` : ''}
				</div>
				<h3 class="title">${post.title}</h3>
				<p class="intro">${post.intro}</p>
			</div>
		</article>
	`).join('');

	if (canCreate) {
		postsContainer.querySelectorAll('button[data-delete]').forEach(btn => {
			btn.addEventListener('click', () => {
				const id = btn.getAttribute('data-delete');
				if (!id) return;
				nuiSend('deletePost', { id });
			});
		});
	}
}

function openUI(author) {
	currentAuthor = author || '';
	root.classList.remove('hidden');
	// initial data will be pushed to NUI after client asks server
}

function closeUI() {
	root.classList.add('hidden');
	nuiSend('close', {});
}

// UI events
newPostBtn.addEventListener('click', () => {
	newPostCard.classList.remove('hidden');
	postForm.querySelector('#author').value = currentAuthor;
});

cancelPostBtn.addEventListener('click', () => {
	newPostCard.classList.add('hidden');
	postForm.reset();
});

categoryFilter.addEventListener('change', () => {
	renderPosts();
});

galleryBtn.addEventListener('click', () => {
	nuiSend('selectGallery', {});
});

postForm.addEventListener('submit', (e) => {
	e.preventDefault();
	const title = postForm.querySelector('#title').value.trim();
	const intro = postForm.querySelector('#intro').value.trim();
	const category = postForm.querySelector('#category').value.trim();
	const author = postForm.querySelector('#author').value.trim();
	const image = postForm.querySelector('#image').value.trim();
	if (!title || !intro || !category || !author) return;
	nuiSend('createPost', { title, intro, category, author, image });
	newPostCard.classList.add('hidden');
	postForm.reset();
});

// delete callback
window.addEventListener('message', () => {});

// NUI messages from client
window.addEventListener('message', (event) => {
	const data = event.data || {};
	if (data.type === 'open') {
		openUI(data.author);
	}
	if (data.type === 'close') {
		closeUI();
	}
	if (data.type === 'posts') {
		allPosts = Array.isArray(data.posts) ? data.posts : [];
		renderCategories(data.defaultCategories);
		renderPosts();
	}
	if (data.type === 'permissions') {
		canCreate = !!data.canCreate;
		if (canCreate) {
			newPostBtn.classList.remove('hidden');
		} else {
			newPostBtn.classList.add('hidden');
		}
	}
	if (data.type === 'selectedImage') {
		const imageInput = postForm.querySelector('#image');
		imageInput.value = data.image || '';
	}
});

// development helper to show UI in browser without FiveM
if (!window.invokeNative) {
	root.classList.remove('hidden');
	// non-reporter preview with seeded posts
	canCreate = false;
	const now = Date.now();
	function make(cat, i) {
		const ts = Math.floor((now/1000) - (i * 60));
		return { id: `web_${cat}_${i}`, title: `${cat} Beispiel ${i+1}`, intro: `Einleitung für ${cat} Beispiel ${i+1}.`, category: cat, author: 'System', time: new Date(ts*1000).toISOString().slice(0,16).replace('T',' '), timestamp: ts };
	}
	allPosts = ['Events','Werbung','News','Jobanzeigen'].flatMap(cat => [make(cat,0), make(cat,1)]);
	renderCategories(['Events','Werbung','News','Jobanzeigen']);
	renderPosts();
}

