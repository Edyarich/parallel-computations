from hdfs import Config
import math
import sys


hdfs_file = sys.argv[1]
client = Config().get_client()
file_status = client.status(hdfs_file)

blocks_count = math.ceil(file_status['length'] / file_status['blockSize'])
print(blocks_count)
