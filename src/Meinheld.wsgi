import meinheld
from app import application

meinheld.listen(("0.0.0.0", 9808))
meinheld.run(application)
