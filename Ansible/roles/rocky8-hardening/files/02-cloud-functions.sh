getMetadata() {
  local path=$1

  local token=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300"`
  curl --fail -s -H "X-aws-ec2-metadata-token: ${token}" -v "http://169.254.169.254/latest/meta-data/${path}" 2>/dev/null
}