# gitlab-kubernetes
1. сертификат домена не нужен гитлабу и реестру?

## Порядок подготовки и установки

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

5. Создаем ключь и сертификат для связи гитлаба с реестром, в таком формате опция gitlab_rails['internal_key'] его хавает

    ```BASH
    openssl req -new -newkey rsa:4096 -subj "/CN=gitlab-issuer" -nodes -x509 -keyout ./registry/certs/auth.key -out ./registry/certs/auth.crt
    ```

6. Запускаем Гитлаб

    ```BASH
    make gitlab-up
    ```
