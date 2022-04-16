# gitlab-kubernetes

## Порядок подготовки настройки и установки

1. 

    ```BASH
 
    ```

2. Создаем область имен

    ```BASH
    sudo kubectl apply -f ./base/namespace.yml
    ```

3. Выпускаем сертификат

    ```BASH
    sudo kubectl apply -f ./base/cert.self.yml
    ```

4. Создаем аккаунт админа кластера

    ```BASH
    sudo kubectl apply -f ./base/gitlab-admin-service-account.yaml
    ```

5. Создаем ключь и сертификат для связи гитлаба с реестром, gitlab_rails['internal_key'] его хавает - хавает но НЕ работает.
   Работает конструкция вида registry['internal_key'] = File.read("/reg-auth-cert/auth.key")

    ```BASH
    openssl req -new -newkey rsa:4096 -subj "/CN=gitlab-issuer" -nodes -x509 -keyout ./registry/certs/reg-auth.key -out ./registry/certs/reg-auth.crt
    sudo kubectl apply -k ./registry/certs
    ```

    по идее можно использовать и домена ключь-сертификат

6. Настройка
    1. gitlab/omnibus-conf.yml
       external_url - внешний адрес гитлаба
       registry_external_url - внешний адрес registry
       db_username - имя пользователя DB
       db_password - пароль пользователя DB
       db_database - имя базы данных
       initial_shared_runners_registration_token - токен для раннеров
       initial_root_password - пароль пользователя root
    2. gitlab/pv.yml
       в nodeAffinity - values - прописываем имя ноды где будет крутится гитлаб
       local - path - путь для монтирования gitlab_data
       persistentVolumeReclaimPolicy: Retain - файлы будут сохранены после удаления PV, Delete - удалены
    3. gitlab/ingress.yml
       настраиваем адреса
    4. postgres/deployment.yaml
       настраиваем POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB

99. Запускаем Гитлаб

    ```BASH
    make gitlab-up
    ```

mountpoint
└── gitlab-data
    ├── builds
    ├── git-data
    ├── shared
    └── uploads

---
  mountOptions:
    - hard
    - timeo=600
    - retrans=3
    - proto=tcp
    - nfsvers=4.2
    - port=2050
    - rsize=4096
    - wsize=4096
    - noacl
    - nocto
    - noatime
    - nodiratime

sudo vi /etc/exports
sudo exportfs -arv

SELinux
chcon -Rt svirt_sandbox_file_t /path/to/volume

```bash
docker login reg.dev-srv.home.lan -u root -p MJw7xHGBg4uxVB9sK7j6
```

### Добавляем самоподписанный сертификат в клиентскую систему

```bash
sudo kubectl -n gitlab get secret root-secret -o json | jq -r '.data["tls.crt"]' | base64 -d > ca.crt
sudo mkdir -p /etc/docker/certs.d/reg.dev-srv.home.lan
sudo cp ca.crt /etc/docker/certs.d/reg.dev-srv.home.lan/ca.crt
sudo cp ca.crt /usr/local/share/ca-certificates/ca.crt
sudo update-ca-certificates
```
docker push reg.dev-srv.home.lan/root/kaniko-project
docker build -t reg.dev-srv.home.lan/root/kaniko-project .
[Service]
Environment="HTTP_PROXY=http://136.144.54.195:10010"
Environment="HTTPS_PROXY=http://50.205.73.210:3128"
Environment="NO_PROXY=localhost,127.0.0.1,.lan"

---

# Registry caps
     cap_add:
       - CHOWN
       - SETGID
       - SETUID
---

{
        "auths": {
                "https://index.docker.io/v1/": {
                        "auth": "c2xheWVydXM6ODJEY1FyRFNKUHdMNEJjcnJwUWh2YW4="
                }
        },
        "proxies": {
            "default":
            {
            "httpProxy": "http://reg.dev-srv.home.lan/",
            "httpsProxy": "http://reg.dev-srv.home.lan/"
            }
        }
}

---

https://github.com/RodrigoRosmaninho/projects-ect/tree/master/4th%20Year/%5BGIRS%5D%20Proj%20-%20Kubernetes%20Deployment%20of%20an%20HA%20Gitlab%20instance
https://github.com/llharris/lab-200a/blob/b7149943df2167e6064ee3af8819eb4e49f6f4a5/docker/gitlab/gitlab-ee-compose.yml
https://github.com/dhtech/kube-sto2/blob/59f759f578dab888089d973a26aa58204e6b9551/gitlab/gitlab-config.yml
https://github.com/asuc-octo/berkeleytime/blob/3da3ec56bb0ae627fb1f7f4ad511bc80a01546c9/infra/k8s/default/bt-gitlab.yaml
https://github.com/danmanners/RKE-Learning-2/blob/0b8a020a104f1e6c104fb6ad4d5a9fa8a8d351d8/Gitlab/ingress.yaml
https://github.com/RihardsT/cloud_project_kubernetes/blob/421cb19276f225707567db9a7573f87dd7268d99/Gitlab/gitlab.yml



    # registry['internal_key'] = "-----BEGIN PRIVATE KEY-----\nMIIJQwIBADPg2Crk=\n-----END PRIVATE KEY-----\n"
    registry['internal_key'] = File.read("/reg-auth-cert/auth.key")
    gitlab_rails['registry_host'] = "reg.dev-srv.home.lan"
    # gitlab_rails['registry_port'] = "5005"
    # Notification secret, it's used to authenticate notification requests to GitLab application
    # You only need to change this when you use external Registry service, otherwise
    # it will be taken directly from notification settings of your Registry
    # gitlab_rails['registry_notification_secret'] = nil
    # Нужен ключь в правильном формате
    # gitlab_rails['internal_key'] = "/reg-auth-cert/auth.key"


curl --silent --user root:secret_pass -G https://gitlab.dev-srv.home.lan/jwt/auth -d service=container_registry -d scope="gitlab-instance-e4525a73:*:*" | ./jq -r '.token')
Command 2: curl -H "Authorization: Bearer ${TOKEN}" ${REGISTRY}v2/group/module/tags/list
Command 3: curl -H "Authorization: Bearer ${TOKEN}" -X "DELETE" {$REGISTRY}v2/group/module/blobs/sha256:xxx

reg.dev-srv.home.lan
curl --user 'root:secret_pass' 'https://gitlab.dev-srv.home.lan/jwt/auth?client_id=docker&offline_token=true&service=container_registry&scope=repository:gitlab-instance-e4525a73:push,pull'

curl --user 'root:secret_pass' 'http://gitlab-svc/jwt/auth?client_id=docker&offline_token=true&service=container_registry&scope=repository:gitlab-instance-e4525a73:push,pull'

curl -vvv -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' -H 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkJHM0w6VUdLTDpONUNWOklINkU6MlBaUTpSUE82OlBMQ0I6TDdYRTpFN0lFOlZGS1M6WkdEMzpPRUxNIiwidHlwIjoiSldUIn0.eyJhY2Nlc3MiOltdLCJqdGkiOiJiODYxNjlhYS01NGM4LTQ2NjEtYWM5NS1hZTRiMDY3YzNiZDAiLCJhdWQiOiJjb250YWluZXJfcmVnaXN0cnkiLCJzdWIiOiJyb290IiwiaXNzIjoiZ2l0bGFiLWlzc3VlciIsImlhdCI6MTY1MDEyMDAxMywibmJmIjoxNjUwMTIwMDA4LCJleHAiOjE2NTAxMjAzMTN9.kWr5USopVKgs8Q1dASBw4lsFaA-X9QUkF9e_RWP6o9bm1rHKUS3zrLDafnCgeiTQho-2DHocAAAydR4mHl8HxR6glPh1iFeVaGXlOeiQhSJcdxj3cJTXkKQynjHCHq7k0AQKtlZRXkI4Z0qWlX5SXAVg1nPiElvm088tDb47SUFig_0bEdmzGKrJ1IOf_HhFRYhcszOD8v77-cblymjCbuAMeXHvHxWMXbgRQvDrAPThKZsvwxyAMjAWCPFokifST54ubfDbJJMyYYONHvbBP5lN061-EPbFLwWyhRwvwMuAHlUhc5vn6vfpXsDrbTZkeQ-nEIL7QsMYFOwZeNaBR8CgzoDOVRs1hiVdy0I_mv47xzw8gbbgdFwuY7w4WXaaAdzvPVxWX3aHzY1hvQMtVf-YEb9Rcgm4Zw3_5N7dd2s6PENAKb4pcr98GPjXzYVQ1Ei4ULzYqhMms1wRtn5G8kOTTzJzrRIHAQTuJB22D3a7bLWh442xXsoK8rlmmwjawVrQEqmawHE6HYk3yzjeob2f5Pb6P8JCAMLJTcLwE2Y7_RWPn2bUR4AIb6bEpU1NDKf8fttkBHAe4y_T-riHHBlyRCfZvQaSXZEsvw47g-DkWig2yeTmpFuRjqRH6a44Shx30slCBrjY79ci9IOBqjCFFhCjoigK894C1lHlpxo' https://gitlab.dev-srv.home.lan/v2/kaniko-project/tags/list