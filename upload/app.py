import falcon
import logging
import redis

from .upload import UploadResource
from .helper_methods import HelperMethods
from .healthz import HealthzResource



# *********************************************************
# *********************************************************
# ******* Upload API only /upload POST mapped *************
# *********************************************************
# *********************************************************


# connection pool to redis
pool = redis.ConnectionPool(host='redis', port=6379, db=0)

# accept not standard minetype for jpg
mimetypes = {
    'image/jpg': '.jpg',
    'image/jpeg': '.jpeg',
    'image/png': '.png',
    'image/gif': '.gif',
    'image/svg+xml': '.svg'
}

helper_methods=HelperMethods(pool=pool, storage_path='/images', mimetypes=mimetypes)

images = UploadResource(helper_methods=helper_methods)
logging.info('Local storage path /images being consumed')

# Start Falcon
app = application = falcon.API()

app.add_route('/upload', images)
logging.info('listening on POST /upload')

app.add_route('/healthz', HealthzResource())
logging.info('listening on GET /healthz')
