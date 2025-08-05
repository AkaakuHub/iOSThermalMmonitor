#!/bin/bash

# iOS開発環境セットアップスクリプト

set -e

echo "🚀 iOS開発環境のセットアップを開始します..."

# Xcodeの存在確認
echo "📱 Xcodeの確認中..."
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ エラー: Xcodeがインストールされていません"
    echo "App StoreからXcodeをインストールしてください"
    exit 1
fi

echo "✅ Xcode が見つかりました"
xcodebuild -version

# iOS Simulatorの確認
echo "📱 iOS Simulatorの確認中..."
SIMULATOR_LIST=$(xcrun simctl list devices available | grep iPhone)
if [ -z "$SIMULATOR_LIST" ]; then
    echo "❌ エラー: iOSシミュレーターが見つかりません"
    echo "Xcodeを起動してiOSシミュレーターをインストールしてください"
    exit 1
fi

echo "✅ 利用可能なシミュレーター:"
echo "$SIMULATOR_LIST"

# デベロッパーアカウントの確認
echo "👤 Apple Developer設定の確認..."
if ! xcrun security find-identity -v -p codesigning 2>/dev/null | grep -q "Developer"; then
    echo "⚠️  警告: 署名用の証明書が見つかりません"
    echo "実機でテストする場合は、Apple Developerアカウントが必要です"
    echo "シミュレーターでのテストは可能です"
else
    echo "✅ 開発者証明書が見つかりました"
fi

# プロジェクトディレクトリの確認
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "📁 プロジェクトディレクトリ: $PROJECT_DIR"

# Xcodeプロジェクトの確認
if [ ! -f "$PROJECT_DIR/ThermalMonitor.xcodeproj/project.pbxproj" ]; then
    echo "❌ エラー: Xcodeプロジェクトが見つかりません"
    exit 1
fi

echo "✅ Xcodeプロジェクトが見つかりました"

# 権限の設定
echo "🔐 ファイル権限の設定..."
chmod +x "$PROJECT_DIR/scripts/"*.sh
chmod +x "$PROJECT_DIR/Makefile"

echo ""
echo "🎉 セットアップが完了しました!"
echo ""
echo "次のコマンドでアプリを起動できます:"
echo "  make run-sim      # シミュレーターで実行"
echo "  make xcode        # Xcodeでプロジェクトを開く"
echo ""
echo "実機にインストールする場合:"
echo "  1. make xcode でXcodeを開く"
echo "  2. デバイスを接続"
echo "  3. デバイスを選択してRun(⌘+R)"
echo ""