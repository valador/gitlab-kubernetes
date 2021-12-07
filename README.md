# gitlab-kubernetes

## Порядок подготовки настройки и установки

1. Установка менеджера сертификатов cert-manager

    ```BASH
    sudo kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml
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

5. Создаем ключь и сертификат для связи гитлаба с реестром, gitlab_rails['internal_key'] его хавает

    ```BASH
    openssl req -new -newkey rsa:4096 -subj "/CN=gitlab-issuer" -nodes -x509 -keyout ./registry/certs/auth.key -out ./registry/certs/auth.crt
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
