#########################################################*
##############        9 Mapas (py)     ##################*
#########################################################*


# ## Introducción

# **(inputs) Este notebook utiliza de la datas de:**
#
# 1. ICPAG e indicadores con percentiles, por aglomerado (solo aglo EPH) (**data_icpag_500k.shp**),

# **(outputs) Mapa con los RC que se corresponden al 3%, 6% 15% y 25% país.


##############      Configuración    #####################

# from plantilla import plantilla
# from dotenv import dotenv_values

# env = dotenv_values("../.env")

# proyecto = "7. Ingreso Esperado"
# subproyecto = "7.4 Analisis y resultados"

# globales = plantilla(
#     proyecto=proyecto,
#     subproyecto=subproyecto,
#     path_proyectos=r"C:\Users\Administrador\Documents\MECON",
# )

# path_proyecto = globales[0]  # Ubicación de la carpeta del Proyecto
# path_datain = r"D:\MECON\7. Ingreso Esperado\data\data_in"  # Bases originales
# path_dataout = r"D:\MECON\7. Ingreso Esperado\data\data_out"
# path_scripts = globales[3]
# path_figures = globales[4]  # Output para las figuras/gráficos
# path_maps = globales[5]  # Output para los mapas (html o imagen)
# path_tables = globales[6]  # Output para las tablas (imagen o excel)
# path_programas = globales[7]

import pandas as pd
import geopandas as gpd
import numpy as np
import plotly.express as px

pd.set_option("display.max_columns", None)

zoom_center = {
    "argentina": (3.18, -39.249, -61.960),
    "amba": (9.34, -34.637, -58.434),
    "cordoba": (10.46, -31.406, -64.194),
    "rosario": (10.44, -32.955, -60.678),
    "mendoza": (11.36, -32.900, -68.829),
    "tucuman": (10.89, -26.819, -65.197),
    "la_plata": (10.49, -34.924, -57.941),
    "mar_del_plata": (10.53, -38.006, -57.523),
    "salta": (12.58, -24.794, -65.403),
    "san_juan": (10.74, -31.548, -68.491),
    "santa_fe": (11.72, -31.625, -60.699),
    "parana": (12.34, -31.742, -60.512),
}


def choropleth(
    data=None,
    variable=None,
    aglo="argentina",
    path_maps=None,
    label=None,
    nombre_archivo=None,
    out="html",  # html o image
    colorscale="Spectral_r",
    range_color=None,
):
    """A partir de un GeoDataFrame, grafica"""
    import plotly.express as px

    pd.options.mode.chained_assignment = None  # default='warn'
    px.set_mapbox_access_token(
        "pk.eyJ1IjoicXVlZW5vMTEiLCJhIjoiY2tlYm81djQ1MGFuNjJzcnM1anYxczE4ZiJ9.mmgMzjhvDMlfcQFrlqWqLg"
    )

    if label == None:
        label = variable
    if range_color is None:
        range_color = [data[variable].quantile(0.05), data[variable].quantile(0.95)]

    fig = px.choropleth_mapbox(
        data,
        geojson=data.geometry,
        locations=data.index,
        color=data[variable],
        labels={variable: label},
        zoom=zoom_center[aglo][0],
        center={"lat": zoom_center[aglo][1], "lon": zoom_center[aglo][2]},
        color_continuous_scale=colorscale,
        range_color=range_color,
        opacity=0.7,
        width=1200,
        height=800,
        hover_name=variable,
    )

    fig.update_layout(margin={"r": 0, "t": 0, "l": 0, "b": 0})
    fig.update_traces(marker_line_width=0)

    fig.update_layout(
        mapbox_style="mapbox://styles/queeno11/ckx8e3hhh1bgd14mtfqnvr9lc",
    )

    config = {
        "displaylogo": False,
        "toImageButtonOptions": {
            "filename": variable,
            "height": 500,
            "width": 700,
            "scale": 10,  # Multiply title/legend/axis/canvas sizes by this factor
        },
    }

    if out == "html":
        if nombre_archivo == None:
            fig.write_html(
                path_maps + "\\mapa_" + str(variable) + ".html", config=config
            )
        else:
            fig.write_html(
                path_maps + "\\" + str(nombre_archivo) + ".html", config=config
            )
    if out == "image":
        if nombre_archivo == None:
            fig.write_image(
                path_maps + "\\mapa_" + "_" + aglo + str(variable) + ".png",
                engine="kaleido",
            )
        else:
            fig.write_image(
                path_maps + "\\" + aglo + "_" + str(nombre_archivo) + ".png",
                engine="kaleido",
            )

    pd.options.mode.chained_assignment = "warn"  # default='warn'


if __name__ == "__main__":

    ## Abre datas de poligonos y [path_dataout + "\\data_icpag_500k.shp"]

    # Importo el shp
    gdf = gpd.read_file(path_dataout + "\\agregados_por_radio_censal.shp")

    choropleth(
        data=gdf,
        variable="n2_3_p",
        label="cobertura",
        aglo="argentina",
        out="html",
        nombre=f"Mapa_arg_cobertura",
    )

    for j in zoom_center.keys():
        choropleth(
            data=gdf,
            variable="n2_3_p",
            label="cobertura",
            aglo=j,
            out="image",
            nombre=f"Mapa_aglo_{j}_cobertura",
        )
        print("Se guardó el mapa del aglo " + str(j))

    # choropleth(
    #     data=gdf,
    #     variable="n2_3_p",
    #     label="cobertura",
    #     out="html",
    #     nombre="Mapa_pais_cobertura",
    # )
