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
      if [ $? -eq 0 ];then
	 info_echo "上一条命令执行正常"
      else
         err_echo "上一条命令执行异常,并退出"
      fi
}

function for_fun(){
        echo -e -n "\e[96m$1\e[0m"
        for k in $( seq 1 5 );do
                sleep 1s
                echo -e -n "\e[95m.\e[0m"
        done
        echo -e  "\e[92m[OK]\e[0m"
}

test -d /jarbackup || mkdir /jarbackup

##全局变量设置
function set_variables(){
	jarname=$2
	tomcat_dir=/usr/local/tomcat7.0_$1
	jar_dir=$tomcat_dir/webapps/$1/WEB-INF/lib
	backup_date=`date +%m%d_%H%M`
	backup_dir=/jarbackup
	countinital=0
}

function checkjar_file(){
	
	if [ ! -f "$jar_dir/$jarname" ];then
		err_echo "jar包不存在，请检查jar报名称是否正确"
	fi

	if [ ! -d "/release/jarfile" ];then
		err_echo "releas目录下没有jarfile目录，请上传后再操作"
	fi	
	if [ ! -f "/release/jarfile/readme.txt" ];then
		err_echo "readme.txt不存在"
	fi	
}

function backjar(){
	info_echo "开始备份jar包...."
	test -d $backup_dir/$1 || mkdir -p $backup_dir/$1 
	cp $jar_dir/$jarname  $backup_dir/$1/${jarname}_$backup_date
	if [  -f "$backup_dir/$1/${jarname}_$backup_date" ];then
		info_echo `ls -l $backup_dir/$1/${jarname}_$backup_date`
	else
		err_echo "备份文件不存在 请检查！"
	fi

}

function unzipjar(){
	cd $backup_dir/$1
	unzip -qo $backup_dir/$1/${jarname}_$backup_date -d /release/$jarname
}

function change_readme(){
	sed -i  "/^#/d"  /release/jarfile/readme.txt	    #删除以#号开头的行
	sed -i 's/\\/\//g' /release/jarfile/readme.txt      #\替换成linux下的/
	sed -i  "/^\r$/d"  /release/jarfile/readme.txt	    #删除空白行
	#sed -i  "/^$/d"  /release/jarfile/readme.txt	    #删除空白行
}

function read_LINE(){
	while read line || [[ -n $line ]]  #解决read line不读取文件最后一行的问题
	do
		#line=${line:0:$((${#line}-1))}
		new_file=`echo ${line} |awk -F '/' '{print $NF}'`
		path=${line%/*}
#		info_echo $path
		info_echo $line
#		path=`echo ${line} |awk -F ${new_file} '{print $1}'`
		if [ -d /release/$jarname/$path ];then
			newname=`echo $new_file|awk -F "\r" '{print $1}'`
			info_echo "更换新文件${newname}"
			cp /release/jarfile/$newname /release/$jarname/$path
			echo  -e "\033[31m文件:\033[0m\e[93m${newname}覆盖到\e[0m\033[35m--->>\033[34m/release/$jarname/${path}/${newname} \e[0m"
			ls -l /release/$jarname/$path/${newname}
		else
			newname=`echo $new_file|awk -F "\r" '{print $1}'`
			info_echo "${newname}路径不存在，即将创建"
			mkdir -p /release/$jarname/$path
			echo  -e "\033[34m新建路径:\033[0m\033[47;30m${path}\033[0m"
			cp /release/jarfile/$newname /release/$jarname/$path
			echo  -e "\033[31m文件:\033[0m\e[93m${newname}覆盖到\e[0m\033[35m--->>\033[34m /release/$jarname/${path}/${newname} \e[0m"
			ls -l /release/$jarname/$path/${newname}
		fi
		countinital=$[${countinital}+1]    #计数器
	done < /release/jarfile/readme.txt
}

function take_jar(){
	source /etc/profile.d/java.sh
	cd /release/$jarname
	jar -cf $jarname ./*
}
function hood_jar(){
        #cp /release/$jarname/$jarname $jar_dir
        cp /release/$jarname/$jarname /usr/local/tomcat7.0_${1}/webapps/${1}/WEB-INF/lib/
	info_echo `ls -l $jar_dir/$jarname`
	info_echo "风萧萧兮易水寒，壮士一去兮不复返。"

}
function Sup(){
	info_echo "是否取消重启应用：请输入【N/n】";read  -t 5 Nsup 
	if [ -n "${Nsup}" ];then
		echo -e "\033[34m用户取消重启\e[0m"
		info_echo "总共更新了${countinital}个文件"
		exit 
	fi
}
function restart_app(){

	procnumber=`ps -ef|grep java|grep ${1}|grep -v 'grep' |grep -v 'bash'|grep -v 'demo'|grep -v 'QY'|grep -v "${1}-admin\|se-${1}\|${1}-draw\|${1}-quartz\|${1}-report\|${1}task"|awk '{print $2}'|wc -l `
	if [ $procnumber == 1 ];then
		ps -ef|grep java|grep ${1}|grep -v 'grep' |grep -v 'bash'|grep -v 'demo'|grep -v 'QY'|grep -v "${1}-admin\|se-${1}\|${1}-draw\|${1}-quartz\|${1}-report\|${1}task"|awk '{print $2}'|xargs kill -9
		info_echo "${1}应用以被杀死"
		info_echo "开始启动${1}"
		source /etc/profile.d/java.sh
		/usr/local/tomcat7.0_${1}/bin/startup.sh > /dev/null
	else
		echo "检测到多个包含${1}字符串的进程 请手动重启"
		exit
	fi
}
function tailLog(){

	info_echo "监听启动日志：请输入【Y/y】"	;read -n1 -t 3 tailSup 
	if [ -z $tailSup  ];then
#		len=`echo ${tailSup}|wc -L`
#		echo $len
		info_echo "发布完成！共更新${countinital}个文件"
		exit
	else
		tail -f /usr/local/tomcat7.0_${1}/logs/catalina.out
	fi
}
function main() {
	set_variables $1 $2
	checkjar_file 
	backjar       $1
	unzipjar      $1
	change_readme
	read_LINE
	take_jar
	hood_jar $1
	Sup
	restart_app $1
	tailLog  $1
}

main $1 $2
