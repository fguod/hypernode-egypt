#!/usr/bin/env python3
"""
HyperNode Optimized - Customized for User-2025ZPVXAR
Windows 11 Pro, Intel i7-14700, 16GB RAM, Python 3.14.3
"""

import sys
import os
import platform
import json
import time
import uuid
import subprocess
import threading
from datetime import datetime

# ==================== SYSTEM INFO ====================
SYSTEM_INFO = {
    "device_name": "User-2025ZPVXAR",
    "processor": "Intel(R) Core(TM) i7-14700 2.10 GHz",
    "ram_gb": 16.0,
    "os": "Windows 11 Pro 24H2",
    "python_version": "3.14.3",
    "optimized": True
}

# ==================== CONFIGURATION ====================
class Config:
    VERSION = "1.0.0-optimized"
    
    # Use your device name in node ID
    NODE_ID_PREFIX = SYSTEM_INFO["device_name"].replace("-", "")[:8].upper()
    INSTALL_DIR = os.path.expanduser("~/.hypernode_optimized")
    
    # MQTT - using public broker
    MQTT_BROKER = "broker.emqx.io"
    MQTT_PORT = 1883
    
    # Topics
    TOPIC_TO_ASSISTANT = "hypernode/optimized/to/assistant"
    TOPIC_FROM_ASSISTANT = "hypernode/assistant/to/{node_id}"
    
    # Allowed commands
    ALLOWED_COMMANDS = ["ping", "info", "system", "execute", "upgrade"]

# ==================== OPTIMIZED FUNCTIONS ====================
def get_detailed_system_info():
    """Get detailed system information for your specific hardware"""
    info = {
        "basic": SYSTEM_INFO.copy(),
        "detailed": {
            "platform": platform.platform(),
            "architecture": platform.architecture(),
            "machine": platform.machine(),
            "processor": platform.processor(),
            "hostname": platform.node(),
            "python_implementation": platform.python_implementation(),
            "python_version": platform.python_version(),
            "timestamp": datetime.now().isoformat()
        }
    }
    
    # Try to get more details with psutil
    try:
        import psutil
        
        # CPU details
        cpu_info = {
            "physical_cores": psutil.cpu_count(logical=False),
            "logical_cores": psutil.cpu_count(logical=True),
            "cpu_percent": psutil.cpu_percent(interval=1),
            "cpu_freq": psutil.cpu_freq()._asdict() if psutil.cpu_freq() else None
        }
        info["detailed"]["cpu"] = cpu_info
        
        # Memory details
        memory = psutil.virtual_memory()
        info["detailed"]["memory"] = {
            "total_gb": round(memory.total / (1024**3), 2),
            "available_gb": round(memory.available / (1024**3), 2),
            "used_gb": round(memory.used / (1024**3), 2),
            "percent": memory.percent
        }
        
        # Disk details
        disk_info = {}
        for partition in psutil.disk_partitions():
            try:
                usage = psutil.disk_usage(partition.mountpoint)
                disk_info[partition.mountpoint] = {
                    "device": partition.device,
                    "total_gb": round(usage.total / (1024**3), 2),
                    "used_gb": round(usage.used / (1024**3), 2),
                    "free_gb": round(usage.free / (1024**3), 2),
                    "percent": usage.percent
                }
            except:
                continue
        info["detailed"]["disk"] = disk_info
        
    except ImportError:
        info["detailed"]["psutil"] = "not_installed"
    
    return info

def execute_command_safely(command, args=None, timeout=30):
    """Execute command with safety checks"""
    if args is None:
        args = []
    
    # Safety: only allow specific commands
    SAFE_COMMANDS = [
        "echo", "dir", "python", "powershell", "cmd",
        "whoami", "hostname", "systeminfo", "tasklist",
        "netstat", "ipconfig", "ping", "tracert"
    ]
    
    cmd_base = command.split()[0].lower() if command else ""
    if cmd_base not in SAFE_COMMANDS:
        return {
            "status": "error",
            "message": f"Command not allowed: {command}",
            "allowed_commands": SAFE_COMMANDS
        }
    
    try:
        result = subprocess.run(
            [command] + args,
            capture_output=True,
            text=True,
            timeout=timeout,
            shell=True,
            encoding='utf-8',
            errors='ignore'
        )
        
        return {
            "status": "success",
            "command": command,
            "returncode": result.returncode,
            "stdout": result.stdout[:2000],  # Limit output
            "stderr": result.stderr[:1000],
            "execution_time": datetime.now().isoformat()
        }
        
    except subprocess.TimeoutExpired:
        return {"status": "error", "message": f"Command timeout after {timeout} seconds"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

# ==================== OPTIMIZED NODE ====================
class OptimizedNode:
    """Optimized node for your specific hardware"""
    
    def __init__(self):
        # Generate unique node ID based on your device
        self.node_id = f"{Config.NODE_ID_PREFIX}-{str(uuid.uuid4())[:8].upper()}"
        self.client = None
        self.connected = False
        
        # Create optimized directory
        os.makedirs(Config.INSTALL_DIR, exist_ok=True)
        os.makedirs(os.path.join(Config.INSTALL_DIR, "logs"), exist_ok=True)
        
        print(f"🔧 Optimized for: {SYSTEM_INFO['device_name']}")
        print(f"💻 Processor: {SYSTEM_INFO['processor']}")
        print(f"🧠 Memory: {SYSTEM_INFO['ram_gb']} GB")
        print(f"🐍 Python: {SYSTEM_INFO['python_version']}")
    
    def start(self):
        """Start the optimized node"""
        print("=" * 70)
        print(f"🚀 HYPERNODE OPTIMIZED v{Config.VERSION}")
        print("=" * 70)
        print(f"🎯 Customized for your Windows 11 Pro system")
        print(f"📊 Hardware: Intel i7-14700 | 16GB RAM")
        print(f"🔗 Node ID: {self.node_id}")
        print(f"📁 Directory: {Config.INSTALL_DIR}")
        print(f"🌐 MQTT: {Config.MQTT_BROKER}:{Config.MQTT_PORT}")
        print("=" * 70)
        
        # Check dependencies
        try:
            import paho.mqtt.client as mqtt
        except ImportError:
            print("❌ Missing dependency: paho-mqtt")
            print("💡 Installing automatically...")
            self._install_dependency("paho-mqtt")
            try:
                import paho.mqtt.client as mqtt
            except:
                print("❌ Failed to install paho-mqtt")
                print("💡 Please run: pip install paho-mqtt")
                return
        
        # Create MQTT client
        self.client = mqtt.Client(client_id=self.node_id)
        self.client.on_connect = self._on_connect
        self.client.on_message = self._on_message
        
        try:
            print("\n🔗 Connecting to MQTT broker...")
            self.client.connect(Config.MQTT_BROKER, Config.MQTT_PORT, 60)
            
            # Start heartbeat
            threading.Thread(target=self._heartbeat, daemon=True).start()
            
            print("\n✅ OPTIMIZED NODE READY")
            print("💡 Waiting for commands from AI Assistant")
            print("🛑 Press Ctrl+C to stop")
            print("=" * 70)
            
            self.client.loop_forever()
            
        except KeyboardInterrupt:
            print("\n\n🛑 Received stop signal")
        except Exception as e:
            print(f"\n❌ Connection error: {e}")
        finally:
            if self.client:
                self.client.disconnect()
            print("👋 Optimized node stopped")
    
    def _install_dependency(self, package):
        """Install Python dependency"""
        try:
            subprocess.run(
                [sys.executable, "-m", "pip", "install", package, "--quiet"],
                check=True,
                capture_output=True
            )
            print(f"✅ Installed: {package}")
            return True
        except:
            print(f"❌ Failed to install: {package}")
            return False
    
    def _on_connect(self, client, userdata, flags, rc):
        """MQTT connection established"""
        if rc == 0:
            print(f"✅ Connected to MQTT broker")
            self.connected = True
            
            # Subscribe to commands
            topic = Config.TOPIC_FROM_ASSISTANT.format(node_id=self.node_id)
            client.subscribe(topic)
            print(f"📡 Subscribed to: {topic}")
            
            # Send optimized online notification
            self._send_optimized_online()
        else:
            print(f"❌ Connection failed with code: {rc}")
    
    def _on_message(self, client, userdata, msg):
        """Process incoming message"""
        try:
            data = json.loads(msg.payload.decode('utf-8'))
            msg_type = data.get("type", "")
            
            if msg_type == "command":
                self._handle_command(data)
                
        except json.JSONDecodeError:
            print(f"⚠️ Invalid JSON in message")
        except Exception as e:
            print(f"⚠️ Message error: {e}")
    
    def _handle_command(self, data):
        """Handle command from AI assistant"""
        cmd_data = data.get("data", {})
        command = cmd_data.get("command", "").lower()
        command_data = cmd_data.get("data", {})
        
        print(f"\n📨 Received command: {command}")
        
        response = None
        
        if command == "ping":
            response = {
                "status": "success",
                "message": "pong",
                "node_id": self.node_id,
                "timestamp": datetime.now().isoformat(),
                "system": SYSTEM_INFO["device_name"]
            }
            
        elif command == "info":
            response = {
                "status": "success",
                "node_id": self.node_id,
                "system_info": SYSTEM_INFO,
                "optimized": True,
                "timestamp": datetime.now().isoformat()
            }
            
        elif command == "system":
            info = get_detailed_system_info()
            response = {
                "status": "success",
                "node_id": self.node_id,
                "detailed_info": info,
                "collection_time": datetime.now().isoformat()
            }
            
        elif command == "execute":
            cmd = command_data.get("command", "")
            args = command_data.get("args", [])
            response = execute_command_safely(cmd, args)
            response["node_id"] = self.node_id
            
        elif command == "upgrade":
            response = {
                "status": "info",
                "message": "Auto-upgrade system ready",
                "node_id": self.node_id,
                "version": Config.VERSION,
                "upgrade_url": "https://github.com/fguod/hypernode-global"
            }
            
        else:
            response = {
                "status": "error",
                "message": f"Unknown command: {command}",
                "node_id": self.node_id,
                "allowed_commands": Config.ALLOWED_COMMANDS
            }
        
        # Send response
        if response:
            self._send_response(command, response)
    
    def _send_optimized_online(self):
        """Send optimized online notification"""
        msg = {
            "from": self.node_id,
            "type": "node_online_optimized",
            "timestamp": datetime.now().isoformat(),
            "data": {
                "version": Config.VERSION,
                "system": SYSTEM_INFO,
                "optimized": True,
                "message": f"Optimized node for {SYSTEM_INFO['device_name']} is online!",
                "hardware": {
                    "processor": SYSTEM_INFO["processor"],
                    "ram_gb": SYSTEM_INFO["ram_gb"],
                    "os": SYSTEM_INFO["os"]
                }
            }
        }
        
        self.client.publish(
            Config.TOPIC_TO_ASSISTANT,
            json.dumps(msg, ensure_ascii=False),
            qos=1
        )
        
        print("📢 Optimized online notification sent")
    
    def _send_response(self, command, response):
        """Send command response"""
        msg = {
            "from": self.node_id,
            "type": "command_response",
            "timestamp": datetime.now().isoformat(),
            "data": {
                "command": command,
                "response": response
            }
        }
        
        self.client.publish(
            Config.TOPIC_TO_ASSISTANT,
            json.dumps(msg, ensure_ascii=False),
            qos=1
        )
        
        print(f"📤 Response sent for: {command}")
    
    def _heartbeat(self):
        """Send periodic heartbeat"""
        while True:
            time.sleep(30)  # Every 30 seconds
            if self.connected and self.client:
                try:
                    import psutil
                    cpu_percent = psutil.cpu_percent(interval=1)
                    memory = psutil.virtual_memory()
                    
                    heartbeat = {
                        "from": self.node_id,
                        "type": "heartbeat_optimized",
                        "timestamp": datetime.now().isoformat(),
                        "data": {
                            "status": "alive",
                            "cpu_percent": cpu_percent,
                            "memory_percent": memory.percent,
                            "memory_available_gb": round(memory.available / (1024**3), 2)
                        }
                    }
                    
                    self.client.publish(
                        Config.TOPIC_TO_ASSISTANT,
                        json.dumps(heartbeat, ensure_ascii=False),
                        qos=0
                    )
                    
                except:
                    # Simple heartbeat if psutil not available
                    heartbeat = {
                        "from": self.node_id,
                        "type": "heartbeat",
                        "timestamp": datetime.now().isoformat(),
                        "data": {"status": "alive"}
                    }
                    
                    self.client.publish(
                        Config.TOPIC_TO_ASSISTANT,
                        json.dumps(heartbeat, ensure_ascii=False),
                        qos=0
                    )

# ==================== MAIN ====================
def main():
    """Main entry point"""
    print("🔍 Detecting system configuration...")
    print(f"📋 System: {platform.system()} {platform.release()}")
    print(f"🐍 Python: {platform.python_version()}")
    
    # Check if running on correct system
    if platform.system() != "Windows":
        print("⚠️  This optimized version is designed for Windows systems")
        print("💡 You can still run it, but some features may not work optimally")
    
    # Start optimized node
    node = OptimizedNode()
    node.start()

if __name__ == "__main__":
    main()