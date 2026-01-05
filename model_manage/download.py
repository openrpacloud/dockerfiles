import os
from tqdm import tqdm
from loguru import logger
from qcloud_cos import CosConfig
from qcloud_cos import CosS3Client


def files_under_dir(dir_path):
    all_files = []
    for root, _, files in os.walk(dir_path):
        for file in files:
            all_files.append(os.path.join(root, file))
    return all_files

# 创建目录当其不存在时
def make_dir_if_not_exists(dir_path):
    if os.path.isfile(dir_path):
        raise Exception(f"{dir_path}是一个文件，应该传入一个存在的目录路径或者不存在的目录路径")
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)
    # else:
    #     raise Exception(f"发现该dir_path存在: {dir_path}, 将会被删除")


class Txs3():
    def __init__(self, config: dict=None, config_yaml: str=None):
        """
        config、config_yaml任传一个就好，都传只生效config_yaml
        config 举例：{
            "secret_id": "xxxxx",   # 必须有
            "secret_key": "yyyyyy",     # 必须有
            "region": "ap-beijing",     # 必须有
            "token": "",                # 可以无
            "bucket_name": ""           # 可以无，当传入时upload_file等方法不传bucket参数时使用该bucketname
        }
        """
        self.secret_id = None
        self.secret_key = None
        self.bucket_name = None
        self.region = None
        self.token = None

        self.init_config(config)
        self.client = self.get_client()

    def init_config(self, config: dict):

        self.secret_id = config['secret_id']
        self.secret_key = config['secret_key']
        self.region = config['region']
        self.token = config.get('token')
        self.bucket_name = config.get('bucket_name')

    def get_client(self):
        config = CosConfig(
            Region=self.region, 
            SecretId=self.secret_id, 
            SecretKey=self.secret_key, 
            Token=self.token
        )
        client = CosS3Client(config)
        return client
    
    def url_2s3_path(self, url):
        """将URL转换拆分为bucket_name, object_name, endpoint_url
        :param url: 文件URL, 例子：
            -传入 https://s3.i.yygu.cn:58081/test-knownow/test/md/test_put_obj/doc_test.cp.mov
            -返回  test-knownow, test-knownow/test/md/test_put_obj/doc_test.cp.mov
        return: (bucket_name, object_name)

        """
        endpoint_url = '/'.join(url.split('/')[:3])
        if not url.startswith(self.endpoint_url):
            logger.warning(f"您传入的url跟配置中的endpoint_url不同，请注意！{endpoint_url}")
        path = url.replace(endpoint_url, '').lstrip('/').split('?', 1)[0]   # 去除URL域名和参数
        parts = path.split('/', 1)
        if len(parts) != 2 or not parts[1]:
            raise ValueError("URL格式不正确，无法解析为S3路径")
        bucket_name, object_name = parts
        return endpoint_url, bucket_name, object_name
    
    def upload_file(self, local_file: str, object_key: str, url: str=None, bucket_name: str=None, success_print: bool=True):
        if not bucket_name:
            bucket_name = self.buc
        self.client.upload_file(
            Bucket=bucket_name,
            LocalFilePath=local_file,
            Key=object_key,
        )
        response = self.client.head_object(Bucket=bucket_name, Key=object_key)
        local_file_size = str(os.path.getsize(local_file))
        if response['Content-Length'] != local_file_size:
            raise Exception(f"上传完成的文件大小不一致：local-{local_file_size}, txs3-{response['Content-Length']}")
        else:
            if success_print:
                logger.success("文件上传完成✅")

    def upload_directory(self, local_dir: str, object_key: str, bucket: str=None, s3_url: str=None):
        """
        文件及路径的层级对应关系：local_dir/* ---> s3_base_path
        """

        local_dir = local_dir.rstrip('/')

        # if bucket in s3_url:
        #     object_key = s3_url.split(bucket+'/')[-1]

        object_key = object_key.strip('/')

        if os.path.isfile(local_dir):
            raise Exception("本方法不接受local_dir是一个文件，请用upload_file方法")
        elif os.path.isdir(local_dir):
            files = files_under_dir(local_dir)
            if not files:
                log_msg = f"目录中没有文件: {local_dir}"
                raise Exception(log_msg)
            
            all_success_flag = True
            for file in tqdm(files):
                dst_file = file
                file_structure = dst_file.replace(local_dir, '').strip('/')
                object_name = os.path.join(object_key, file_structure)
                try:
                    self.upload_file(dst_file, bucket_name=bucket, object_key=object_name, success_print=False)
                except Exception as e:
                    logger.error(f"文件上传失败❌：{e}")
                    all_success_flag = False
            if all_success_flag:
                logger.success(f"所有文件上传完成✅。")
            else:
                logger.error(f"您有文件未上传成功，请检查日志！❌🔴❌")
        else:
            raise Exception(f"传入的local_dir: {local_dir}既不是文件也不是目录或者文件不存在，请检查")

    def download_file(self, bucket: str, object_name, local_path: str, s3_url: str=None, success_print: bool=True):
        response = self.client.get_object(
                Bucket=bucket,
                Key=object_name,
            )
        content_size = response['Content-Length']         # 
        local_file_size = str(os.path.getsize(local_path)) if os.path.exists(local_path) else 0
        if os.path.exists(local_path) and content_size == local_file_size:
            if success_print:
                logger.success(f"检查到文件在本地存在: {local_path}, 但文件大小一致")
            pass
        else:
            make_dir_if_not_exists(os.path.dirname(local_path))
            if os.path.exists(local_path):
                os.remove(local_path)
            if not self.bucket_name:
                bucket = self.bucket_name
        
            if s3_url:
                endpoint_url, bucket, object_name = self.url_2s3_path(s3_url)
            response['Body'].get_stream_to_file(local_path)
            local_file_size = str(os.path.getsize(local_path)) if os.path.exists(local_path) else 0
            if str(content_size) == str(local_file_size):
                if success_print:
                    logger.success("文件下载完成✅")
            else:
                raise Exception(f"下载完成的文件大小不一致：local-{local_file_size}, txs3-{content_size}")

    def download_directory(self, s3_url, download_dir, bucket_name: str=None):
        """
        下载后的路径对应：s3_url/*  --->.  download_dir/*
        download_dir下面所有文件的路径同s3_url下的层级结构一致。
        """
        if not bucket_name:
            bucket_name=self.bucket

        s3_url = s3_url.rstrip('/')
        download_dir = download_dir.rstrip('/')
        bucket_name = bucket_name.strip('/')

        # object_key_prefix = s3_url.replace(self.endpoint_url + '/' + bucket_name + '/', '')
        object_key_prefix = s3_url

        response = self.client.list_objects(
            Bucket=bucket_name,
            Prefix=object_key_prefix,
        )

        all_files_download_flag = True

        count = 1
        total = len(response.get('Contents', []))
        for content in tqdm(response.get('Contents', [])):
            download_path = os.path.join(download_dir, content['Key'].replace(object_key_prefix + '/', ''))
            key = content['Key']
            try:
                self.download_file(bucket=bucket_name, object_name=key, local_path=download_path, success_print=False)
                logger.info(f"下载进度: {count}/{total}")
                count += 1
            except Exception as e:
                logger.error(f"文件下载失败：{e}")
                all_files_download_flag = False
        if all_files_download_flag:
            logger.success("目录下载执行完成✅.")
        else:
            logger.error(f"您有文件未上传成功，请检查日志！❌🔴❌")

    def test_bucket_connection(self, bucket_name: str=None):
        if not bucket_name:
            bucket_name = self.bucket_name
        resp = self.client.head_bucket(Bucket=bucket_name)
        logger.info(resp)
        return True


def main():
    model_name = os.getenv("MODEL_NAME", default="baichuan/t5-base")
    custom_path = os.getenv("MODEL_SAVE_PATH", default=".")
    secret_id = os.getenv("SECRET_ID", default=".")
    secret_key = os.getenv("SECRET_KEY", default=".")

    bucket_name = "models-hub-1369730192"
    config = {
        "secret_id": secret_id,   # 必须有
        "secret_key": secret_key,     # 必须有
        "region": "ap-beijing",     # 必须有
        "token": "",                # 可以无
        "bucket_name": bucket_name
    }
    s3 = Txs3(config=config)
    s3.download_directory(s3_url=model_name, download_dir=custom_path, bucket_name=bucket_name)
    print(f"模型路径: {custom_path}")

if __name__ == '__main__':
    main()
