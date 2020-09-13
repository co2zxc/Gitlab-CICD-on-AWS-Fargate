# Gitlab-CICD-on-AWS-Fargate

###使用Gitlab on EC2來進行CICD on AWS Fargate

1. 撰寫Dockerfile、PHP Code(return http 4xx error)
2. Commit Code
3. Docker Build
4. 檢查http狀態200 pass 4xx fail
5. 修改成正確的PHP Code
6. Commit Code
7. Docker Build
8. Test(Pass)
9. 核准後進行Deploy

###安裝Gitlab
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


