from palmerpenguins import penguins
from pandas import get_dummies
from sklearn.linear_model import LinearRegression
from pins import board_folder
from vetiver import VetiverModel
from vetiver import VetiverAPI

import logging

# Configure the log object
logging.basicConfig(
    format='%(asctime)s - %(message)s',
    level=logging.INFO
)

# Log app start
logging.info("API Started")

# This is how you would reload the model from disk...
b = board_folder('data/model', allow_pickle_read=True)
v = VetiverModel.from_pin(b, 'penguin_model')

# ... however VertiverAPI also uses the model inputs to define params from the prototype
df = penguins.load_penguins().dropna()
df.head(3)
X = get_dummies(df[['bill_length_mm', 'species', 'sex']], drop_first=True)
y = df['body_mass_g']

model = LinearRegression().fit(X, y)

v = VetiverModel(model, model_name="penguin_model", prototype_data=X)

app = VetiverAPI(v, check_prototype=True)
app.run(port=8000)
