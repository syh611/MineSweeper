# 恋爱任务簿（Couple Task Rewards）MVP




## 00. 没有 Git、没有开发环境的最简方式（直接点链接下载）

你不需要安装 Git / Flutter / Python。

### 方案 A：GitHub Releases（最推荐）
1. 打开仓库的 **Releases** 页面。
2. 下载：
   - `app-release.apk`（安卓安装包）
   - `download-site.zip`（下载落地页 + Web 预览）

### 方案 B：GitHub Actions 构建产物
1. 打开仓库 **Actions** → `Build Release Assets`。
2. 点击 `Run workflow`。
3. 构建完成后，在该次运行页面下载 `couple-task-release-assets`。

> 仓库已内置自动构建工作流：`.github/workflows/build_release.yml`。

## 0. 你要的“直接可运行 + 点击下载”最快方式

只要你本机有 Flutter，执行两条命令：

### macOS / Linux
```bash
./scripts/package_download_site.sh
./scripts/run_download_site.sh
```

### Windows PowerShell
```powershell
# 先进入项目根目录（非常重要）
cd 你的项目目录

powershell -ExecutionPolicy Bypass -File .\scripts\package_download_site.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\run_download_site.ps1
```

### Windows 一键启动（推荐）
```bat
start_windows.bat
```

然后打开浏览器访问：`http://127.0.0.1:8080`

你会看到一个可点击下载的页面：
- **安卓版下载**：直接下载 `app-release.apk`
- **网页预览版**：直接打开 Flutter Web

> 如果要给别人用，把 `dist/` 目录上传到任意静态托管（Netlify/Vercel/GitHub Pages），即可得到公网点击链接。

> Flutter + Supabase 的双人情侣任务奖励应用。核心目标：**双人私密、低并发、仪式感、逻辑稳定**。

## 1. 功能概览
- 账号注册/登录（昵称、性别、伴侣称呼）
- 配对码绑定（仅支持一对一）
- 任务生命周期：待接受 → 接受/拒绝 → 提交完成 → 确认发放/驳回
- 完成证明（二选一：图片或一句话）
- 性别币种规则（女生=菲币，男生=小币）
- 钱包余额、累计获得、连续完成 streak、徽章
- 下载落地页（H5）+ 二维码接入方案

## 2. 仓库结构

```text
.
├── flutter_app/                    # Flutter APP
│   ├── lib/
│   │   ├── app/
│   │   ├── core/
│   │   └── features/
│   ├── supabase/init.sql           # 表结构 + RLS + RPC + 初始化
│   └── .env.example
├── landing_page/                   # 移动端下载/预览落地页（H5）
│   └── index.html
└── README.md
```

## 3. 关键业务规则（已在 SQL + Flutter 实现）
1. 奖励币种由接收者性别自动决定，不允许手动切换。
2. 发布任务不会扣除发布者余额。
3. 任务确认完成后，调用 `confirm_task_and_reward` 原子发放奖励并更新 streak。
4. 提交完成时必须满足：图片或文字至少一个。

## 4. Flutter 启动

```bash
cd flutter_app
cp .env.example .env
# 填入 Supabase URL/ANON KEY
flutter pub get
flutter run
```

## 5. Supabase 初始化
1. 在 Supabase 创建项目；
2. 打开 SQL Editor，执行：`flutter_app/supabase/init.sql`；
3. Storage 创建 bucket：`proofs`（私有）；
4. 在 Authentication 打开邮箱密码登录。

## 6. 测试账号建议
- 女方：`faye@example.com`，性别 female，初始菲币 10
- 男方：`chris@example.com`，性别 male，初始小币 10
- 两人互填配对码完成绑定。

## 7. 下载落地页（H5）
位于 `landing_page/index.html`，包含：
- 安卓下载按钮（可直链 APK）
- iOS TestFlight 入口
- Web Demo 入口
- 二维码区域（落地页链接）
- 微信内打开提示

### 部署（示例）
- **Vercel**：Import repo → Root 选 `landing_page` → Deploy
- **Netlify**：New site from Git → Base dir=`landing_page`
- **Supabase Hosting**：可将落地页静态文件部署到 hosting。

## 8. 二维码生成
公网落地页例如：`https://your-domain.com`
- 命令行：
```bash
python -m pip install qrcode[pil]
python - <<'PY'
import qrcode
url='https://your-domain.com'
img=qrcode.make(url)
img.save('landing_qr.png')
PY
```

## 9. APK 与 TestFlight
- Android APK：`flutter build apk --release`，将产物挂到落地页按钮
- iOS：`flutter build ipa` 后上传 App Store Connect，使用 TestFlight 分发



## 10. 如何产出前端截图（可直接用于汇报/落地页）

### 方案 A：Flutter 官方截图命令（推荐）
```bash
./scripts/take_screenshots.sh
```
输出目录：`artifacts/screenshots/`。

### 方案 B：手动截图
1. 运行 `flutter run`。
2. 在模拟器打开任务页/货币页/创建任务页。
3. 使用 iOS Simulator 或 Android Emulator 自带截图。

## 11. 如何生成“点击即可下载”的链接

### Android APK 直链
1. 先打包 APK：
```bash
cd flutter_app
flutter build apk --release
```
2. 上传 `build/app/outputs/flutter-apk/app-release.apk` 到任一公网静态托管（如 GitHub Releases、OSS、S3、Supabase Storage 公共桶）。
3. 把 `landing_page/index.html` 的 APK 按钮链接替换成该公网 URL。

### 一键发布落地页（Netlify）
```bash
NETLIFY_AUTH_TOKEN=xxx NETLIFY_SITE_ID=xxx ./scripts/deploy_landing_netlify.sh
```
发布后会得到公网域名，扫码即可打开落地页，再点击按钮下载 APK。

> 说明：当前仓库里的链接是占位符（`your-domain.com` / `your-web-demo-url.example.com`），需要替换为你的真实公网地址。


### Windows 常见报错怎么解决
1. `*.ps1 does not exist`：你当前不在项目根目录。先 `cd` 到仓库目录再执行命令。
2. `py is not recognized`：新版 `run_download_site.ps1` 已不依赖 Python。
3. `*.sh is not recognized`：PowerShell 不能直接执行 `.sh`，请使用 `.ps1` 或 `start_windows.bat`。
