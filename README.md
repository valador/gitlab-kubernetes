# gitlab-kubernetes
1. сертификат домена не нужен гитлабу и реестру?

## Ключь для аутентификации реестра, в таком формате опция gitlab_rails['internal_key'] его хавает

```
openssl req -new -newkey rsa:4096 -subj "/CN=gitlab-issuer" -nodes -x509 -keyout auth.key -out auth.crt
```
