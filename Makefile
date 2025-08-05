.PHONY: run build test clean help

# 変数定義
PROJECT_NAME = ThermalMonitor
SCHEME = ThermalMonitor
CONFIGURATION = Debug
DERIVED_DATA_PATH = ./DerivedData

# シミュレーターで実行
run:
	@echo "🚀 シミュレーターでアプリを実行します..."
	open $(PROJECT_NAME).xcodeproj
	@echo "✅ Xcodeが開きました。Run ボタン (⌘+R) を押してください"

# プロジェクトビルド
build:
	@echo "🔨 プロジェクトをビルドしています..."
	xcodebuild -project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-destination 'platform=iOS Simulator,name=iPhone 16' \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		build

# テスト実行
test:
	@echo "🧪 テストを実行しています..."
	xcodebuild test -project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=iPhone 16' \
		-derivedDataPath $(DERIVED_DATA_PATH)

# クリーンアップ
clean:
	@echo "🧹 クリーンアップしています..."
	xcodebuild -project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		clean
	rm -rf $(DERIVED_DATA_PATH)

# ヘルプ
help:
	@echo "🚀 ThermalMonitor - 利用可能なコマンド:"
	@echo ""
	@echo "  make run     - シミュレーターで実行"
	@echo "  make build   - プロジェクトビルド"
	@echo "  make test    - テスト実行"
	@echo "  make clean   - クリーンアップ"
	@echo "  make help    - このヘルプを表示"