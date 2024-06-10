from utilidades import MeliScrapper, desanidar_key
import logging
import csv
from datetime import date



# Creación de una instancia de MyClass
meli_data = MeliScrapper()


# Muestrear items por cada categoría. La cantidad de items y las categorías dependen de los parámetros
# 'limit_api' y 'categorias' especificados en el archivo parametros.yml, respectivamente.
lista_muestreo = []
for categoria in meli_data.categorias:
    url = f"https://api.mercadolibre.com/sites/MLA/search?q={categoria}&limit={meli_data.limit_api}#json"
    respuesta = meli_data.api_get(url)
    respuesta_refinada = respuesta['results']
    if respuesta not in lista_muestreo:
        lista_muestreo.extend(respuesta_refinada)


# Si se obtuvo una respuesta exitosa de la API, crear una lista con todos los IDs de los items extraídos
if lista_muestreo:
    ids_list = []
    for result in range(len(lista_muestreo)):
        ids_list.append(lista_muestreo[result]['id'])
    logging.info(f"Extrayendo los ID de los items...")
else:
    logging.warning("No fue posible extraer datos de la API.")



# Crear un archivo llamado data.csv (si es que no existe) y cargar en él campos de interés de los distintos 
# productos seleccionados anteriormente.
with open('parte_2/data.csv', 'w', newline='') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=meli_data.campos_necesarios)
    writer.writeheader()

    if ids_list: 
        for id in ids_list:
            url = f"https://api.mercadolibre.com/items/{id}"
            respuesta = meli_data.api_get(url)
            respuesta['fecha_de_carga'] = date.today()
            desanidar_key(respuesta, 'sale_terms')
            desanidar_key(respuesta, 'attributes')
            print(respuesta)
            writer.writerow({key: respuesta[key] for key in meli_data.campos_necesarios})
    else:
        logging.warning("No fue posible extraer datos de la API.")
