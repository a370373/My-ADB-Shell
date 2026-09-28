## My ADB Shell 🤡

一個為 Termux 設計的極簡 Android ADB Shell 工具。

它的目標很單純：

«讓 Termux 更方便地透過 Android Wireless Debugging 建立 ADB 連線，並直接進入 Android Shell（UID 2000）。»

不用 Shizuku。
不用 Rish。
不用額外的 Android App。

就是：

Termux
  ↓
ADB
  ↓
Android Wireless Debugging
  ↓
adbd
  ↓
UID 2000 (shell)

---

## ✨ 功能

目前腳本主要負責：

- 🔗 Android Wireless Debugging 配對
- 🔁 自動重試配對
- 🔄 配對失敗後重新輸入資訊
- 📡 ADB 裝置偵測
- 🔍 找不到裝置時使用 "nmap" 作為額外搜尋方式
- 🔐 確認目前 ADB Shell 是否為 "UID 2000"
- 🖥️ 成功後直接進入 Android Shell

最終效果：

$ ./my_adb_shell.sh

======================================
        My ADB Shell / UID 2000
======================================

Pairing IP:Port : xxx.xxx.xxx.xxx:xxxxx
Please enter your verify code : xxxxxx

[+] Pairing SUCCESS.

======================================
 Verifying UID 2000...
======================================

uid=2000(shell) gid=2000(shell) ...

======================================
 SUCCESS
 UID 2000 shell obtained.
======================================

然後直接進入：

shell@android:/$

---

## 🎯 為什麼做這個？

Android 的 Wireless Debugging 本身並不複雜，但從 Termux 使用時，常常需要自己處理：

ADB
├── 啟動 ADB Server
├── Wireless Debugging 配對
├── Pairing Code
├── ADB Connection
├── 裝置偵測
└── adb shell

這個專案只是把這些步驟包成一個簡單的腳本。

不重新發明 ADB。

不實作自己的 Android 權限機制。

不繞過 Android 安全機制。

只是把既有的 ADB 流程整理好。

---

## 🧩 這不是 Shizuku

本工具不依賴：

- Shizuku
- Rish
- Rish/Dex
- Root
- Magisk

它使用 Android 官方 ADB / Wireless Debugging 所提供的正常連線流程。

---

## 🔐 UID 2000 是什麼？

當 ADB 成功連接 Android 裝置後：

adb shell

會由 Android 的：

adbd

建立 Shell Process。

該 Process 通常使用：

UID 2000

也就是：

shell

因此本工具會在進入 Shell 前確認：

uid=2000(shell)

需要注意：

UID 2000 ≠ Root。

Android 的 DAC、SELinux 以及其他系統安全機制仍然存在。

---

## 📱 支援環境

目前定位

Termux only

本專案主要針對：

Android
└── Termux
    └── my_adb_shell.sh

設計。

其他 Linux 發行版理論上可能可以修改後使用，但目前不以它們為目標平台。

---

## 📦 需求

基本需求：

- Android
- Termux
- "adb"
- Android Wireless Debugging
- Bash

如果需要使用腳本中的額外網路搜尋功能：

- "nmap"

例如 Termux：

pkg install android-tools

如果需要：

pkg install nmap

---

## 🚀 使用方式

先確定 Android：

設定
→ 開發人員選項
→ 無線偵錯

開啟 Wireless Debugging。

然後在 Termux 執行：

chmod +x my_adb_shell.sh
./my_adb_shell.sh

依照腳本提示輸入 Wireless Debugging 顯示的配對資訊。

成功後即可進入：

UID 2000 Android Shell

---

## 🏗️ 工作流程

┌──────────────┐
│    Termux    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ my_adb_shell │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     ADB      │
└──────┬───────┘
       │
       ▼
┌────────────────────┐
│ Wireless Debugging │
└─────────┬──────────┘
          │
          ▼
┌──────────────┐
│    adbd      │
└──────┬───────┘
       │
       ▼
┌────────────────────┐
│ UID 2000 / shell   │
└────────────────────┘

---

## ⚠️ 注意事項

Pairing ≠ Connection

Android Wireless Debugging 中：

Pairing

與：

ADB Connection

是兩個不同階段。

Pairing 成功代表 ADB Client 與 Android 裝置建立了信任關係；之後仍需要建立實際的 ADB 連線。

本腳本會嘗試自動處理後續流程。

---

## 🤡 為什麼只有一個 Bash？

因為這個專案本來就不需要更多東西。

沒有：

大型 Framework
大型 Backend
大型 GUI
大型 Android App

只有：

一個 Bash Script
+
ADB

Keep it stupidly simple.

🤣

---

## 📁 專案結構

目前：

my-adb-shell/
├── my_adb_shell.sh
├── README.md
├── LICENSE
└── NOTICE

未來如果真的需要功能增加，再拆分。

目前不為了「看起來像大型專案」而增加不必要的程式碼。

---

## 📜 授權與 ADB

本專案的 Shell Script 與相關整合程式碼，依本專案所使用的 License 發布。

ADB 本身並非本專案原創軟體。

ADB 來自 Android Open Source Project（AOSP），其原始碼、License 與 NOTICE 應以 AOSP 官方內容為準。

如果 Release 包含預編譯的 "adb" binary，該 binary 的授權與來源資訊也應一併保留。

---

## 💡 Project Philosophy

這個專案沒有要取代 ADB。

它只是想把：

「我要從 Termux 進 Android UID 2000 Shell」

這件事情變得簡單一點。

就這樣。

One script.
One ADB.
One shell.

🤡

---

## 📬 聯繫創作者

- Instagram：[a370373/XRH](https://instagram.com/a370373)
- 本人17歲🤔 做的不好請見諒
- 獨立開發 ＆ AI協作
- 緩慢更新 ＆ 除錯
- 純手機Termux 開發👀
- 持續開發中…

---

## 👀作品 & 產品 集

- [Cyber-Fly-Android-Bridge](https://github.com/a370373/Cyber-Fly-Android-Bridge)
- [My-ADB-Shell](https://github.com/a370373/My-ADB-Shell/tree/main)
- [Cyber-Fly](https://github.com/a370373/Cyber-Fly)
- [MyOS](https://github.com/a370373/MyOS)
- [RWM-1:1 Real World Minecraft](https://github.com/a370373/RWM-Real-World-Minecraft)
- [MyAI-Offline Personal AI Agent System](https://github.com/a370373/MyAI-Offline-Personal-AI-Agent-System-/tree/main)
- [WCL - Web Clone Lab](https://github.com/a370373/web-clone-lab/)
- 持續增加中…👀

---

## 🤖 AI 協作

My-ADB-shell 由 a370373/XRH 發起、設計與開發。

開發過程中使用 OpenAI ChatGPT 作為 AI 協作夥伴，協助進行 技術分析、程式碼檢查、除錯 & 文件整理。

產品方向、設計理念 & 最終決策由專案創作者負責。
