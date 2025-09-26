from modelscope import snapshot_download
import os
# 指定模型
model_name = os.getenv("MODEL_NAME", default="baichuan/t5-base")
custom_path = os.getenv("MODEL_SAVE_PATH", default=".")
revision = os.getenv("MODEL_REVISION", default=None)
# model_dir = snapshot_download(model_name,cache_dir=custom_path)
# print(f"model download to {model_dir}")

try:
    model_dir = snapshot_download(model_name,
                                  cache_dir=custom_path,
                                  revision=revision,
                                  local_files_only=True)
except Exception:
    print("本地没有缓存，开始下载...")
    model_dir = snapshot_download(model_name, revision=revision, cache_dir=custom_path)

print(f"模型路径: {model_dir}")
