import logging
import yaml
import requests
import json


class MeliScrapper():
    def __init__(self) -> None:
        # Configuración de logging
        logging.basicConfig(level=logging.DEBUG,
            format='%(asctime)s [%(levelname)s] %(message)s',
            handlers=[
                logging.FileHandler('parte_2/run_history.log', 'a'),
                logging.StreamHandler()
            ])

        # Declaración de variables definidas en el archivo parametros.yaml
        with open(r'parte_2/parametros.yml') as file:
            variables_dict = yaml.load(file, Loader=yaml.FullLoader)

        self.limit_api = variables_dict["limit_api"]
        self.categorias = variables_dict["categorias"]
        self.campos_necesarios = variables_dict["campos_necesarios"]


    def api_get(self, url: str) -> dict:
        """Realiza un get con una API y almacena la(s) respuesta(s) en un diccionario.
        
        Args:
            url: url de la API utilizada.

        Returns:
            api_response: diccionario que contiene los datos extraídos.
        """

        try:
            response = requests.get(url)
            response.raise_for_status() 
            response_dictionary = json.loads(response.text)
            logging.info(f"La request se ejecutó con éxito!")
            return response_dictionary
        # Catch de errores HTTP 
        except requests.exceptions.HTTPError as err:
            logging.error(f"La request falló con el status code {err.response.status_code}")
        # Catch de otro tipo de errores
        except Exception as e:  
            logging.error(f"Error inesperado:", e)
    

def snakify(texto: str) -> str:
    """Toma un texto y lo convierte según la convención snake_case
        
    Args:
        texto: texto a convertir.

    Returns:
        texto_snake_case: texto modificado de acuerdo a la convención snake_case.
    """
    translation_table = str.maketrans('áéíóú', 'aeiou')
    texto_sin_acentos = texto.translate(translation_table)
    texto_snake_case = texto_sin_acentos.replace(' ', '_').lower()
    return texto_snake_case


def desanidar_key(nombre_diccionario: dict, nombre_key: str) -> dict:
    """Toma una key de un diccionario que esté anidada y la desanida para obtener sus
     características.
        
    Args:
        nombre_diccionario: diccionario que tiene la key a desanidar.
        nombre_key: key a desanidar.

    Returns:
        diccionario original más las keys nuevas que surgieron luego del desanidado.
    """
    for i in range(len(nombre_diccionario[nombre_key])):
        clave = nombre_diccionario[nombre_key][i]['name']
        clave_snake_case = snakify(clave)
        nombre_diccionario[clave_snake_case] = nombre_diccionario[nombre_key][i]['value_name']
    return nombre_diccionario