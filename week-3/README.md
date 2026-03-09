# Proyecto de Gestión de Datos NoSQL - StreamHub 🎬

Este proyecto implementa una solución de base de datos no relacional utilizando **MongoDB** para gestionar una plataforma de streaming ficticia llamada **StreamHub**. El diseño aprovecha la flexibilidad de los documentos JSON para manejar contenido dinámico y optimizar el rendimiento mediante índices y agregaciones.

---

## 📂 Estructura de la Entrega
El archivo comprimido contiene:
1.  **`script_streamhub.js`**: Script con todos los comandos de MongoDB (Inserciones, Consultas, Updates, Deletes, Índices y Agregaciones).
2.  **`README.md`**: Documentación técnica y justificación del modelo (este archivo).

---

## 🛠 TASK 1: Análisis y Diseño de Documentos
Se han definido colecciones principales bajo un enfoque híbrido para equilibrar consistencia y velocidad:

* **Colección `content`**: Almacena películas y series.
    * **Diseño:** Se utilizan **Arrays** para los géneros (`genres`), permitiendo que un título pertenezca a múltiples categorías sin redundancia de datos.
* **Colección `users`**: Gestiona perfiles y preferencias.
    * **Diseño:** Se utiliza **Embebido (Embedding)** para el historial de visualización (`watch_history`). Esto permite recuperar el perfil completo del usuario en una sola lectura de disco.

---

## 🔍 TASK 3 y 4: CRUD y Operadores Avanzados
Se implementaron filtros lógicos para cubrir necesidades reales de la plataforma:
* **Filtrado de Catálogo:** Uso de `$and`, `$gt` e `$in` para buscar películas largas de géneros específicos.
* **Segmentación de Usuarios:** Uso de `$or` y `$lt` para identificar usuarios con planes básicos o menores de edad.
* **Búsqueda Semántica:** Uso de `$regex` para permitir que el buscador de la interfaz encuentre títulos de forma parcial e insensible a mayúsculas.

---

## ⚡ TASK 5: Índices y Performance
Para garantizar la escalabilidad de **StreamHub**, se aplicaron los siguientes índices:

1.  **Índice Único en `title`**: 
    * *Justificación:* Acelera la búsqueda directa de títulos. Evita que la base de datos tenga que revisar cada documento (`COLLSCAN`), pasando a una búsqueda binaria eficiente (`IXSCAN`).
2.  **Índice Multillave en `genres`**:
    * *Justificación:* Dado que `genres` es un array, este índice permite filtrar instantáneamente por categorías (ej. "Sci-Fi") sin penalizar el rendimiento cuando el catálogo crezca a miles de títulos.

---

## 📊 Agregaciones (Reportes y Métricas)
Se incluyeron dos pipelines de agregación para obtener inteligencia de negocio:

1.  **Métrica de Contenido:** Calcula la duración promedio por género. Utiliza `$unwind` para descomponer los arrays de géneros y `$group` para promediar las duraciones.
2.  **Métrica de Engagement:** Identifica a los usuarios más activos basándose en el tamaño (`$size`) de su array de historial, filtrando aquellos con más de un contenido visto mediante `$match`.

---

## 🚀 Instrucciones de Uso
1.  Asegúrese de tener una instancia de **MongoDB** activa.
2.  Ejecute el script `script_streamhub.js` en la **MongoDB Shell** (`mongosh`) o cárguelo a través de **MongoDB Compass**.
3.  Verifique la creación de la base de datos `streamhub_db` y sus respectivas colecciones.

---
**Analista a cargo:** [Tu Nombre/ID]  
**Institución:** Gestión Académica - 2026