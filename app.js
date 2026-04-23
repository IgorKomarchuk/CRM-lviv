// ===== BigCAT ERP - Application Logic =====

// Navigation between pages
function showPage(pageId) {
    document.querySelectorAll('.o-page').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.o-nav-item').forEach(n => n.classList.remove('active'));
    document.querySelectorAll('.o-sidebar-item').forEach(s => s.classList.remove('active'));

    const page = document.getElementById(pageId);
    if (page) page.classList.add('active');

    document.querySelectorAll(`[data-page="${pageId}"]`).forEach(el => el.classList.add('active'));

    // Update breadcrumb
    const titles = {
        'page-dashboard': 'Головна панель',
        'page-products': 'Склад / Товари',
        'page-orders': 'Замовлення',
        'page-crm': 'CRM — Воронка продажів',
        'page-purchases': 'Закупівлі',
        'page-ai': '🤖 AI Аналітик — Висновки та рекомендації',
        'page-finance': '💰 Фінанси та Управлінський облік (Методи 1С)',
        'page-accounting': '📄 Бухгалтерія та Первинні документи',
        'page-telephony': 'Телефонія',
        'page-analytics': 'Аналітика',
        'page-settings': 'Налаштування'
    };
    const bc = document.getElementById('breadcrumb-title');
    if (bc) bc.textContent = titles[pageId] || pageId;
}

// Phone panel toggle
function togglePhone() {
    const panel = document.getElementById('phone-panel');
    const fab = document.getElementById('phone-fab');
    if (panel.classList.contains('open')) {
        panel.classList.remove('open');
        fab.style.display = 'flex';
    } else {
        panel.classList.add('open');
        fab.style.display = 'none';
    }
}

// Search filter for products table
function filterProducts() {
    const query = document.getElementById('product-search').value.toLowerCase();
    const rows = document.querySelectorAll('#products-tbody tr');
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(query) ? '' : 'none';
    });
}

// Search filter for orders table
function filterOrders() {
    const query = document.getElementById('order-search').value.toLowerCase();
    const rows = document.querySelectorAll('#orders-tbody tr');
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(query) ? '' : 'none';
    });
}

// Initialize animated bars on dashboard
function animateBars() {
    const bars = document.querySelectorAll('.o-bar');
    bars.forEach(bar => {
        const target = bar.getAttribute('data-height');
        setTimeout(() => { bar.style.height = target + '%'; }, 100);
    });
}

// Initialize on load
document.addEventListener('DOMContentLoaded', () => {
    showPage('page-dashboard');
    animateBars();

    // Live clock
    function updateClock() {
        const now = new Date();
        const el = document.getElementById('live-clock');
        if (el) el.textContent = now.toLocaleTimeString('uk-UA', { hour: '2-digit', minute: '2-digit' });
    }
    updateClock();
    setInterval(updateClock, 30000);
});
