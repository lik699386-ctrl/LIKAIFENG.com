# 🎬 B站视频嵌入完整指南

## 📋 快速开始（3步搞定）

### 第1步：上传视频到B站

1. **访问B站创作中心**
   ```
   https://member.bilibili.com/platform/upload/video/frame
   ```

2. **登录B站账号**（没有的话先注册一个）

3. **上传视频**
   - 点击"上传视频"
   - 选择你的视频文件
   - 填写标题和简介

4. **设置可见性**
   - 向下滚动到"稿件设置"
   - 选择 **"仅自己可见"** 或 **"不公开"**
   - 这样视频不会出现在B站搜索中，但你可以通过链接访问

5. **提交审核**
   - 点击"提交"
   - 等待几分钟（B站会自动转码）

---

### 第2步：获取BV号

上传成功后，在"稿件管理"中找到你的视频：

1. 点击视频标题进入详情页
2. 复制浏览器地址栏的链接，格式如：
   ```
   https://www.bilibili.com/video/BV1xx411c7mD
   ```
3. **BV号就是：`BV1xx411c7mD`**

---

### 第3步：嵌入到网页

打开 `video.html` 文件，找到：

```html
<iframe 
    src="//player.bilibili.com/player.html?bvid=BV1GJ411x7h7&page=1&high_quality=1&danmaku=0" 
    scrolling="no" 
    allowfullscreen="true">
</iframe>
```

把 `bvid=BV1GJ411x7h7` 替换成你的BV号：

```html
<iframe 
    src="//player.bilibili.com/player.html?bvid=你的BV号&page=1&high_quality=1&danmaku=0" 
    scrolling="no" 
    allowfullscreen="true">
</iframe>
```

保存文件，刷新网页即可！

---

## 🎨 播放器参数详解

在 iframe 的 `src` 地址中，你可以自定义这些参数：

### 基础参数

| 参数 | 说明 | 可选值 | 示例 |
|------|------|--------|------|
| `bvid` | 视频BV号 | 你的BV号 | `bvid=BV1xx411c7mD` |
| `page` | 视频分P | 数字（默认1） | `page=1` |

### 播放控制

| 参数 | 说明 | 可选值 | 默认值 |
|------|------|--------|--------|
| `autoplay` | 自动播放 | 0=否, 1=是 | 0 |
| `muted` | 静音播放 | 0=否, 1=是 | 0 |
| `t` | 从第几秒开始 | 秒数 | 0 |

### 播放器界面

| 参数 | 说明 | 可选值 | 默认值 |
|------|------|--------|--------|
| `danmaku` | 显示弹幕 | 0=关闭, 1=开启 | 1 |
| `high_quality` | 高清优先 | 0=否, 1=是 | 0 |
| `as_wide` | 宽屏模式 | 0=否, 1=是 | 0 |

### 示例组合

**1. 自动播放 + 静音 + 无弹幕**
```html
src="//player.bilibili.com/player.html?bvid=你的BV号&autoplay=1&muted=1&danmaku=0"
```

**2. 高清 + 宽屏 + 从30秒开始**
```html
src="//player.bilibili.com/player.html?bvid=你的BV号&high_quality=1&as_wide=1&t=30"
```

**3. 推荐设置（网页展示）**
```html
src="//player.bilibili.com/player.html?bvid=你的BV号&page=1&high_quality=1&danmaku=0"
```

---

## 📐 响应式播放器（自适应屏幕）

### 方法1：16:9 比例（推荐）

```html
<!-- 容器 -->
<div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden;">
    <!-- 播放器 -->
    <iframe 
        src="//player.bilibili.com/player.html?bvid=你的BV号" 
        style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"
        scrolling="no" 
        border="0" 
        frameborder="no" 
        allowfullscreen="true">
    </iframe>
</div>
```

### 方法2：4:3 比例

把 `padding-bottom: 56.25%` 改为 `padding-bottom: 75%`

### 方法3：固定宽度

```html
<iframe 
    src="//player.bilibili.com/player.html?bvid=你的BV号" 
    width="800" 
    height="600" 
    scrolling="no" 
    allowfullscreen="true">
</iframe>
```

---

## 🎯 完整示例代码

### 单个视频展示

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>视频展示</title>
    <style>
        .video-container {
            max-width: 1000px;
            margin: 50px auto;
            padding: 0 20px;
        }
        .video-wrapper {
            position: relative;
            padding-bottom: 56.25%;
            height: 0;
            background: #000;
            border-radius: 12px;
            overflow: hidden;
        }
        .video-wrapper iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: none;
        }
        .video-title {
            margin-top: 20px;
            font-size: 24px;
            color: #333;
        }
    </style>
</head>
<body>
    <div class="video-container">
        <div class="video-wrapper">
            <iframe 
                src="//player.bilibili.com/player.html?bvid=你的BV号&high_quality=1&danmaku=0" 
                scrolling="no" 
                allowfullscreen="true">
            </iframe>
        </div>
        <h2 class="video-title">我的视频标题</h2>
    </div>
</body>
</html>
```

### 多个视频网格

```html
<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
    <!-- 视频1 -->
    <div>
        <div style="position: relative; padding-bottom: 56.25%; height: 0;">
            <iframe 
                src="//player.bilibili.com/player.html?bvid=BV号1" 
                style="position: absolute; width: 100%; height: 100%;"
                scrolling="no" 
                allowfullscreen="true">
            </iframe>
        </div>
        <p>视频1标题</p>
    </div>
    
    <!-- 视频2 -->
    <div>
        <div style="position: relative; padding-bottom: 56.25%; height: 0;">
            <iframe 
                src="//player.bilibili.com/player.html?bvid=BV号2" 
                style="position: absolute; width: 100%; height: 100%;"
                scrolling="no" 
                allowfullscreen="true">
            </iframe>
        </div>
        <p>视频2标题</p>
    </div>
    
    <!-- 视频3 -->
    <div>
        <div style="position: relative; padding-bottom: 56.25%; height: 0;">
            <iframe 
                src="//player.bilibili.com/player.html?bvid=BV号3" 
                style="position: absolute; width: 100%; height: 100%;"
                scrolling="no" 
                allowfullscreen="true">
            </iframe>
        </div>
        <p>视频3标题</p>
    </div>
</div>
```

---

## ❓ 常见问题

### Q1: 视频显示"视频不存在"？
**A:** 检查：
- BV号是否正确
- 视频是否审核通过
- 稿件设置中"允许转载"和"允许承包"建议都开启

### Q2: 视频无法播放？
**A:** 检查：
- 网页是否用HTTPS（可能被浏览器拦截）
- iframe标签是否完整
- 浏览器是否允许iframe

### Q3: 移动端视频太小？
**A:** 使用响应式代码（padding-bottom方法），会自适应屏幕

### Q4: 可以隐藏B站LOGO吗？
**A:** 不能，这是B站的服务条款要求

### Q5: 视频加载慢？
**A:** 
- 添加 `high_quality=1` 参数
- 或者上传时选择"限制清晰度"

### Q6: 如何让视频不能下载？
**A:** B站播放器本身就防下载，用户只能在线观看

---

## 🚀 推送到GitHub Pages

修改完 `video.html` 后：

```bash
cd D:\个人网页
git add video.html
git commit -m "添加视频展示页面"
git push origin master
```

等待1-2分钟，访问：
```
https://lik699386-ctrl.github.io/likaifeng.com/video.html
```

---

## 💡 最佳实践

### 视频规范
- **格式**：MP4（H.264编码）最佳
- **分辨率**：1080P或720P
- **大小**：建议<2GB（大文件会分段处理）
- **时长**：建议每个视频<10分钟（方便用户观看）

### 上传建议
- **标题**：简短明了
- **封面**：自定义封面图（16:9比例）
- **分类**：选择正确的分区
- **可见性**：选"仅自己可见"（私密但可通过链接访问）

### 性能优化
- 添加 `high_quality=1` 启用高清
- 添加 `danmaku=0` 关闭弹幕（减少资源占用）
- 使用响应式容器适配不同屏幕

---

## 📞 获取帮助

- B站上传帮助：https://www.bilibili.com/read/cv8631910
- B站创作者学院：https://member.bilibili.com/academy

---

✅ **完成！现在你可以在网站上展示流式播放的视频了！**




















