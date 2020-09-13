# Gitlab-CICD-on-AWS-Fargate

- [情境說明](#情境說明)
- [檔案說明](#檔案說明)

### 情境說明
- 使用Gitlab on EC2來進行CICD on AWS Fargate
1. 撰寫Dockerfile、PHP Code(return http 4xx error)
2. Commit Code
3. Docker Build
4. 檢查http狀態200 pass 4xx fail
5. 修改成正確的PHP Code
6. Commit Code
7. Docker Build
8. Test(Pass)
9. 核准後進行Deploy

### 檔案說明

- 請把 gitlab-ci.yml 更名為 .gitlab-ci.yml
- 建立 ECR
- 建立 ECS 環境設定
  - 建立ECS Cluster for Fargate
  - 建立Task Definitions
 - 填寫 fargate-task.json
 - 修改 .gitlab-ci.yml

### 安裝Gitlab
- IAM role
```bash
AmazonEC2ContainerRegistryFullAccess
AmazonEC2ContainerServiceFullAccess
AmazonECS_FullAccess
```
1. Install Docker Engine
```bash
sudo curl -sSL https://get.docker.com/ | sh
```
2. Set up the volumes location
- Before setting everything else, configure a new environment variable $GITLAB_HOME pointing to the directory where the configuration, logs, and data files will reside. Ensure that the directory exists and appropriate permission have been granted.
```bash
export GITLAB_HOME=/srv/gitlab
```
3. Install GitLab using Docker Engine
```bash
sudo docker run --detach \
  --hostname gitlab.test.com \
  --publish 443:443 --publish 80:80  \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  gitlab/gitlab-ee:latest
```
- The initialization process may take a long time. You can track this process with:
```bash
sudo docker logs -f gitlab
```

### 自動申請免費憑證 Let's Encrypt
- 進入container設定
```bash
docker container ls
docker exec -it <container id> bash
```
- Change Gitlab Domain
```bash
sudo vi /etc/gitlab/gitlab.rb

external_url 'https://gitlab.test.com'
letsencrypt['enable'] = true
letsencrypt['contact_emails'] = ['test@test.com']

sudo gitlab-ctl reconfigure
#Make sure the cli end without error
```

### 將預設GitLab Notification Emails改為SES
- 進入設定
```bash
docker exec -it gitlab bash
sudo vi /etc/gitlab/gitlab.rb

gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "email-smtp.region-1.amazonaws.com"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "Smtp Username"
gitlab_rails['smtp_password'] = "Smtp Password"
gitlab_rails['smtp_domain'] = "yourdomain.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true

gitlab-ctl reconfigure
```
- 測試
```bash
gitlab-rails console
Notify.test_email('test@test.com', 'gitlab test', 'gitlab test').deliver_now
```
### Install GitLab Runner
1. 先安裝docker
```bash
curl -sSL https://get.docker.com/ | sh
```
2. Use Docker volumes to start the Runner container
```bash
docker volume create gitlab-runner-config
```
3. Start the Runner container using the volume we just created:
```bash
docker run -d --name gitlab-runner --restart always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v gitlab-runner-config:/etc/gitlab-runner \
    gitlab/gitlab-runner:latest
```
4. Register the Runner
- Use Docker-in-Docker with privileged mode
```bash
docker run --rm -it -v gitlab-runner-config:/etc/gitlab-runner gitlab/gitlab-runner:latest register

sudo docker exec -it gitlab-runner bash
###################################
vi /etc/gitlab-runner/config.toml
 [runners.docker]
    privileged = false > 改true
###################################
gitlab-runner restart
exit
docker run --rm -it -v gitlab-runner-config:/etc/gitlab-runner gitlab/gitlab-runner:latest status
```
