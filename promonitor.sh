#!/bin/bash

function err_echo(){
echo -e "\e[91m[Error]: $* \e[0m"
exit 1
}
function info_echo(){
echo -e "\e[92m[Info]: $* \e[0m"

}
function warn_echo(){
echo -e "\e[93m[Warning]: $* \e[0m"

}
function check_exit(){
if [ $? -ne 0]; then
err_echo "异常码：$1"
exit 1
fi
}

#应用一


function sobet(){
     PROT=8080
     HOST_IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
     APPNAME=sobet
     APPDIR=/root/sobet
     Checkproess=`ps -ef|grep $APPNAME|grep -v grep|wc -l`
     CheckStatus=`curl -I -m 10 -o /dev/null -s -w %{http_code}"\n"  $HOST_IP:$PROT/$APPNAME`
    if [ $Checkproess == 0 ]
    then
	warn_echo "不好！$APPNAME应用挂掉了，不过不用担心我会帮你启动起来 "
	source /etc/profile
	/bin/sh 		$APPDIR/bin/startup.sh  >> /dev/null
	info_echo "=========================正在启动${APPNAME}应用=====================" 	
	sleep 10
	info_echo "正在检测进程启动状态"
		if [ "$CheckStatus" == "000" ]
		then
			warn_echo "$APPNAME应用还未启动完成 HTTP状态码为：$CheckStatus！请等待.........."
			while true
			do
			CheckStatus=`curl -I -m 10 -o /dev/null -s -w %{http_code}"\n"  $HOST_IP:$PROT/$APPNAME`  #重新获取$CheckStatus的值，不然会造成死循环
				case $CheckStatus in 
					000) info_echo "正在启动中"
					;;
					*) info_echo "启动完成"
					break
					;;
				esac
			done
		
				
		elif [ $CheckStatus -lt 400 ]
		then
			info_echo "$APPNAME应用启动状态正常"

		else
			warn_echo "$APPNAME应用进程启动失败 HTTP状态码为：$CheckStatus！请手动排查错误并启动"
#			echo "主机:$HOST_IP TK环境$APPNAME应用启动失败 " | mail -s "脚本启动$APPNAME失败，请手动启动" shine@networkws.com
		fi
    else
	info_echo "$APPNAME应用正在稳定运行当中"
    fi	
}

#应用二

function admin(){
     PROT=8081
     HOST_IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
     APPNAME=admin
     APPDIR=/root/admin
     Checkproess=`ps -ef|grep $APPNAME|grep -v grep|wc -l`
     CheckStatus=`curl -I -m 10 -o /dev/null -s -w %{http_code}"\n"  $HOST_IP:$PROT/$APPNAME`
    if [ $Checkproess == 0 ]
    then
	warn_echo "不好！$APPNAME应用挂掉了，不过不用担心我会帮你启动起来 "
	source /etc/profile
	/bin/sh 		$APPDIR/bin/startup.sh  >> /dev/null
	info_echo "=========================正在启动${APPNAME}应用=====================" 	
	sleep 10
	info_echo "正在检测进程启动状态"
		if [ "$CheckStatus" == "000" ]
		then
			warn_echo "$APPNAME应用还未启动完成 HTTP状态码为：$CheckStatus！请等待.........."
			while true
			do
			CheckStatus=`curl -I -m 10 -o /dev/null -s -w %{http_code}"\n"  $HOST_IP:$PROT/$APPNAME`  #重新获取$CheckStatus的值，不然会造成死循环
				case $CheckStatus in 
					000) info_echo "正在启动中"
					;;
					*) info_echo "启动完成"
					break
					;;
				esac
			done
		
				
		elif [ $CheckStatus -lt 400 ]
		then
			info_echo "$APPNAME应用启动状态正常"

		else
			warn_echo "$APPNAME应用进程启动失败 HTTP状态码为：$CheckStatus！请手动排查错误并启动"
#			echo "主机:$HOST_IP TK环境$APPNAME应用启动失败 " | mail -s "脚本启动$APPNAME失败，请手动启动" shine@networkws.com
		fi
    else
	info_echo "$APPNAME应用正在稳定运行当中"
    fi	
}
sobet
admin
