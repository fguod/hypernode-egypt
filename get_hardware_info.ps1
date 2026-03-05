# 获取HyperNode节点硬件信息脚本
# 节点ID: COMPLETE-8199DFB1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "获取HyperNode节点硬件信息" -ForegroundColor Yellow
Write-Host "节点ID: COMPLETE-8199DFB1" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 创建Python脚本获取硬件信息
$pythonScript = @'
import paho.mqtt.client as mqtt
import json
import time
import sys

# 配置
NODE_ID = "COMPLETE-8199DFB1"
BROKER = "broker.emqx.io"
PORT = 1883
TIMEOUT = 10  # 等待响应的超时时间（秒）

# 存储响应的变量
response_received = False
response_data = None

def on_connect(client, userdata, flags, rc):
    """连接成功回调"""
    if rc == 0:
        print(f"✅ 已连接到MQTT代理: {BROKER}:{PORT}")
        # 订阅响应主题
        client.subscribe("hypernode/complete/responses")
        print("✅ 已订阅响应主题: hypernode/complete/responses")
    else:
        print(f"❌ 连接失败，错误码: {rc}")
        sys.exit(1)

def on_message(client, userdata, msg):
    """收到消息回调"""
    global response_received, response_data
    
    try:
        payload = msg.payload.decode('utf-8')
        data = json.loads(payload)
        
        # 检查是否是我们节点的响应
        if data.get("from") == NODE_ID and data.get("type") == "command_response":
            command = data.get("data", {}).get("command", "")
            if command == "hardware":
                response_received = True
                response_data = data
                print("✅ 收到硬件信息响应")
    except Exception as e:
        print(f"❌ 解析响应时出错: {e}")

def send_hardware_command():
    """发送硬件信息命令"""
    print("🚀 发送硬件信息请求...")
    
    # 创建MQTT客户端
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message
    
    # 连接并发送命令
    try:
        client.connect(BROKER, PORT, 60)
        client.loop_start()
        
        # 等待连接建立
        time.sleep(2)
        
        # 发送硬件信息命令
        command = {
            "command": "hardware",
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "request_id": "HW_REQ_" + str(int(time.time()))
        }
        
        topic = f"hypernode/complete/commands/{NODE_ID}"
        client.publish(topic, json.dumps(command))
        print(f"📤 命令已发送到主题: {topic}")
        
        # 等待响应
        print(f"⏳ 等待响应 (超时: {TIMEOUT}秒)...")
        start_time = time.time()
        
        while not response_received and (time.time() - start_time) < TIMEOUT:
            time.sleep(0.5)
        
        if response_received and response_data:
            # 显示硬件信息
            print("\n" + "="*60)
            print("🖥️  HARDWARE INFORMATION")
            print("="*60)
            
            response = response_data.get("data", {}).get("response", {})
            status = response.get("status", "unknown")
            data = response.get("data", {})
            
            if status == "success":
                # 系统信息
                if "system" in data:
                    print("\n📊 SYSTEM INFORMATION:")
                    print("-" * 40)
                    sys_info = data["system"]
                    for key, value in sys_info.items():
                        print(f"  {key}: {value}")
                
                # CPU信息
                if "cpu" in data:
                    print("\n💻 CPU INFORMATION:")
                    print("-" * 40)
                    cpu_info = data["cpu"]
                    for key, value in cpu_info.items():
                        print(f"  {key}: {value}")
                
                # 内存信息
                if "memory" in data:
                    print("\n🧠 MEMORY INFORMATION:")
                    print("-" * 40)
                    mem_info = data["memory"]
                    for key, value in mem_info.items():
                        print(f"  {key}: {value}")
                
                # 磁盘信息
                if "disk" in data:
                    print("\n💾 DISK INFORMATION:")
                    print("-" * 40)
                    disk_info = data["disk"]
                    for key, value in disk_info.items():
                        print(f"  {key}: {value}")
                
                # 网络信息
                if "network" in data:
                    print("\n🌐 NETWORK INFORMATION:")
                    print("-" * 40)
                    net_info = data["network"]
                    for key, value in net_info.items():
                        print(f"  {key}: {value}")
                
                # 其他硬件信息
                if "other_hardware" in data:
                    print("\n🔧 OTHER HARDWARE:")
                    print("-" * 40)
                    other_info = data["other_hardware"]
                    for key, value in other_info.items():
                        print(f"  {key}: {value}")
                
                print("\n" + "="*60)
                print(f"✅ 硬件信息获取完成，共 {len(data)} 个类别")
                
            else:
                print(f"❌ 命令执行失败: {response.get('message', 'Unknown error')}")
        else:
            print("❌ 等待响应超时，未收到硬件信息")
            
    except Exception as e:
        print(f"❌ 发送命令时出错: {e}")
    finally:
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    print("="*60)
    print("HyperNode Hardware Information Collector")
    print(f"Target Node: {NODE_ID}")
    print(f"MQTT Broker: {BROKER}:{PORT}")
    print("="*60)
    print()
    
    send_hardware_command()
'@

# 保存Python脚本并执行
$scriptPath = "$env:TEMP\get_hardware.py"
$pythonScript | Out-File -FilePath $scriptPath -Encoding UTF8

Write-Host "执行硬件信息获取脚本..." -ForegroundColor Yellow
python $scriptPath

# 清理临时文件
Remove-Item $scriptPath -Force

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "硬件信息获取完成" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan