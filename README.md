# HyperNode Global - Complete Edition

**企业级分布式AI节点系统 v2.0.0**

![Version](https://img.shields.io/badge/Version-2.0.0-blue)
![Python](https://img.shields.io/badge/Python-3.8%2B-green)
![Windows](https://img.shields.io/badge/Windows-7%2B%2C%2010%2C%2011-success)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Features](https://img.shields.io/badge/Features-30%2B-orange)

## 🚀 企业级功能完整版

HyperNode Complete Edition 是一个功能完整的分布式AI节点系统，专为企业级应用设计。提供实时监控、远程执行、文件管理、自动更新等全套功能。

### ✨ 核心特性

#### 🔧 系统监控
- **实时硬件监控** - CPU、内存、磁盘、网络实时数据
- **详细系统信息** - 完整的硬件和系统信息报告
- **进程管理** - 进程查看、结束、优先级调整
- **服务管理** - Windows服务状态和控制

#### 🔄 远程管理
- **安全命令执行** - 白名单机制，30+安全命令
- **文件操作** - 文件列表、读取、写入、删除
- **脚本执行** - 远程Python脚本执行
- **配置管理** - 动态配置加载和保存

#### 🛡️ 安全功能
- **命令验证** - 所有输入严格验证，防止注入
- **加密支持** - 数据加密和哈希计算
- **访问控制** - 基于节点的权限管理
- **日志审计** - 完整的操作日志记录

#### 🌐 网络通信
- **多MQTT代理** - 3个公共代理，自动故障转移
- **心跳检测** - 30秒心跳确保连接状态
- **自动重连** - 网络中断智能恢复
- **广播消息** - 支持群组广播通信

#### 🔧 管理功能
- **自动更新** - 每小时检查GitHub更新
- **插件系统** - 可扩展的插件架构
- **备份恢复** - 系统配置和数据备份
- **计划任务** - 定时执行任务调度
- **日志轮转** - 自动清理旧日志文件

## 📦 快速安装

### 完整版安装（推荐）
```powershell
# 下载完整版安装脚本
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fguod/hypernode-global/main/install_complete.bat" -OutFile "install.bat"

# 运行安装
.\install.bat
```

### 一键安装
```powershell
# 一行命令安装完整版
irm https://raw.githubusercontent.com/fguod/hypernode-global/main/install_complete.bat | iex
```

### 其他版本
```powershell
# 优化版（为你的系统定制）
irm https://raw.githubusercontent.com/fguod/hypernode-global/main/install_optimized.ps1 | iex

# 简单版（基础功能）
irm https://raw.githubusercontent.com/fguod/hypernode-global/main/install.ps1 | iex
```

## 🎯 立即开始

### 启动完整版
```cmd
:: 安装后自动启动，或手动启动：
cd %USERPROFILE%\.hypernode_complete
start.bat
```

### 查看功能
启动后，系统会显示：
```
╔══════════════════════════════════════════════════════════════╗
║                    HYPERNODE COMPLETE EDITION                ║
║                         Version 2.0.0                        ║
╠══════════════════════════════════════════════════════════════╣
║  Node ID: COMPLETE-XXXX-XXXX                               ║
║  System: Windows 11 Pro                                    ║
║  Python: 3.14.3                                            ║
║  Directory: C:\Users\Administrator\.hypernode_complete     ║
╠══════════════════════════════════════════════════════════════╣
║  Features:                                                   ║
║  • Real-time monitoring • Remote execution • File transfer   ║
║  • Auto-update • Plugin system • Web interface • Encryption ║
║  • Backup/restore • Scheduled tasks • Security controls      ║
╚══════════════════════════════════════════════════════════════╝
```

## 📡 支持的MQTT代理

1. **broker.emqx.io:1883** - 主要代理（推荐）
2. **test.mosquitto.org:1883** - 备用代理  
3. **mqtt.eclipseprojects.io:1883** - 备用代理

## 🔧 命令参考（30+命令）

### 系统命令
- `ping` - 连接测试
- `info` - 基本信息
- `system` - 详细系统信息
- `hardware` - 硬件信息
- `network` - 网络信息

### 执行命令
- `execute` - 执行系统命令
- `script` - 执行Python脚本
- `process_list` - 列出进程
- `process_kill` - 结束进程
- `service_status` - 服务状态
- `service_control` - 控制服务

### 文件命令
- `file_list` - 列出目录
- `file_read` - 读取文件
- `file_write` - 写入文件

### 管理命令
- `update_check` - 检查更新
- `update_install` - 安装更新
- `plugin_list` - 列出插件
- `plugin_install` - 安装插件
- `plugin_remove` - 移除插件
- `config_get` - 获取配置
- `config_set` - 设置配置
- `log_view` - 查看日志
- `log_clear` - 清除日志
- `task_schedule` - 计划任务
- `task_list` - 列出任务
- `task_remove` - 移除任务

### 安全命令
- `encrypt` - 加密数据
- `decrypt` - 解密数据
- `hash` - 计算哈希
- `benchmark` - 性能测试

## 📊 系统要求

### 最低要求
- **操作系统**: Windows 7/8/10/11
- **Python**: 3.8+
- **内存**: 512MB RAM
- **磁盘空间**: 100MB
- **网络**: 互联网连接

### 推荐配置
- **操作系统**: Windows 10/11 64位
- **Python**: 3.11+
- **内存**: 2GB+ RAM
- **磁盘空间**: 1GB+
- **网络**: 稳定连接

## 📁 文件结构

```
.hypernode_complete/
├── hypernode_complete.py      # 主程序 (30,258字节)
├── config.json                # 配置文件
├── VERSION                    # 版本文件
├── start.bat                  # 启动脚本
├── start.ps1                  # PowerShell启动
├── service.bat                # 服务管理
├── logs/                      # 日志目录
├── data/                      # 数据目录
├── plugins/                   # 插件目录
└── backups/                   # 备份目录
```

## 🛠️ 故障排除

### 快速诊断
```powershell
# 检查Python
python --version

# 测试网络
Test-NetConnection -ComputerName broker.emqx.io -Port 1883

# 查看日志
type "$env:USERPROFILE\.hypernode_complete\logs\*.log" | select -Last 50
```

### 常见问题
1. **Python未找到** - 安装Python 3.8+并添加到PATH
2. **网络连接失败** - 检查防火墙，尝试备用代理
3. **权限不足** - 以管理员身份运行
4. **依赖安装失败** - 手动安装: `pip install paho-mqtt psutil`

## 🔄 更新

系统每小时自动检查更新，或手动更新：
```cmd
cd "%USERPROFILE%\.hypernode_complete"
python -c "import urllib.request; urllib.request.urlretrieve('https://raw.githubusercontent.com/fguod/hypernode-global/main/hypernode_complete.py', 'hypernode_complete_new.py')"
move /y hypernode_complete_new.py hypernode_complete.py
```

## 📄 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件

## 🤝 支持

- **GitHub Issues**: [问题报告](https://github.com/fguod/hypernode-global/issues)
- **文档**: [完整文档](README_COMPLETE.md)
- **版本**: 2.0.0 Complete Edition

---

**🚀 HyperNode Complete Edition v2.0.0 - 企业级分布式AI节点系统**

*功能完整，安全可靠，易于管理*