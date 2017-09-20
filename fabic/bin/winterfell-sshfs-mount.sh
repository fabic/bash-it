#!/bin/sh
#sshfs yumedesu@winterfell.no.yumedesu.me:/home/yumedesu/sshfs-yumedesu.me \
sshfs yumenimous@winterfell:/home/yumenimous/ \
	/home/winterfell/ \
		-o reconnect,follow_symlinks,transform_symlinks,nonempty,allow_other,ro

