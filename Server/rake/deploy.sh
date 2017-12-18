# Installing system libs, tools and gems

echo "Attention: make, automake, gcc, gcc-c++, kernel-devel, ruby-devel, zeromq, zeromq-devel libs and zmqjsonrpc gem will be installed."
echo "Also whmconnect user and /home/whmconnect dir will be created."
read -p "Are you sure?[Y/n]" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Y]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi
echo -n "You have 5 sec before some dangerous stuff will started..."
echo -n '5..' && sleep 1 && echo -n '4..' && sleep 1 && echo -n '3..' && sleep 1 && echo -n '2..' && sleep 1 && echo -n '1..' && sleep 1 && echo 'Go'

sed -i 's/enabled\=1/enabled\=0/g'  /etc/yum.repos.d/vonecloud.repo
yum install -y make automake gcc gcc-c++ kernel-devel ruby-devel zeromq zeromq-devel
gem install zmqjsonrpc
sed -i 's/enabled\=0/enabled\=1/g'  /etc/yum.repos.d/vonecloud.repo

# Creating gem-test file

echo "require 'zmqjsonrpc'

class TestHand
    def test_func(msg)
        return 'pong' if msg == 'ping'
    end
end

server = ZmqJsonRpc::Server.new(TestHand.new, 'tcp://*:666666')
Thread.new do
    server.server_loop
end

client = ZmqJsonRpc::Client.new('tcp://localhost:666666')
if client.test_func('ping') == 'pong' then
    puts 'OK'
else
    puts 'FAIL'
end" > gemtest.rb

# Testing how the lib was installed

UNIT=`/usr/bin/ruby gemtest.rb`

if [ "$UNIT" == 'OK' ]; then
    echo '++++++++++++++++++++++++++++++++++++++++++++++'
    echo '+    Deploy process finished successfuly!    +'
    echo '++++++++++++++++++++++++++++++++++++++++++++++'
else
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+ Something went wrong, it's maybe caused by 'zmqjsonrpc' gem installing... +"
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
fi

git clone --branch testing https://slnt_opp:Jago322==@bitbucket.org/slnt_opp/opennebula.git
mv opennebula/* ./
mv Server server
rm -rf opennebula
bundle install --gemfile server/Gemfile

read -p "Do you want to add aliases for log(onlog) and snapshot-log(onsnap)?" -n 1 -r
if [[ $REPLY =~ ^[Y]$ ]]
then
    echo "alias onlog='cat /scripts/server/log/activities.log'" >> ~/.bashrc
    echo "alias onsnap='cat /scripts/server/log/snapshot.log'" >> ~/.bashrc
fi

read -p "Do you want to add onwhm to '/usr/bin'?" -n 1 -r
if [[ $REPLY =~ ^[Y]$ ]]
then
    cp server/rake/onwhm /usr/bin
fi

rm -f ./gemtest.rb
rm -f ./deploy.sh