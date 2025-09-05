# git相关

<!-- - [1. git相关](#1-git相关)
  - [1.1. git安装](#11-git安装)
    - [1.1.1. windows安装git](#111-windows安装git)
    - [1.1.2. linux 安装git](#112-linux-安装git)
  - [1.2. git 使用](#12-git-使用)
    - [1.2.1. git 版本管理](#121-git-版本管理) -->
- [1. git安装](#1-git安装)
  - [1.1. windows安装git](#11-windows安装git)
  - [1.2. linux 安装git](#12-linux-安装git)
- [2. git 使用](#2-git-使用)
  - [2.1. git 版本管理](#21-git-版本管理)
- [3. Test](#3-test)
  - [3.1. haha](#31-haha)



## 1. git安装

### 1.1. windows安装git

> ps: Windows上面一定要装一个git，超级方便，而且Windows自带的cmd和powershell超级难用，
> 装上git后直接使用体验升级，各种好用的工具（md5，命令补全，命令行终端快捷键，自动source
>  python虚拟环境,自动切到并显示工作分支等）

>下载链接：[https://git-scm.com/downloads](https://git-scm.com/downloads)

```
    选择windows，然后根据自己的需求和机器的架构选择相应的下载链接，安装就是下一步，很简
    单，记得勾选 *将环境变量添加到系统PATH* 以及 *添加到文件管理上下文* ,不然后面可能会
    找不到gitbash，鼠标右键可能也找不到gitbash
```

```bash
#正常安装后vscode中新建bash终端显示就是这个样子
Administrator@MAY MINGW64 /d/my/Yaominan.github.io/blog (test)
$ source D:/my/Yaominan.github.io/.blog_env/Scripts/activate
(.blog_env) 
Administrator@MAY MINGW64 /d/my/Yaominan.github.io/blog (test)
$ 
```



### 1.2. linux 安装git



## 2. git 使用

### 2.1. git 版本管理

- 仓库克隆 - git clone

```bash
$ git clone git@github.com:Yaominan/blog.git
Administrator@MAY MINGW64 /d/my/Yaominan.github.io/blog (main)
# 仓库克隆成功后用branch查看一般显示是在main分支
$ git branch 
  cicd
* main
  test
(.blog_env) 
```

- 内容暂存 - git add .
- 内容提交 - git commit -m '描述更新信息'
- 分支推送 - git push
```bash
#第一次推送之前会提示没有配置用户名和邮箱，需要配置一下用户名和邮箱
git config user.name kris
git config user.email haha@example.com

git add .
git commit -m 'Test git push'
#绑定远程仓库，这样以后就不用每次都输入仓库名了
git push --set-upstream remote-repo main 
#绑定远程仓库后，后面的推送直接push就行，或者推送指定分支 (git push test)
git push
```

- 更新远程仓库的更新到本地 - git fetch、git pull
- 冲突时本地文件暂存 - git stash
```bash
#拉取远程仓库的更新,fetch只拉取，不合并内容，可以通过checkout切换fetch的分支
git fetch
git checkout test1
# pull操作是将远程指定的分支合并到本地分支，默认是main，pull操作是先fetch然后再merge
git pull
git pull test1
# pull时有冲突的话需要手动解决冲突
```

## 3. Test

### 3.1. haha