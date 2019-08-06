
# Warning: Using a password on the command line interface can be insecure 해결 방법

sudo mysql_config_editor set --login-path=mylogin --host=localhost --user=root --port=3306 --password <br>
sudo mysql_config_editor print --login-path=mylogin <br>
생성 path ( ~/.mylogin.cnf ) <br>
sudo chown onycom:onycom ./.mylogin.cnf <br>
예)<br>
sudo scp -P 30401 onycom@52.231.156.156:/home/onycom/.mylogin.cnf ./<br>