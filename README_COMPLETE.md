# HyperNode Complete Edition

**企业级分布式AI节点系统 - 完整功能版**

![Version](https://img.shields.io/badge/Version-2.0.0-blue)
![Python](https://img.shields.io/badge/Python-3.8%2B-green)
![Windows](https://img.shields.io/badge/Windows-7%2B%2C%2010%2C%2011-success)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 🚀 概述

HyperNode Complete Edition 是一个功能完整的分布式AI节点系统，专为企业级应用设计。它提供了实时监控、远程执行、文件管理、自动更新等全套功能，支持通过MQTT协议与AI助手进行双向通信。

## ✨ 核心特性

### 🔧 系统功能
- **实时监控** - CPU、内存、磁盘、网络实时监控
- **硬件信息** - 详细的硬件信息收集和报告
- **远程执行** - 安全的远程命令执行（白名单机制）
- **文件管理** - 文件列表、读取、写入操作
- **进程管理** - 进程查看和控制
- **服务管理** - Windows服务状态和控制

### 🔄 管理功能
- **自动更新** - 每小时检查GitHub更新
- **插件系统** - 可扩展的插件架构
- **配置管理** - 动态配置加载和保存
- **日志系统** - 完整的日志记录和轮转
- **备份恢复** - 系统配置和数据备份

### 🛡️ 安全功能
- **命令白名单** - 只允许安全的系统命令
- **输入验证** - 所有输入都经过严格验证
- **加密支持** - 可选的数据加密功能
- **访问控制** - 基于节点的访问控制

### 🌐 网络功能
- **多MQTT代理** - 支持3个公共MQTT代理
- **自动重连** - 网络中断时自动重连
- **心跳检测** - 30秒心跳确保连接状态
- **广播消息** - 支持广播消息接收

## 📦 安装

### 快速安装（推荐）
```powershell
# 下载安装脚本
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fguod/hypernode-global/main/install_complete.bat" -OutFile "install.bat"

# 运行安装
.\install.bat
```

### 一键安装
```powershell
# 一行命令安装（需要管理员权限）
irm https://raw.githubusercontent.com/fguod/hypernode-global/main/install_complete.bat | iex
```

### 手动安装
```powershell
# 1. 创建目录
mkdir "$env:USERPROFILE\.hypernode_complete"
cd "$env:USERPROFILE\.hypernode_complete"

# 2. 下载主程序
$url = "https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py"
(New-Object System.Net.WebClient).DownloadFile($url, "hypernode_complete.py")

# 3. 安装依赖
python -m pip install paho-mqtt psutil requests cryptography

# 4. 运行
python hypernode_complete.py
```

## 🎯 使用指南

### 启动方式
```cmd
:: 方式1: 批处理文件
start.bat

:: 方式2: PowerShell
.\start.ps1

:: 方式3: 服务模式
service.bat

:: 方式4: 直接运行
python hypernode_complete.py
```

### 服务管理
```cmd
:: 启动服务
service.bat
:: 选择选项1

:: 停止服务
service.bat
:: 选择选项2

:: 查看日志
service.bat
:: 选择选项4

:: 检查状态
service.bat
:: 选择选项5
```

## 📡 MQTT通信

### 主题结构
```
hypernode/complete/commands/{node_id}    # 接收命令
hypernode/complete/responses             # 发送响应
hypernode/complete/heartbeat             # 心跳消息
hypernode/complete/broadcast             # 广播消息
```

### 支持的MQTT代理
1. **broker.emqx.io:1883** - 主要代理（推荐）
2. **test.mosquitto.org:1883** - 备用代理
3. **mqtt.eclipseprojects.io:1883** - 备用代理

### 消息格式
```json
{
  "from": "COMPLETE-XXXX-XXXX",
  "type": "command_response",
  "timestamp": "2026-03-06T01:30:00",
  "data": {
    "command": "info",
    "response": {
      "status": "success",
      "data": { ... }
    }
  }
}
```

## 🔧 命令参考

### 系统命令
| 命令 | 描述 | 示例 |
|------|------|------|
| `ping` | 测试连接 | `{"command": "ping"}` |
| `info` | 获取基本信息 | `{"command": "info"}` |
| `system` | 获取详细系统信息 | `{"command": "system"}` |
| `hardware` | 获取硬件信息 | `{"command": "hardware"}` |
| `network` | 获取网络信息 | `{"command": "network"}` |

### 执行命令
| 命令 | 描述 | 示例 |
|------|------|------|
| `execute` | 执行系统命令 | `{"command": "execute", "data": {"command": "dir"}}` |
| `script` | 执行Python脚本 | `{"command": "script", "data": {"script": "print('hello')"}}` |

### 文件命令
| 命令 | 描述 | 示例 |
|------|------|------|
| `file_list` | 列出目录内容 | `{"command": "file_list", "data": {"path": "."}}` |
| `file_read` | 读取文件内容 | `{"command": "file_read", "data": {"path": "config.json"}}` |
| `file_write` | 写入文件内容 | `{"command": "file_write", "data": {"path": "test.txt", "content": "hello"}}` |

### 管理命令
| 命令 | 描述 | 示例 |
|------|------|------|
| `process_list` | 列出进程 | `{"command": "process_list"}` |
| `process_kill` | 结束进程 | `{"command": "process_kill", "data": {"pid": 1234}}` |
| `service_status` | 服务状态 | `{"command": "service_status", "data": {"service": "wuauserv"}}` |
| `service_control` | 控制服务 | `{"command": "service_control", "data": {"service": "wuauserv", "action": "start"}}` |

### 更新命令
| 命令 | 描述 | 示例 |
|------|------|------|
| `update_check` | 检查更新 | `{"command": "update_check"}` |
| `update_install` | 安装更新 | `{"command": "update_install"}` |

### 插件命令
| 命令 | 描述 | 示例 |
|------|------|------|
| `plugin_list` | 列出插件 | `{"command": "plugin_list"}` |
| `plugin_install` | 安装插件 | `{"command": "plugin_install", "data": {"plugin": "monitoring"}}` |
| `plugin_remove` | 移除插件 | `{"command": "plugin_remove", "data": {"plugin": "monitoring"}}` |

### 配置命令
| 命令 | 描述 | 示例 |
|------|------|------|
| `config_get` | 获取配置 | `{"command": "config_get", "data": {"key": "mqtt_broker"}}` |
| `config_set` | 设置配置 | `{"command": "config_set", "data": {"key": "log_level", "value": "DEBUG"}}` |

### 日志命令
| 命令 | 描述 | 示例 |
|------|------|------|
| `log_view` | 查看日志 | `{"command": "log_view", "data": {"lines": 100}}` |
| `log_clear` | 清除日志 | `{"command": "log_clear"}` |

### 任务命令
| 命令 | 描述 | 示例 |
|------|------|------|
| `task_schedule` | 计划任务 | `{"command": "task_schedule", "data": {"task": "backup", "schedule": "0 2 * * *"}}` |
| `task_list` | 列出任务 | `{"command": "task_list"}` |
| `task_remove` | 移除任务 | `{"command": "task_remove", "data": {"task_id": "backup"}}` |

### 安全命令
| 命令 | 描述 | 示例 |
|------|------|------|
| `encrypt` | 加密数据 | `{"command": "encrypt", "data": {"data": "secret"}}` |
| `decrypt` | 解密数据 | `{"command": "decrypt", "data": {"encrypted": "..."}}` |
| `hash` | 计算哈希 | `{"command": "hash", "data": {"data": "text"}}` |
| `benchmark` | 性能测试 | `{"command": "benchmark"}` |

## 📊 系统要求

### 最低要求
- **操作系统**: Windows 7/8/10/11 (64位推荐)
- **Python**: 3.8 或更高版本
- **内存**: 512MB RAM
- **磁盘空间**: 100MB 可用空间
- **网络**: 互联网连接 (用于MQTT通信)

### 推荐配置
- **操作系统**: Windows 10/11 64位
- **Python**: 3.11 或更高版本
- **内存**: 2GB RAM 或更多
- **磁盘空间**: 1GB 可用空间
- **网络**: 稳定的互联网连接

## 🔧 配置

### 配置文件位置
```
%USERPROFILE%\.hypernode_complete\config.json
```

### 配置示例
```json
{
  "version": "2.0.0",
  "node_id": "AUTO_GENERATED",
  "mqtt_broker": "broker.emqx.io",
  "mqtt_port": 1883,
  "auto_update": true,
  "heartbeat_interval": 30,
  "log_level": "INFO",
  "features": {
    "real_time_monitoring": true,
    "hardware_info": true,
    "remote_execution": true,
    "file_transfer": true,
    "auto_update": true,
    "plugin_system": true,
    "web_interface": false,
    "encryption": true,
    "backup_restore": true,
    "scheduled_tasks": true
  }
}
```

## 📁 目录结构

```
.hypernode_complete/
├── hypernode_complete.py      # 主程序
├── config.json                # 配置文件
├── VERSION                    # 版本文件
├── start.bat                  # 启动脚本
├── start.ps1                  # PowerShell启动脚本
├── service.bat                # 服务管理脚本
├── logs/                      # 日志目录
│   ├── hypernode_20260306.log
│   └── ...
├── data/                      # 数据目录
│   └── temp_scripts/
├── plugins/                   # 插件目录
│   └── plugin.json
└── backups/                   # 备份目录
    └── config_backup_20260306.json
```

## 🛠️ 故障排除

### 常见问题

#### 1. Python未找到
```cmd
:: 检查Python是否在PATH中
python --version

:: 如果未找到，手动添加Python到PATH
setx PATH "%PATH%;C:\Python311"
```

#### 2. 网络连接失败
```powershell
# 测试MQTT代理连接
Test-NetConnection -ComputerName broker.emqx.io -Port 1883

# 如果失败，尝试备用代理
# 修改config.json中的mqtt_broker设置
```

#### 3. 权限不足
```cmd
:: 以管理员身份运行
右键点击 -> 以管理员身份运行
```

#### 4. 防火墙阻止
```powershell
# 添加防火墙规则
New-NetFirewallRule -DisplayName "HyperNode MQTT" -Direction Outbound -Protocol TCP -RemotePort 1883 -Action Allow
```

#### 5. 依赖安装失败
```cmd
:: 手动安装依赖
python -m pip install paho-mqtt --user
python -m pip install psutil --user
```

### 日志查看
```cmd
:: 查看最新日志
type "%USERPROFILE%\.hypernode_complete\logs\hypernode_*.log" | more

:: 查看错误日志
findstr /i "error fail" "%USERPROFILE%\.hypernode_complete\logs\*.log"
```

## 🔄 更新

### 自动更新
系统每小时自动检查GitHub更新，如果有新版本可用，会通过MQTT通知。

### 手动更新
```cmd
cd "%USERPROFILE%\.hypernode_complete"
python -c "import urllib.request; urllib.request.urlretrieve('https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py', 'hypernode_complete_new.py')"
move /y hypernode_complete_new.py hypernode_complete.py
```

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🤝 贡献

欢迎提交问题和拉取请求！

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开拉取请求

## 📞 支持

- **GitHub Issues**: [问题报告](https://github.com/fguod/hypernode-global/issues)
- **文档**: [README](https://github.com/fguod/hypernode-global)
- **邮箱**: fguod@users.noreply.github.com

## 🎉 特别感谢

感谢所有贡献者和用户的支持！

---

**HyperNode Complete Edition** - 企业级分布式AI节点系统 🚀

*最后更新: 2026-03-06*