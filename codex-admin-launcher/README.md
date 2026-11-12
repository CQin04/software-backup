# ChatGPT / Codex 管理员启动器

双击一个 BAT 文件，通过 Windows 管理员确认后，重新启动桌面应用。PowerShell 脚本已嵌入，不需要额外的 `.ps1` 文件。

## 使用

1. 打开 [ChatGPT-Admin.bat](../ChatGPT-Admin.bat)，使用 GitHub 的 **Download raw file** 下载，保留 `.bat` 扩展名。
2. 先保存正在进行的工作：脚本会强制关闭同一程序路径下的现有桌面应用进程。
3. 双击文件，在 Windows 管理员权限提示中选择“是”。
4. 应用启动后可以关闭启动器窗口。

## 适用范围

- Windows，使用系统自带的 Windows PowerShell。
- 当前用户已安装包名为 `OpenAI.Codex` 的 MSIX 桌面应用。
- 自动查找安装目录中的 `app\ChatGPT.exe`、`app\Codex.exe` 或 `app\Codex (Beta).exe`，无需填写用户名、安装路径或版本号。
- 通过 `--do-not-de-elevate` 参数启动；适用性取决于应用是否继续支持该启动方式。

这是针对上述安装形式的启动器。其他安装方式或未来应用结构变化可能需要修改脚本。

## 验证记录

2026-11-02，Windows 上的 `OpenAI.Codex 26.1027.3384.0` 已实际运行，随后在应用会话中检测到管理员身份和 High 完整性级别。其他电脑和版本尚未实测。
