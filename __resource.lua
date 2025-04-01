fx_version 'cerulean'
game 'gta5'

name 'secureDataSystem'
author 'D4NTE98'
version '1.0.0'
description 'Zaawansowany system danych z wbudowanym szyfrowaniem i cache\'owaniem'

client_scripts {
    'c_data.lua'
}

server_scripts {
    's_data.lua'
}

exports {
    'getData',
    'setData',
    'transferData'
}

server_exports {
    'generateNewEncryptionKey',
    'flushPlayerCache'
}

data_file 'DLC_ITYP_REQUEST' 'stream/security/encryption.ytyp'

provide 'elementdata'
