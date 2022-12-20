# gcp-terraform-datastream-cloudsql

https://cloud.google.com/datastream/docs/private-connectivity

install config para proxy
```shell
sudo apt install wget
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
chmod +x cloud_sql_proxy
```
copy key.json to vm path

run cloud_sql_proxy
```shell
 ./cloud_sql_proxy -instances=-staging:west1:-staging-0ada6cc6=tcp:0.0.0.0:5432 -credential_file=./iam-acount-cloudsqlproxy.json -ip_address_types=PRIVATE &

 ```


