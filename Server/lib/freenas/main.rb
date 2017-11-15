#############################################
#               TRY RuPy!!!                 #
#############################################

class FreeNAS
    def initialize
        @freenas = CONF['FreeNAS']
    end
    def exec(cmd)
        Net::SSH.start(@freenas['hostname'], @freenas['username'], password: @freenas['password']) do | host |
            return host.exec!(cmd)
        end
    end
    def create_ds(params)
        name, quota, acip = params['name'], params['quota'], params['acip']
        # name - имя датасета, quota - квота на дисковое пространство в гигабайтах, acip - IP, которому можно будет примонтировать хранилище
        return exec("sh /scripts/createShare.sh #{name} #{quota} #{acip}")
    end
    def resize_ds(params)
        name, quota, acip, id = params['name'], params['quota'], params['acip'], params['id']
        return exec("sh /scripts/resizeShare.sh #{name} #{quota} #{acip} #{id}")
    end
    def destroy_ds(params)
        name, id = params['name'], params['id']
        return exec("sh /scripts/destroyShare.sh #{name} #{id}")
    end
    def list_ds(params)
        exec("curl --user #{@freenas['username']}:#{@freenas['password']} -X GET http://freenas.support.by/api/v1.0/storage/volume/NAS10-2/ -o /tmp/ds_list#{stamp = Time.now.to_i}.txt")
        out = exec("cat /tmp/ds_list#{stamp}.txt")
        exec("rm -f /tmp/ds_list#{stamp}.txt")
        return out
    end
end

class WHMHandler
    def FreeNASController(request)
        return FreeNAS.new.send(request['method'], request['params'])
    end
end