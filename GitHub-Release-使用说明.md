# 🚀 GitHub Release 文件分发系统使用说明

## 📋 目录
1. [系统简介](#系统简介)
2. [准备工作](#准备工作)
3. [上传文件到GitHub Release](#上传文件到github-release)
4. [配置应用信息](#配置应用信息)
5. [常见问题](#常见问题)

---

## 🎯 系统简介

这个系统允许你通过 GitHub Release 免费托管和分发大文件（最大2GB），支持：
- ✅ 完全免费
- ✅ 支持1.5GB大文件
- ✅ CDN加速下载（jsDelivr）
- ✅ 稳定可靠

### 工作原理
```
你的文件 → GitHub Release → 网站展示 → 用户下载（CDN加速）
```

---

## 🛠️ 准备工作

### 1. 安装 GitHub CLI

**方法一：使用 winget（推荐）**
```powershell
winget install GitHub.cli
```

**方法二：手动下载**
访问 https://cli.github.com 下载安装

### 2. 登录 GitHub
```powershell
gh auth login
```

按提示选择：
1. GitHub.com
2. HTTPS
3. Yes（登录）
4. Login with a web browser（浏览器登录）

---

## 📤 上传文件到GitHub Release

### 方法一：使用上传脚本（推荐）

```powershell
# 切换到网站目录
cd "D:\个人网页"

# 上传文件
.\upload-to-release.ps1 -FilePath "你的文件.zip" -Version "v1.0.0" -AppName "应用名称" -Description "版本说明"
```

**参数说明：**
- `FilePath`: 文件路径（必填）
- `Version`: 版本号，格式 v1.0.0（必填）
- `AppName`: 应用名称（必填）
- `Description`: 版本说明（可选）

**示例：**
```powershell
.\upload-to-release.ps1 -FilePath "D:\MyApp.zip" -Version "v1.5.0" -AppName "我的超级应用" -Description "修复了重要bug"
```

### 方法二：使用 GitHub CLI 命令

```powershell
# 创建 Release 并上传文件
gh release create v1.0.0 `
  --repo lik699386-ctrl/likaifeng.com `
  --title "应用名称 - v1.0.0" `
  --notes "版本说明" `
  "D:\你的文件.zip"
```

### 方法三：使用 GitHub 网页界面

1. 访问 https://github.com/lik699386-ctrl/likaifeng.com/releases
2. 点击 "Draft a new release"
3. 填写标签（Tag）：v1.0.0
4. 填写标题和说明
5. 拖拽文件上传
6. 点击 "Publish release"

---

## ⚙️ 配置应用信息

上传成功后，脚本会自动生成配置JSON，或者手动编辑 `releases-config.json`：

```json
{
  "apps": [
    {
      "id": 1,
      "name": "我的应用",
      "description": "应用描述",
      "version": "v1.0.0",
      "category": "utility",
      "fileName": "MyApp.zip",
      "fileSize": "1.5 GB",
      "downloadUrl": "https://github.com/lik699386-ctrl/likaifeng.com/releases/download/v1.0.0/MyApp.zip",
      "cdnUrl": "https://cdn.jsdelivr.net/gh/lik699386-ctrl/likaifeng.com@v1.0.0/MyApp.zip",
      "uploadDate": "2024-01-01",
      "icon": null
    }
  ],
  "repo": {
    "owner": "lik699386-ctrl",
    "name": "likaifeng.com",
    "url": "https://github.com/lik699386-ctrl/likaifeng.com"
  },
  "settings": {
    "useCDN": true,
    "autoUpdate": true
  }
}
```

### 字段说明：

| 字段 | 说明 | 必填 |
|------|------|------|
| `id` | 唯一ID | ✅ |
| `name` | 应用名称 | ✅ |
| `description` | 应用描述 | ✅ |
| `version` | 版本号 | ✅ |
| `category` | 分类：productivity/utility/creative/development/other | ✅ |
| `fileName` | 文件名 | ✅ |
| `fileSize` | 文件大小 | ✅ |
| `downloadUrl` | GitHub下载链接 | ✅ |
| `cdnUrl` | CDN加速链接 | 可选 |
| `uploadDate` | 上传日期 | ✅ |
| `icon` | 图标（base64或URL） | 可选 |

### CDN链接格式：
```
https://cdn.jsdelivr.net/gh/{用户名}/{仓库名}@{版本号}/{文件名}
```

例如：
```
https://cdn.jsdelivr.net/gh/lik699386-ctrl/likaifeng.com@v1.0.0/MyApp.zip
```

---

## ❓ 常见问题

### Q1: 文件超过2GB怎么办？
**A:** GitHub Release单文件限制2GB。解决方案：
1. 压缩文件
2. 分卷压缩（zip分卷）
3. 使用其他方案（云存储）

### Q2: 上传速度慢？
**A:** 
- 使用稳定网络
- 考虑使用代理
- 分时段上传（避开高峰）

### Q3: CDN加速不生效？
**A:**
- jsDelivr有12小时缓存延迟
- 检查CDN链接格式是否正确
- 确保版本号正确（需要是Git Tag）

### Q4: 如何删除旧版本？
**A:**
```powershell
# 删除 Release
gh release delete v1.0.0 --repo lik699386-ctrl/likaifeng.com --yes
```

### Q5: 如何更新应用？
**A:**
1. 上传新版本（新的版本号）
2. 更新 `releases-config.json`
3. 提交并推送到GitHub

### Q6: 下载链接失效？
**A:** 检查：
- Release是否还存在
- 文件是否被删除
- 链接格式是否正确

---

## 🔗 快速链接

- 仓库地址：https://github.com/lik699386-ctrl/likaifeng.com
- Releases页面：https://github.com/lik699386-ctrl/likaifeng.com/releases
- GitHub CLI文档：https://cli.github.com/manual/
- jsDelivr文档：https://www.jsdelivr.com/

---

## 📝 版本管理建议

### 版本号规则（语义化版本）
- **v1.0.0** - 主版本.次版本.修订号
- **v1.0.0** → **v1.0.1** - 修复bug
- **v1.0.0** → **v1.1.0** - 新功能
- **v1.0.0** → **v2.0.0** - 重大更新

### 文件命名建议
```
AppName-v1.0.0-windows-x64.zip
应用名称-版本号-平台-架构.扩展名
```

---

## 🎉 完成！

现在你可以：
1. ✅ 上传1.5GB大文件到GitHub Release
2. ✅ 通过CDN加速分发
3. ✅ 在网站上展示和下载
4. ✅ 完全免费使用

有问题？查看 [GitHub Issues](https://github.com/lik699386-ctrl/likaifeng.com/issues)

