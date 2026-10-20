/* ==============================================================================
   MAANG AI ENGINEER ELI5 - JAVASCRIPT APP CONTROLLER
   Offline-first (file:// and http:// compatible), Instant Search, Multi-language
   ============================================================================== */

let appData = null;
let currentLessonNum = 1;
let currentLanguage = 'split'; // 'split', 'tr', 'en'
let allLessonsFlat = [];

document.addEventListener('DOMContentLoaded', async () => {
  await initData();
  initUI();
  handleRouting();
});

// Load curriculum data from window.LESSONS_DATA or fetch fallback
async function initData() {
  if (window.LESSONS_DATA && window.LESSONS_DATA.modules) {
    appData = window.LESSONS_DATA;
  } else {
    try {
      const response = await fetch('data/lessons.json');
      appData = await response.json();
    } catch (e) {
      console.warn("Could not fetch data via fetch API, relying on window.LESSONS_DATA:", e);
    }
  }

  if (!appData || !appData.modules) {
    alert("Hata: Ders verileri yüklenemedi. Lütfen 'lessons.js' dosyasının var olduğundan emin olun.");
    return;
  }

  // Flatten lessons for quick lookup
  allLessonsFlat = [];
  appData.modules.forEach(m => {
    m.lessons.forEach(l => {
      allLessonsFlat.push({ ...l, module: m });
    });
  });
}

function initUI() {
  renderSidebar(appData.modules);
  setupTheme();
  setupLanguageSwitcher();
  setupSearch();
  setupPdfModal();
  setupKeyboardShortcuts();
  window.addEventListener('hashchange', handleRouting);
}

function setupTheme() {
  const themeToggleBtn = document.getElementById('themeToggleBtn');
  const savedTheme = localStorage.getItem('ai_engineer_theme') || 'light';
  applyTheme(savedTheme);

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', () => {
      const isDark = document.body.classList.contains('theme-dark');
      applyTheme(isDark ? 'light' : 'dark');
    });
  }
}

function applyTheme(theme) {
  const themeToggleBtn = document.getElementById('themeToggleBtn');
  if (theme === 'dark') {
    document.body.classList.add('theme-dark');
    if (themeToggleBtn) themeToggleBtn.textContent = '🌙 Koyu';
  } else {
    document.body.classList.remove('theme-dark');
    if (themeToggleBtn) themeToggleBtn.textContent = '☀️ Açık';
  }
  localStorage.setItem('ai_engineer_theme', theme);
}

// Router based on hash (#lesson-12)
function handleRouting() {
  const hash = window.location.hash;
  let targetLesson = 1;
  if (hash.startsWith('#lesson-')) {
    const num = parseInt(hash.replace('#lesson-', ''), 10);
    if (!isNaN(num) && num >= 1 && num <= 60) {
      targetLesson = num;
    }
  }
  selectLesson(targetLesson);
}

// Render Sidebar Accordion
function renderSidebar(modules) {
  const container = document.getElementById('moduleAccordion');
  if (!container) return;
  container.innerHTML = '';

  modules.forEach(m => {
    const li = document.createElement('li');
    li.className = 'module-item open';
    li.id = `mod-item-${m.id}`;

    let lessonButtonsHtml = '';
    m.lessons.forEach(l => {
      lessonButtonsHtml += `
        <li>
          <button class="lesson-nav-btn" id="nav-btn-${l.num}" onclick="navigateToLesson(${l.num})">
            <span class="lesson-nav-num">#${l.num < 10 ? '0' + l.num : l.num}</span>
            <span class="lesson-nav-title">${escapeHtml(l.title_tr)}</span>
          </button>
        </li>
      `;
    });

    li.innerHTML = `
      <div class="module-header" onclick="toggleModule(${m.id})">
        <div class="module-title-group">
          <span class="module-badge">BÖLÜM ${m.id}</span>
          <span class="module-title-text">${escapeHtml(m.title_tr)}</span>
        </div>
        <span class="module-chevron">▶</span>
      </div>
      <ul class="lesson-sublist">
        ${lessonButtonsHtml}
      </ul>
    `;
    container.appendChild(li);
  });
}

function toggleModule(modId) {
  const item = document.getElementById(`mod-item-${modId}`);
  if (item) {
    item.classList.toggle('open');
  }
}

function navigateToLesson(num) {
  window.location.hash = `#lesson-${num}`;
}

// Select and Render Lesson
function selectLesson(num) {
  currentLessonNum = num;
  const item = allLessonsFlat.find(x => x.num === num);
  if (!item) return;

  // Update Sidebar active state
  document.querySelectorAll('.lesson-nav-btn').forEach(btn => btn.classList.remove('active'));
  const activeBtn = document.getElementById(`nav-btn-${num}`);
  if (activeBtn) {
    activeBtn.classList.add('active');
    const parentModule = activeBtn.closest('.module-item');
    if (parentModule && !parentModule.classList.contains('open')) {
      parentModule.classList.add('open');
    }
    activeBtn.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }

  // Update Lesson counter badge
  const counterBadge = document.getElementById('lessonCounterBadge');
  if (counterBadge) counterBadge.innerText = `Ders ${num} / 60`;

  // Render Lesson Content
  renderLessonView(item);
  const main = document.getElementById('mainContent');
  if (main) main.scrollTop = 0;
}

function renderLessonView(item) {
  const main = document.getElementById('mainContent');
  if (!main) return;
  const m = item.module;

  // Takeaways rendering
  let takeawaysHtml = '';
  if (item.takeaways && item.takeaways.length > 0) {
    takeawaysHtml = item.takeaways.map(t => `
      <div class="takeaway-row">
        <div class="takeaway-tr"><strong>•</strong> ${escapeHtml(t[0])}</div>
        <div class="takeaway-en"><strong>•</strong> ${escapeHtml(t[1])}</div>
      </div>
    `).join('');
  }

  // Previous & Next navigation
  const prevNum = item.num > 1 ? item.num - 1 : null;
  const nextNum = item.num < 60 ? item.num + 1 : null;
  const prevItem = prevNum ? allLessonsFlat.find(x => x.num === prevNum) : null;
  const nextItem = nextNum ? allLessonsFlat.find(x => x.num === nextNum) : null;

  main.innerHTML = `
    <!-- Lesson Banner -->
    <header class="lesson-banner">
      <div class="lesson-meta-bar">
        <div class="lesson-meta-tags">
          <span class="tag-module">BÖLÜM ${m.id}: ${escapeHtml(m.title_tr)}</span>
          <span class="tag-lesson-num">Ders #${item.num} / 60</span>
        </div>
        <a href="../output/individual/lesson_${item.num < 10 ? '0' + item.num : item.num}.pdf" target="_blank" class="btn-secondary" style="font-size: 0.78rem; padding: 0.35rem 0.75rem;">
          📄 Bu Dersin PDF'ini Aç
        </a>
      </div>
      <h1 class="lesson-title-tr">${escapeHtml(item.title_tr)}</h1>
      <h2 class="lesson-title-en">${escapeHtml(item.title_en)}</h2>
    </header>

    <!-- Architecture Diagram Box -->
    <section class="content-box box-diagram">
      <div class="box-header">
        <div class="box-title">
          <span>🤖 AI Mimarisi & Veri Akış Şeması</span>
          <span class="box-badge">ASCII Flow</span>
        </div>
        <button class="btn-secondary" style="font-size: 0.74rem; padding: 0.25rem 0.65rem;" onclick="copyElementText('diagram-code-${item.num}')">
          📋 Şemayı Kopyala
        </button>
      </div>
      <div class="box-body" style="padding: 0;">
        <pre class="diagram-pre" id="diagram-code-${item.num}">${escapeHtml(item.diagram)}</pre>
      </div>
    </section>

    <!-- ELI5 Box -->
    <section class="content-box box-eli5">
      <div class="box-header">
        <div class="box-title">
          <span>💡 Aptala Anlatım (ELI5 Metaforu)</span>
          <span class="box-badge">Explain Like I'm 5</span>
        </div>
      </div>
      <div class="box-body">
        ${renderBilingualText(item.eli5_tr, item.eli5_en)}
      </div>
    </section>

    <!-- MAANG Technical Deep Dive -->
    <section class="content-box box-deep">
      <div class="box-header">
        <div class="box-title">
          <span>🔍 MAANG Seviyesi Teknik Derinlik</span>
          <span class="box-badge">Technical Deep-Dive</span>
        </div>
      </div>
      <div class="box-body">
        ${renderBilingualText(item.deep_tr, item.deep_en)}
      </div>
    </section>

    <!-- Java 25 & Modern Frameworks Code Box -->
    <section class="content-box box-code">
      <div class="box-header">
        <div class="box-title">
          <span>⚡ Modern Java 25, Spring AI & LangChain4j</span>
          <span class="box-badge">Java 25 LTS</span>
        </div>
        <button class="btn-secondary" style="font-size: 0.74rem; padding: 0.25rem 0.65rem;" onclick="copyElementText('java-code-${item.num}')">
          📋 Kodu Kopyala
        </button>
      </div>
      <div class="box-body" style="padding: 0;">
        <div class="code-wrapper">
          <button class="btn-copy-code" onclick="copyElementText('java-code-${item.num}')">Kopyala</button>
          <pre class="code-pre" id="java-code-${item.num}"><code>${escapeHtml(item.java_code)}</code></pre>
        </div>
      </div>
    </section>

    <!-- Warning & Interview Bottlenecks -->
    <section class="content-box box-warning">
      <div class="box-header">
        <div class="box-title">
          <span>⚠️ Halüsinasyon, Güvenlik & Mülakat Tuzağı</span>
          <span class="box-badge">Interview Trap</span>
        </div>
      </div>
      <div class="box-body">
        ${renderBilingualText(item.warning_tr, item.warning_en)}
      </div>
    </section>

    <!-- Key Takeaways -->
    <section class="content-box box-takeaways">
      <div class="box-header">
        <div class="box-title">
          <span>🎯 Mülakatta Hatırlanacak Altın Çıkarımlar</span>
          <span class="box-badge">Key Takeaways</span>
        </div>
      </div>
      <div class="box-body">
        <div class="takeaways-grid">
          ${takeawaysHtml}
        </div>
      </div>
    </section>

    <!-- Bottom Navigation Footer -->
    <footer class="lesson-footer-nav">
      ${prevItem ? `
        <div class="nav-direction-btn" onclick="navigateToLesson(${prevNum})">
          <span style="font-size: 1.3rem;">◀</span>
          <div>
            <div class="nav-dir-sub">Önceki Ders #${prevNum}</div>
            <div class="nav-dir-title">${escapeHtml(prevItem.title_tr)}</div>
          </div>
        </div>
      ` : `
        <div class="nav-direction-btn disabled">
          <span style="font-size: 1.3rem;">◀</span>
          <div>
            <div class="nav-dir-sub">İlk Ders</div>
            <div class="nav-dir-title">Müfredatın Başındasınız</div>
          </div>
        </div>
      `}

      ${nextItem ? `
        <div class="nav-direction-btn" style="text-align: right;" onclick="navigateToLesson(${nextNum})">
          <div>
            <div class="nav-dir-sub">Sonraki Ders #${nextNum}</div>
            <div class="nav-dir-title">${escapeHtml(nextItem.title_tr)}</div>
          </div>
          <span style="font-size: 1.3rem;">▶</span>
        </div>
      ` : `
        <div class="nav-direction-btn disabled" style="text-align: right;">
          <div>
            <div class="nav-dir-sub">Tebrikler!</div>
            <div class="nav-dir-title">Müfredatı Tamamladınız</div>
          </div>
          <span style="font-size: 1.3rem;">🎓</span>
        </div>
      `}
    </footer>
  `;
}

// Render Bilingual Grid
function renderBilingualText(trText, enText) {
  return `
    <div class="split-columns">
      <div class="lang-column col-tr">
        <div class="col-header label-tr">🇹🇷 TÜRKÇE</div>
        <p>${escapeHtml(trText)}</p>
      </div>
      <div class="lang-column col-en">
        <div class="col-header label-en">🇬🇧 ENGLISH</div>
        <p>${escapeHtml(enText)}</p>
      </div>
    </div>
  `;
}

// Setup Language Switcher
function setupLanguageSwitcher() {
  const buttons = document.querySelectorAll('.lang-btn');
  buttons.forEach(btn => {
    btn.addEventListener('click', () => {
      buttons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const lang = btn.getAttribute('data-lang');
      currentLanguage = lang;

      document.body.classList.remove('mode-split', 'mode-tr', 'mode-en');
      if (lang === 'tr') {
        document.body.classList.add('mode-tr');
      } else if (lang === 'en') {
        document.body.classList.add('mode-en');
      } else {
        document.body.classList.add('mode-split');
      }
    });
  });
}

// Setup Search
function setupSearch() {
  const input = document.getElementById('searchInput');
  if (!input) return;

  input.addEventListener('input', (e) => {
    const q = e.target.value.toLowerCase().trim();
    if (!q) {
      document.querySelectorAll('.lesson-nav-btn').forEach(btn => btn.style.display = 'flex');
      document.querySelectorAll('.module-item').forEach(m => m.style.display = 'block');
      return;
    }

    appData.modules.forEach(m => {
      let moduleHasMatch = false;
      m.lessons.forEach(l => {
        const btn = document.getElementById(`nav-btn-${l.num}`);
        const fullContent = (
          l.title_tr + " " +
          l.title_en + " " +
          l.eli5_tr + " " +
          l.eli5_en + " " +
          l.deep_tr + " " +
          l.deep_en + " " +
          l.diagram + " " +
          l.java_code
        ).toLowerCase();

        if (fullContent.includes(q)) {
          if (btn) btn.style.display = 'flex';
          moduleHasMatch = true;
        } else {
          if (btn) btn.style.display = 'none';
        }
      });

      const moduleGroup = document.getElementById(`mod-item-${m.id}`);
      if (moduleGroup) {
        if (moduleHasMatch) {
          moduleGroup.style.display = 'block';
          moduleGroup.classList.add('open');
        } else {
          moduleGroup.style.display = 'none';
        }
      }
    });
  });
}

// Setup PDF Library Modal
function setupPdfModal() {
  const modal = document.getElementById('pdfModal');
  const btnOpen = document.getElementById('btnOpenPdfModal');
  const btnClose = document.getElementById('btnClosePdfModal');

  if (!modal || !btnOpen || !btnClose) return;

  btnOpen.addEventListener('click', () => {
    populatePdfModal();
    modal.classList.add('open');
  });

  btnClose.addEventListener('click', () => {
    modal.classList.remove('open');
  });

  modal.addEventListener('click', (e) => {
    if (e.target === modal) {
      modal.classList.remove('open');
    }
  });
}

function populatePdfModal() {
  const moduleContainer = document.getElementById('modalModulePdfList');
  const individualContainer = document.getElementById('modalIndividualPdfList');
  if (!moduleContainer || !individualContainer) return;

  if (moduleContainer.children.length === 0) {
    moduleContainer.innerHTML = appData.modules.map(m => `
      <div class="pdf-item">
        <div>
          <div style="font-weight: 700; color: white; font-size: 0.88rem;">
            📦 Bölüm ${m.id}: ${escapeHtml(m.title_tr)}
          </div>
          <div style="font-size: 0.74rem; color: var(--text-secondary);">
            ${escapeHtml(m.title_en)} (6 Ders Paketi)
          </div>
        </div>
        <a href="../output/modules/module_${m.id < 10 ? '0' + m.id : m.id}_${m.dir}.pdf" target="_blank" class="btn-secondary" style="font-size: 0.76rem; padding: 0.35rem 0.8rem;">
          ⬇️ İndir / Aç
        </a>
      </div>
    `).join('');
  }

  if (individualContainer.children.length === 0) {
    individualContainer.innerHTML = allLessonsFlat.map(l => `
      <div class="pdf-grid-item">
        <span style="color: var(--text-secondary); font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 170px;">
          #${l.num < 10 ? '0' + l.num : l.num}: ${escapeHtml(l.title_tr)}
        </span>
        <a href="../output/individual/lesson_${l.num < 10 ? '0' + l.num : l.num}.pdf" target="_blank" class="btn-secondary" style="padding: 0.2rem 0.5rem; font-size: 0.7rem;">
          PDF
        </a>
      </div>
    `).join('');
  }
}

// Copy Code / Diagram to Clipboard
function copyElementText(elementId) {
  const el = document.getElementById(elementId);
  if (!el) return;
  const text = el.innerText;
  navigator.clipboard.writeText(text).then(() => {
    showToast("Panoya kopyalandı! / Copied to clipboard!");
  }).catch(err => {
    console.error("Kopyalama hatası:", err);
  });
}

function showToast(msg) {
  let toast = document.querySelector('.toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.className = 'toast';
    document.body.appendChild(toast);
  }
  toast.innerText = msg;
  toast.classList.add('show');
  setTimeout(() => {
    toast.classList.remove('show');
  }, 2200);
}

// Keyboard navigation
function setupKeyboardShortcuts() {
  document.addEventListener('keydown', (e) => {
    // If typing in input, ignore shortcuts
    if (e.target.tagName === 'INPUT') return;

    if (e.key === 'ArrowRight' && currentLessonNum < 60) {
      navigateToLesson(currentLessonNum + 1);
    } else if (e.key === 'ArrowLeft' && currentLessonNum > 1) {
      navigateToLesson(currentLessonNum - 1);
    } else if (e.key === '/') {
      e.preventDefault();
      const searchInput = document.getElementById('searchInput');
      if (searchInput) searchInput.focus();
    }
  });
}

// Utility: HTML Escaping
function escapeHtml(text) {
  if (!text) return '';
  return text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}
