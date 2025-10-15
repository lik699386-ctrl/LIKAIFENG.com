/**
 * Apple-style Scroll Animation Engine
 * 基于Canvas的滚动序列帧动画系统
 */

class ScrollAnimation {
    constructor(canvasId, options = {}) {
        this.canvas = document.getElementById(canvasId);
        if (!this.canvas) return;
        
        this.ctx = this.canvas.getContext('2d');
        this.frames = [];
        this.frameCount = options.frameCount || 60;
        this.currentFrame = 0;
        this.imagesLoaded = 0;
        
        // 配置选项
        this.options = {
            frameUrlPattern: options.frameUrlPattern || null,
            generateFrames: options.generateFrames || true,
            scrollElement: options.scrollElement || this.canvas.parentElement.parentElement,
            ...options
        };
        
        this.init();
    }
    
    init() {
        this.setupCanvas();
        
        if (this.options.generateFrames) {
            this.generateProceduralFrames();
        } else if (this.options.frameUrlPattern) {
            this.loadFrames();
        }
        
        this.setupScrollListener();
        window.addEventListener('resize', () => this.setupCanvas());
    }
    
    setupCanvas() {
        const parent = this.canvas.parentElement;
        const dpr = window.devicePixelRatio || 1;
        
        // 设置画布尺寸
        this.canvas.width = parent.offsetWidth * dpr;
        this.canvas.height = parent.offsetHeight * dpr;
        this.canvas.style.width = parent.offsetWidth + 'px';
        this.canvas.style.height = parent.offsetHeight + 'px';
        
        this.ctx.scale(dpr, dpr);
        
        // 重新渲染当前帧
        if (this.frames.length > 0) {
            this.render();
        }
    }
    
    // 生成程序化帧（用于演示，无需实际图片）
    generateProceduralFrames() {
        for (let i = 0; i < this.frameCount; i++) {
            this.frames.push(i);
        }
        this.render();
    }
    
    // 加载图片序列帧
    loadFrames() {
        for (let i = 1; i <= this.frameCount; i++) {
            const img = new Image();
            const frameNumber = i.toString().padStart(4, '0');
            img.src = this.options.frameUrlPattern.replace('{frame}', frameNumber);
            
            img.onload = () => {
                this.imagesLoaded++;
                if (this.imagesLoaded === this.frameCount) {
                    this.render();
                }
            };
            
            this.frames.push(img);
        }
    }
    
    setupScrollListener() {
        let ticking = false;
        
        const handleScroll = () => {
            if (!ticking) {
                window.requestAnimationFrame(() => {
                    this.updateFrame();
                    ticking = false;
                });
                ticking = true;
            }
        };
        
        window.addEventListener('scroll', handleScroll, { passive: true });
    }
    
    updateFrame() {
        const scrollElement = this.options.scrollElement;
        const rect = scrollElement.getBoundingClientRect();
        const scrollHeight = scrollElement.offsetHeight - window.innerHeight;
        
        // 计算滚动进度 (0 到 1)
        const scrollTop = -rect.top;
        const scrollFraction = Math.max(0, Math.min(scrollTop / scrollHeight, 1));
        
        // 计算当前帧
        const frameIndex = Math.floor(scrollFraction * (this.frameCount - 1));
        
        if (frameIndex !== this.currentFrame) {
            this.currentFrame = frameIndex;
            this.render();
        }
        
        // 触发自定义事件，传递滚动进度
        const event = new CustomEvent('scrollprogress', { 
            detail: { progress: scrollFraction, frame: frameIndex } 
        });
        this.canvas.dispatchEvent(event);
    }
    
    render() {
        const ctx = this.ctx;
        const canvas = this.canvas;
        const width = canvas.width / (window.devicePixelRatio || 1);
        const height = canvas.height / (window.devicePixelRatio || 1);
        
        // 清空画布
        ctx.clearRect(0, 0, width, height);
        
        if (this.options.generateFrames) {
            this.renderProceduralFrame(this.currentFrame);
        } else {
            const img = this.frames[this.currentFrame];
            if (img && img.complete) {
                // 居中绘制图片
                const scale = Math.min(width / img.width, height / img.height);
                const x = (width - img.width * scale) / 2;
                const y = (height - img.height * scale) / 2;
                ctx.drawImage(img, x, y, img.width * scale, img.height * scale);
            }
        }
    }
    
    // 渲染程序化生成的帧（用于演示）
    renderProceduralFrame(frameIndex) {
        const ctx = this.ctx;
        const width = this.canvas.width / (window.devicePixelRatio || 1);
        const height = this.canvas.height / (window.devicePixelRatio || 1);
        const progress = frameIndex / (this.frameCount - 1);
        
        // 创建动态视觉效果
        const centerX = width / 2;
        const centerY = height / 2;
        
        // 绘制多个圆形，创建动画效果
        for (let i = 0; i < 8; i++) {
            const angle = (progress * Math.PI * 2) + (i * Math.PI / 4);
            const radius = 60 + progress * 100;
            const x = centerX + Math.cos(angle) * radius;
            const y = centerY + Math.sin(angle) * radius;
            
            const gradient = ctx.createRadialGradient(x, y, 0, x, y, 40);
            gradient.addColorStop(0, `hsla(${200 + progress * 160}, 80%, 60%, ${0.8 - progress * 0.3})`);
            gradient.addColorStop(1, `hsla(${200 + progress * 160}, 80%, 60%, 0)`);
            
            ctx.fillStyle = gradient;
            ctx.beginPath();
            ctx.arc(x, y, 40 + progress * 20, 0, Math.PI * 2);
            ctx.fill();
        }
        
        // 中心圆
        const centerGradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, 80 + progress * 40);
        centerGradient.addColorStop(0, `hsla(${220 + progress * 120}, 90%, 70%, 0.9)`);
        centerGradient.addColorStop(1, `hsla(${220 + progress * 120}, 90%, 70%, 0)`);
        
        ctx.fillStyle = centerGradient;
        ctx.beginPath();
        ctx.arc(centerX, centerY, 80 + progress * 40, 0, Math.PI * 2);
        ctx.fill();
    }
}

// Hero Canvas 动画（持续动画，不依赖滚动）
class HeroAnimation {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        if (!this.canvas) return;
        
        this.ctx = this.canvas.getContext('2d');
        this.particles = [];
        this.time = 0;
        
        this.init();
    }
    
    init() {
        this.setupCanvas();
        this.createParticles();
        this.animate();
        
        window.addEventListener('resize', () => {
            this.setupCanvas();
            this.createParticles();
        });
    }
    
    setupCanvas() {
        const parent = this.canvas.parentElement;
        const size = Math.min(500, Math.min(parent.offsetWidth, parent.offsetHeight));
        const dpr = window.devicePixelRatio || 1;
        
        this.canvas.width = size * dpr;
        this.canvas.height = size * dpr;
        this.canvas.style.width = size + 'px';
        this.canvas.style.height = size + 'px';
        
        this.ctx.scale(dpr, dpr);
        this.size = size;
    }
    
    createParticles() {
        this.particles = [];
        const count = 30;
        
        for (let i = 0; i < count; i++) {
            this.particles.push({
                angle: (Math.PI * 2 * i) / count,
                speed: 0.002 + Math.random() * 0.003,
                radius: 80 + Math.random() * 100,
                size: 3 + Math.random() * 5,
                opacity: 0.3 + Math.random() * 0.4
            });
        }
    }
    
    animate() {
        this.time += 0.01;
        this.render();
        requestAnimationFrame(() => this.animate());
    }
    
    render() {
        const ctx = this.ctx;
        const size = this.size;
        const centerX = size / 2;
        const centerY = size / 2;
        
        // 清空画布
        ctx.clearRect(0, 0, size, size);
        
        // 绘制粒子
        this.particles.forEach((particle, index) => {
            const angle = particle.angle + this.time * particle.speed;
            const x = centerX + Math.cos(angle) * particle.radius;
            const y = centerY + Math.sin(angle) * particle.radius;
            
            const gradient = ctx.createRadialGradient(x, y, 0, x, y, particle.size * 3);
            gradient.addColorStop(0, `rgba(0, 113, 227, ${particle.opacity})`);
            gradient.addColorStop(1, 'rgba(0, 113, 227, 0)');
            
            ctx.fillStyle = gradient;
            ctx.beginPath();
            ctx.arc(x, y, particle.size * 3, 0, Math.PI * 2);
            ctx.fill();
        });
        
        // 绘制连接线
        ctx.strokeStyle = 'rgba(0, 113, 227, 0.1)';
        ctx.lineWidth = 1;
        
        for (let i = 0; i < this.particles.length; i++) {
            const p1 = this.particles[i];
            const angle1 = p1.angle + this.time * p1.speed;
            const x1 = centerX + Math.cos(angle1) * p1.radius;
            const y1 = centerY + Math.sin(angle1) * p1.radius;
            
            for (let j = i + 1; j < this.particles.length; j++) {
                const p2 = this.particles[j];
                const angle2 = p2.angle + this.time * p2.speed;
                const x2 = centerX + Math.cos(angle2) * p2.radius;
                const y2 = centerY + Math.sin(angle2) * p2.radius;
                
                const distance = Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2);
                
                if (distance < 100) {
                    ctx.beginPath();
                    ctx.moveTo(x1, y1);
                    ctx.lineTo(x2, y2);
                    ctx.stroke();
                }
            }
        }
    }
}

// 初始化动画
document.addEventListener('DOMContentLoaded', () => {
    // Hero 区域的持续动画
    new HeroAnimation('heroCanvas');
    
    // 滚动驱动的序列帧动画
    const scrollAnim = new ScrollAnimation('scrollCanvas', {
        frameCount: 120,
        generateFrames: true
    });
    
    // 监听滚动进度，更新文本显示
    const scrollCanvas = document.getElementById('scrollCanvas');
    const textItems = document.querySelectorAll('.scroll-text-item');
    
    scrollCanvas.addEventListener('scrollprogress', (e) => {
        const progress = e.detail.progress;
        
        textItems.forEach(item => {
            const start = parseFloat(item.dataset.scrollStart);
            const end = parseFloat(item.dataset.scrollEnd);
            
            if (progress >= start && progress <= end) {
                item.classList.add('active');
            } else {
                item.classList.remove('active');
            }
        });
    });
});

