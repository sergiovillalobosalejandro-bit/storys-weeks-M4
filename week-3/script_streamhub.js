/**
 * SCRIPT PARA GESTIÓN DE STREAMHUB
 * Incluye: CRUD, Índices y Agregaciones
 */

// ---------------------------------------------------------
// TASK 2: INSERCIÓN DE DATOS
// ---------------------------------------------------------
db.content.insertMany([
  { "title": "Inception", "type": "movie", "genres": ["Sci-Fi", "Action"], "duration": 148, "release_year": 2010, "rating_avg": 4.8 },
  { "title": "Stranger Things", "type": "series", "genres": ["Horror", "Drama"], "seasons": 4, "release_year": 2016, "rating_avg": 4.7 },
  { "title": "The Godfather", "type": "movie", "genres": ["Crime", "Drama"], "duration": 175, "release_year": 1972, "rating_avg": 4.9 },
  { "title": "Toy Story", "type": "movie", "genres": ["Animation", "Kids"], "duration": 81, "release_year": 1995, "rating_avg": 4.5 },
  { "title": "Interstellar", "type": "movie", "genres": ["Sci-Fi", "Drama"], "duration": 169, "release_year": 2014, "rating_avg": 4.6 }
]);

db.users.insertMany([
  { "name": "Carlos Ruiz", "age": 28, "subscription": "Premium", "watch_history": ["Inception", "Stranger Things"], "email": "carlos@mail.com" },
  { "name": "Ana Lopez", "age": 17, "subscription": "Basic", "watch_history": ["Toy Story"], "email": "ana@mail.com" },
  { "name": "Marta Diaz", "age": 35, "subscription": "Premium", "watch_history": ["The Godfather", "Interstellar", "Inception"], "email": "marta@mail.com" }
]);

// ---------------------------------------------------------
// TASK 3: CONSULTAS (FIND) CON OPERADORES
// ---------------------------------------------------------

// 1. Películas con duración > 120 min Y género Sci-Fi ($and, $gt, $in)
db.content.find({
  $and: [
    { "duration": { $gt: 120 } },
    { "genres": { $in: ["Sci-Fi"] } }
  ]
});

// 2. Usuarios menores de 20 años O con suscripción Basic ($or, $lt, $eq)
db.users.find({
  $or: [
    { "age": { $lt: 20 } },
    { "subscription": { $eq: "Basic" } }
  ]
});

// 3. Contenido cuyo título contenga "The" (Regex case-insensitive)
db.content.find({ "title": { $regex: "the", $options: "i" } });

// ---------------------------------------------------------
// TASK 4: ACTUALIZACIONES Y ELIMINACIONES
// ---------------------------------------------------------

// Actualizar el rating promedio de "Inception"
db.content.updateOne(
  { "title": "Inception" },
  { $set: { "rating_avg": 4.9 } }
);

// Agregar "Classic" a todos los contenidos de antes del año 2000
db.content.updateMany(
  { "release_year": { $lt: 2000 } },
  { $addToSet: { "genres": "Classic" } }
);

// Eliminar usuarios con historial vacío (Simulación)
db.users.deleteMany({ "watch_history": { $size: 0 } });

// ---------------------------------------------------------
// TASK 5: ÍNDICES (PERFORMANCE)
// ---------------------------------------------------------

// Índice simple para búsquedas rápidas por título
db.content.createIndex({ "title": 1 });

// Índice multillave para filtrar por géneros eficientemente
db.content.createIndex({ "genres": 1 });

// Verificación de índices
db.content.getIndexes();

/* JUSTIFICACIÓN: 
  El índice en 'title' es vital para la barra de búsqueda. 
  El índice en 'genres' es necesario porque es el filtro más usado en la UI
  y al ser un array, un índice multillave evita escaneos de colección (COLLSCAN).
*/

// ---------------------------------------------------------
// AGREGACIONES (REPORTES Y MÉTRICAS)
// ---------------------------------------------------------

// MÉTRICA 1: Promedio de duración por género (Uso de $unwind, $group, $sort)
db.content.aggregate([
  { $unwind: "$genres" },
  { $group: {
      "_id": "$genres",
      "promedio_duracion": { $avg: "$duration" },
      "total_titulos": { $sum: 1 }
  }},
  { $sort: { "promedio_duracion": -1 } }
]);

// MÉTRICA 2: Usuarios con más de 1 contenido visto ($project, $match)
db.users.aggregate([
  { $project: {
      "name": 1,
      "cantidad_visto": { $size: "$watch_history" }
  }},
  { $match: { "cantidad_visto": { $gt: 1 } } },
  { $sort: { "cantidad_visto": -1 } }
]);