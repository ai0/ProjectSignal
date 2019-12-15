DB_CONFIG = {
    'connections': {
        'default': {
            'engine': 'tortoise.backends.asyncpg',
            'credentials': {
                'host': 'db',
                'port': '5432',
                'user': 'beacon',
                'password': '1llus0ryBe4c0n',
                'database': 'illusorybeacon',
            }
        },
    },
    'apps': {
        'models': {
            'models': ['models'],
        }
    }
}