from modelscope import snapshot_download
import os
# 指定模型
model_name = os.getenv("MODEL_NAME", default="baichuan/t5-base")
custom_path = os.getenv("MODEL_SAVE_PATH", default=".")
model_dir = snapshot_download(model_name,cache_dir=custom_path)
print(f"model download to {model_dir}")
