CONTAINER_PORT=8062
# passby options example: 
# /mydata/mysh/common.deploy.sh -c 8061 -p 8102 -i daishu-platform/hospital-manage:v0.1.11 -v '-v /mydata/nfs_share/go-app/hospital-manage/config:/go/app/config -v /mydata/logs/hospitaladm:/go/app/logs -v /mydata/nfs_share/go-app/hospital-manage/view:/go/app/view' > /mydata/mysh/log-hospital-manage.log
while getopts "i:v:p:c:" opt; do
  case $opt in
    i)
      IMAGE_NAME=$OPTARG
      ;;
    v)
      CONTAINER_VOLUME=$OPTARG
      ;;
    p)
      PORT=$OPTARG
      ;;
    c)
      CONTAINER_PORT=$OPTARG
      ;;
    *)
      echo "invalid options: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

URL=http://127.0.0.1:7777.com   //harbor url,better ues interal ip address 
IMAGE_URL=$URL/$IMAGE_NAME
CAINTAINER_NAME=$(echo $IMAGE_NAME | awk -F ':' '{print $1}')
CAINTAINER_NAME=${CAINTAINER_NAME/\//_}
echo "Port :$PORT"
echo $CAINTAINER_NAME
IP_LIST=(10.0.6.9 10.0.1.109)  //internal ip list here
for ip in ${IP_LIST[@]}; do
  ssh root@$ip << EOF
    docker login $URL -u harborusername -p harborpasswd // login harbor
    docker pull $IMAGE_URL
    docker stop $CAINTAINER_NAME&&docker rm $CAINTAINER_NAME
    docker run -d --name=$CAINTAINER_NAME -p $PORT:$CONTAINER_PORT ${CONTAINER_VOLUME} $IMAGE_URL restart
EOF
done