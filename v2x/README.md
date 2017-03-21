### Docker + Elasticsearch.v2x

研究 elasticsearch 集群部署。

考虑将配置文件 `elasticsearch.yml` 挂载到主机目录下，这样可以随意更改cluster节点的配置。

volume 目录：

```
/app
	config -- 自定义 es 配置文件及log配置文件
	data -- 数据目录
	logs -- 日志目录
```

当需要组成集群模式时，`unicast.hosts` 参数可设置成宿主机的IP。

