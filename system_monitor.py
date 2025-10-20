import psutil
import json
import time
from datetime import datetime

def get_system_metrics():
    """
    Gathers system metrics such as CPU usage, memory consumption, and disk space.
    """
    cpu_usage = psutil.cpu_percent(interval=1)
    memory_info = psutil.virtual_memory()
    disk_info = psutil.disk_usage('/')

    metrics = {
        "timestamp": datetime.now().isoformat(),
        "cpu_usage": cpu_usage,
        "memory": {
            "total": memory_info.total,
            "available": memory_info.available,
            "percent": memory_info.percent,
            "used": memory_info.used,
        },
        "disk": {
            "total": disk_info.total,
            "used": disk_info.used,
            "free": disk_info.free,
            "percent": disk_info.percent,
        },
    }
    return metrics

def main():
    """
    Main function to run the monitoring loop.
    """
    while True:
        metrics = get_system_metrics()
        with open("system_metrics.json", "w") as f:
            json.dump(metrics, f)
        time.sleep(5)

if __name__ == "__main__":
    main()
