#!/bin/bash
# ============================================
# HelloKitty 个人工作台 — 自动搭建脚本
# 在 Mac 终端运行: bash setup.sh
# ============================================

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "🌸 HelloKitty 个人工作台 — 自动搭建"
echo "========================================"

# 1. 检查 XcodeGen 是否已安装
if ! command -v xcodegen &> /dev/null; then
    echo "📦 正在安装 XcodeGen..."
    brew install xcodegen
fi

# 2. 检查 Bundler（用于 CocoaPods/Swift 依赖）
if ! command -v bundle &> /dev/null; then
    gem install bundler
fi

# 3. 生成 Xcode 工程
echo "🔧 正在生成 Xcode 工程..."
cd "$PROJECT_DIR"
xcodegen generate --spec project.yml

echo ""
echo "✅ 搭建完成！"
echo ""
echo "📱 下一步:"
echo "   1. 双击打开 HelloKittyWorkbench.xcodeproj"
echo "   2. 选择模拟器 (iPhone 15 Pro)"
echo "   3. 按 Cmd+R 编译运行"
echo ""
echo "🎀 粉色 Hello Kitty 主题工作台，祝你使用愉快！"
