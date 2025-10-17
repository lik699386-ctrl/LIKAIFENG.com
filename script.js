// 应用数据存储
let apps = [];
let releasesConfig = null;

// 从GitHub Release配置加载应用数据
async function loadApps() {
    try {
        // 优先从releases-config.json加载
        const response = await fetch('releases-config.json');
        if (response.ok) {
            releasesConfig = await response.json();
            apps = releasesConfig.apps || [];
            console.log('✅ 已从 GitHub Release 加载应用列表');
        } else {
            throw new Error('配置文件不存在');
        }
    } catch (error) {
        console.log('⚠️ 未找到 releases-config.json，使用本地存储');
        // 降级到localStorage
        const stored = localStorage.getItem('myApps');
        if (stored) {
            apps = JSON.parse(stored);
        } else {
            // 添加一些示例应用
            apps = [
                {
                    id: 1,
                    name: '邮件质检系统',
                    description: '智能邮件质量检查工具，提升邮件处理效率',
                    version: '1.0.0',
                    category: 'productivity',
                    icon: null,
                    downloadUrl: '#',
                    cdnUrl: '#',
                    fileName: 'MailQC.zip',
                    fileSize: '25.6 MB',
                    uploadDate: new Date().toISOString()
                },
                {
                    id: 2,
                    name: 'AI图片生成器',
                    description: '使用人工智能技术快速生成高质量图片',
                    version: '2.1.0',
                    category: 'creative',
                    icon: null,
                    downloadUrl: '#',
                    cdnUrl: '#',
                    fileName: 'ImageDesign.zip',
                    fileSize: '42.3 MB',
                    uploadDate: new Date().toISOString()
                }
            ];
            saveApps();
        }
    }
    renderApps();
}

// 保存应用数据到localStorage
function saveApps() {
    localStorage.setItem('myApps', JSON.stringify(apps));
}

// 渲染应用列表
function renderApps() {
    const grid = document.getElementById('appsGrid');
    
    if (apps.length === 0) {
        grid.innerHTML = `
            <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px;">
                <p style="font-size: 20px; color: var(--text-secondary);">暂无应用，快去上传第一个应用吧！</p>
            </div>
        `;
        return;
    }
    
    grid.innerHTML = apps.map(app => {
        const categoryNames = {
            productivity: '生产力',
            utility: '实用工具',
            creative: '创意设计',
            development: '开发工具',
            other: '其他'
        };
        
        return `
            <div class="app-card" data-id="${app.id}">
                <div class="app-icon">
                    ${app.icon 
                        ? `<img src="${app.icon}" alt="${app.name}">` 
                        : `<div class="app-icon-placeholder">${app.name.charAt(0)}</div>`
                    }
                </div>
                <div class="app-info">
                    <h3 class="app-name">${app.name}</h3>
                    <p class="app-description">${app.description}</p>
                    <div class="app-meta">
                        <span class="app-version">版本 ${app.version}</span>
                        <span class="app-category">${categoryNames[app.category] || app.category}</span>
                    </div>
                    <button class="download-button" onclick="downloadApp(${app.id})">
                        下载 ${app.fileSize || ''}
                    </button>
                </div>
            </div>
        `;
    }).join('');
}

// 下载应用
function downloadApp(appId) {
    const app = apps.find(a => a.id === appId);
    if (!app) return;
    
    // 优先使用CDN链接，如果配置启用且有CDN链接
    let downloadUrl = app.downloadUrl;
    if (releasesConfig?.settings?.useCDN && app.cdnUrl && app.cdnUrl !== '#') {
        downloadUrl = app.cdnUrl;
        console.log('🚀 使用 CDN 加速下载');
    } else if (app.downloadUrl && app.downloadUrl !== '#') {
        downloadUrl = app.downloadUrl;
        console.log('📦 从 GitHub 下载');
    } else if (app.fileUrl && app.fileUrl !== '#') {
        // 兼容旧版本的fileUrl
        downloadUrl = app.fileUrl;
    }
    
    if (downloadUrl && downloadUrl !== '#') {
        // 触发下载
        const a = document.createElement('a');
        a.href = downloadUrl;
        a.download = app.fileName || `${app.name}.zip`;
        a.target = '_blank'; // 新标签页打开，某些浏览器需要
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        
        const source = releasesConfig?.settings?.useCDN ? 'CDN加速' : 'GitHub';
        showNotification(`开始下载 ${app.name} (${source})`, 'success');
    } else {
        showNotification('此应用暂无可下载文件', 'error');
    }
}

// 显示通知
function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideIn 0.3s ease-out reverse';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// 文件上传处理
document.addEventListener('DOMContentLoaded', () => {
    loadApps();
    
    // 文件选择显示
    const appIconInput = document.getElementById('appIcon');
    const appFileInput = document.getElementById('appFile');
    const iconFileName = document.getElementById('iconFileName');
    const appFileName = document.getElementById('appFileName');
    
    appIconInput.addEventListener('change', (e) => {
        if (e.target.files.length > 0) {
            iconFileName.textContent = e.target.files[0].name;
        }
    });
    
    appFileInput.addEventListener('change', (e) => {
        if (e.target.files.length > 0) {
            const file = e.target.files[0];
            const sizeMB = (file.size / (1024 * 1024)).toFixed(1);
            appFileName.textContent = `${file.name} (${sizeMB} MB)`;
        }
    });
    
    // 表单提交
    const uploadForm = document.getElementById('uploadForm');
    uploadForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const submitButton = uploadForm.querySelector('.submit-button');
        submitButton.classList.add('loading');
        
        // 获取表单数据
        const formData = {
            id: Date.now(),
            name: document.getElementById('appName').value,
            description: document.getElementById('appDescription').value,
            version: document.getElementById('appVersion').value,
            category: document.getElementById('appCategory').value,
            icon: null,
            fileUrl: '#',
            fileName: '',
            fileSize: '',
            uploadDate: new Date().toISOString()
        };
        
        // 处理图标
        if (appIconInput.files.length > 0) {
            const iconFile = appIconInput.files[0];
            formData.icon = await readFileAsDataURL(iconFile);
        }
        
        // 处理应用文件
        if (appFileInput.files.length > 0) {
            const file = appFileInput.files[0];
            formData.fileName = file.name;
            formData.fileSize = `${(file.size / (1024 * 1024)).toFixed(1)} MB`;
            
            // 在实际应用中，这里应该上传文件到服务器
            // 现在只是模拟，将文件转换为DataURL存储（仅适用于小文件）
            if (file.size < 10 * 1024 * 1024) { // 小于10MB
                formData.fileUrl = await readFileAsDataURL(file);
            } else {
                formData.fileUrl = '#'; // 大文件需要服务器支持
            }
        }
        
        // 模拟上传延迟
        await new Promise(resolve => setTimeout(resolve, 1500));
        
        // 添加到应用列表
        apps.unshift(formData);
        saveApps();
        renderApps();
        
        // 重置表单
        uploadForm.reset();
        iconFileName.textContent = '选择图片文件';
        appFileName.textContent = '选择应用文件';
        
        submitButton.classList.remove('loading');
        
        showNotification('应用上传成功！', 'success');
        
        // 滚动到应用区域
        document.getElementById('apps').scrollIntoView({ behavior: 'smooth' });
    });
});

// 读取文件为DataURL
function readFileAsDataURL(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = (e) => resolve(e.target.result);
        reader.onerror = reject;
        reader.readAsDataURL(file);
    });
}

// 平滑滚动
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({ behavior: 'smooth' });
        }
    });
});

// 导航栏滚动效果
let lastScroll = 0;
window.addEventListener('scroll', () => {
    const navbar = document.querySelector('.navbar');
    const currentScroll = window.pageYOffset;
    
    if (currentScroll > 100) {
        navbar.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.1)';
    } else {
        navbar.style.boxShadow = 'none';
    }
    
    lastScroll = currentScroll;
});

