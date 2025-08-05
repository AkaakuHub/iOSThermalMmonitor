# ThermalMonitor - iPhoneサーマルモニターアプリ

iPhone/iPadの熱状態をリアルタイムで監視し、状態変化時に通知を送信するアプリです。

## 🌡️ 機能

- **リアルタイムサーマルモニター**: デバイスの熱状態を常時監視
- **状態変化通知**: 熱状態が変化した際に自動でプッシュ通知
- **シンプルなUI**: 現在の状態と推奨事項を分かりやすく表示
- **4段階の状態表示**: 正常・良好・注意・危険の4レベル

## 📱 動作環境

- iOS 18.0以降
- iPhone/iPad対応
- Xcode 16.0以降（開発時）
- Swift 6.0

## 🚀 クイックスタート

### 1. 環境セットアップ
```bash
# セットアップスクリプトを実行
./scripts/setup-ios.sh
```

### 2. シミュレーターで実行（推奨）
```bash
# 最も簡単な方法：Xcodeで直接実行
make run

# 詳細版（ビルドからインストールまで）
make run-sim
```

### 3. 実機にインストール
```bash
# インストールガイドを表示
./scripts/install-device.sh

# またはXcodeで直接開く
make xcode
```

### 💡 おすすめの実行方法
1. `make run` でXcodeを開く
2. iPhone 16シミュレーターを選択
3. Run ボタン (⌘+R) を押す

これが最も確実で簡単な方法です！

## 📁 プロジェクト構成

```
ThermalMonitor/
├── ThermalMonitor/
│   ├── Sources/
│   │   └── ThermalMonitor/
│   │       ├── ThermalMonitorApp.swift    # メインアプリ
│   │       ├── ContentView.swift          # メインUI
│   │       └── ThermalManager.swift       # サーマルモニターロジック
│   └── Resources/
│       └── Info.plist                     # アプリ設定
├── scripts/
│   ├── setup-ios.sh                       # 環境セットアップ
│   └── install-device.sh                  # 実機インストール支援
├── docs/                                  # ドキュメント
├── Makefile                               # ビルド設定
├── Package.swift                          # Swift Package Manager
└── README.md                              # このファイル
```

## 🛠️ 利用可能なコマンド

```bash
make help              # ヘルプを表示
make setup             # 開発環境セットアップ
make build             # プロジェクトビルド
make build-sim         # シミュレーター用ビルド
make build-device      # 実機用ビルド
make run-sim           # シミュレーターで実行
make test              # テスト実行
make clean             # クリーンアップ
make xcode             # Xcodeでプロジェクトを開く
```

## 📋 実機インストール手順

### 必要な準備
1. **Xcode 15.0以降** をインストール
2. **Apple Developer アカウント** (無料でも可)
3. **iOSデバイス** をUSB接続

### インストール手順
1. デバイスをMacに接続
2. デバイス側で「このコンピュータを信頼」を選択
3. 以下のコマンドを実行:
   ```bash
   ./scripts/install-device.sh
   ```
4. Xcodeが開いたら:
   - デバイスを選択
   - 必要に応じてBundle Identifierを変更
   - Run (⌘+R) を実行

### トラブルシューティング

#### 「デベロッパーを検証できません」エラー
- デバイスの 設定 > 一般 > VPNとデバイス管理 でアプリを信頼

#### ビルドエラーが発生する場合
- Bundle Identifier を一意の名前に変更
- Team を「Personal Team」に設定

#### 証明書エラーの場合
- Xcode > Preferences > Accounts でApple IDを追加
- 「Manage Certificates」で開発証明書を作成

## 🌡️ 温度状態について

| 状態 | 色 | 説明 |
|------|----|----|
| **正常** | 🟢 緑 | デバイスは正常に動作中 |
| **良好** | 🟡 黄 | 軽微な発熱、重い処理は控えめに |
| **注意** | 🟠 橙 | 高温状態、処理軽減を推奨 |
| **危険** | 🔴 赤 | 緊急冷却が必要 |

## 🔔 通知機能

アプリは以下の場合に通知を送信します:
- 温度状態が変化した時
- 危険レベルに達した時
- 正常レベルに戻った時

初回起動時に通知許可をリクエストします。

## 🧪 テスト方法

### シミュレーターでのテスト
```bash
make test
```

### 実機での熱状態テスト
Xcodeの「Device Conditions」機能を使用:
1. Window > Devices and Simulators
2. 接続されたデバイスを選択
3. Device Conditions で Thermal State を変更

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🤝 貢献

バグ報告や機能提案は、GitHubのIssuesでお願いします。

## 📚 技術詳細

このアプリは以下の最新技術を使用しています:

### Swift 6 & iOS 18対応
- **@Observable**: 新しいObservation APIを使用
- **Strict Concurrency**: Swift 6の並行性安全機能
- **os.log Logger**: 構造化ログ出力

### SwiftUI 6新機能
- **NavigationStack**: 最新のナビゲーション
- **Material**: 新しい背景エフェクト
- **Symbol Effects**: アイコンアニメーション
- **Content Transitions**: スムーズな状態変化

### iOS 18通知機能
- **Interruption Levels**: 通知の重要度レベル
- **Relevance Score**: 通知の関連度
- **Provisional Authorization**: 暫定的な通知許可

### 基盤技術
- **ProcessInfo.ThermalState**: iOS公式の熱状態監視API
- **UserNotifications**: 高度なプッシュ通知
- **Swift Concurrency**: AsyncStream による非同期処理

詳細な技術仕様は `docs/cc.md` を参照してください。