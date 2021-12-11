awk '/v1.2.6/{flag=1; next } /^# v/{flag=0} flag' CHANGELOG.md 
