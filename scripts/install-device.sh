#!/bin/bash

# iOS実機インストール支援スクリプト

set -e

echo "📱 iOS実機へのインストールガイド"
echo "=================================="

# 接続されたデバイスの確認
echo "🔍 接続されたデバイスを確認中..."
DEVICES=$(xcrun xctrace list devices 2>/dev/null | grep -E "iPhone|iPad" | grep -v Simulator || true)

if [ -z "$DEVICES" ]; then
    echo "❌ iOSデバイスが見つかりません"
    echo ""
    echo "デバイスを接続する手順:"
    echo "1. USBケーブルでiPhoneをMacに接続"
    echo "2. iPhone側で「このコンピュータを信頼しますか？」で「信頼」をタップ"
    echo "3. 再度このスクリプトを実行"
    exit 1
fi

echo "✅ 以下のデバイスが見つかりました:"
echo "$DEVICES"
echo ""

# デベロッパーモードの確認
echo "⚙️  デベロッパーモードの確認"
echo "デバイスでデベロッパーモードが有効になっているかご確認ください:"
echo "設定 > プライバシーとセキュリティ > デベロッパーモード > オン"
echo ""

# 証明書の確認
echo "🔐 コード署名証明書の確認..."
CERTIFICATES=$(xcrun security find-identity -v -p codesigning 2>/dev/null | grep "iPhone Developer\|Apple Development" || true)

if [ -z "$CERTIFICATES" ]; then
    echo "❌ 開発用証明書が見つかりません"
    echo ""
    echo "Apple Developerアカウントが必要です:"
    echo "1. https://developer.apple.com でアカウント作成"
    echo "2. Xcodeでアカウントを追加: Xcode > Preferences > Accounts"
    echo "3. 「Manage Certificates」で証明書を作成"
    echo ""
    echo "または無料の開発証明書を使用:"
    echo "1. Xcodeでプロジェクトを開く"
    echo "2. Team を「Personal Team」に設定"
    echo "3. Bundle Identifier を一意の名前に変更"
    exit 1
fi

echo "✅ 以下の証明書が利用可能です:"
echo "$CERTIFICATES"
echo ""

# Xcodeでのインストール手順
echo "🚀 Xcodeでのインストール手順:"
echo "1. make xcode でプロジェクトを開く"
echo "2. 上部のデバイス選択で接続されたiPhoneを選択"
echo "3. 必要に応じてBundle Identifierを変更"
echo "4. Team設定を確認"
echo "5. Run ボタン (⌘+R) を押す"
echo ""

# 自動実行オプション
read -p "Xcodeでプロジェクトを開きますか？ (y/N): " OPEN_XCODE
if [[ $OPEN_XCODE =~ ^[Yy]$ ]]; then
    echo "🔧 Xcodeを開いています..."
    open "$(dirname "$0")/../ThermalMonitor.xcodeproj"
    echo "✅ Xcodeが開きました。上記の手順に従ってインストールしてください。"
fi

echo ""
echo "💡 トラブルシューティング:"
echo "- 「デベロッパーを検証できません」エラー: 設定 > 一般 > VPNとデバイス管理"
echo "- ビルドエラー: Bundle Identifierを一意の名前に変更"
echo "- 証明書エラー: Teamを「Personal Team」に設定"