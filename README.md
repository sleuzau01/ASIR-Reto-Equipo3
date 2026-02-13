# 🏟️ Estadio Racing - Sistema Distribuido de Gestión de Bares

Este proyecto implementa una infraestructura de base de datos relacional y distribuida para la gestión integral de los 16 bares de un estadio de fútbol. La solución está desplegada en la nube utilizando **AWS (Amazon Web Services)** para garantizar alta disponibilidad y rendimiento en entornos de alta concurrencia.

## 🚀 Características Técnicas (ACID)

El sistema se basa en el motor **InnoDB**, garantizando la robustez de los datos mediante las propiedades:

* **Atomicity (Atomicidad):** Las ventas se registran bajo el principio de "todo o nada", evitando tickets incompletos.
* **Consistency (Consistencia):** Reglas de integridad que aseguran que el stock y las relaciones entre tablas siempre sean válidos.
* **Isolation (Aislamiento):** Gestión de transacciones simultáneas para evitar conflictos cuando varios bares venden el mismo producto a la vez.
* **Durability (Durabilidad):** Persistencia de datos asegurada mediante logs transaccionales, incluso ante fallos críticos del sistema.

## 📊 Arquitectura de Datos

La base de datos `estadio_racing_bares.sql` está estructurada para optimizar la trazabilidad y el rendimiento:

### Bloques Principales
* **Gestión de Entidades:** Tablas `bares`, `usuarios` y `productos`.
* **Motor Transaccional:** Tabla `ventas` (cabecera) y `ventas_detalle` (líneas de producto).
* **Control de Inventario:** Tabla `stock_bares` vinculada mediante triggers.



## 🛠️ Automatización y Optimización

* **Triggers de Stock:** Actualización automática y en tiempo real de las existencias por cada bar tras insertar una nueva venta.
* **Integridad Referencial:** Uso estricto de **Foreign Keys** para impedir datos huérfanos y errores de coherencia lógica.
* **Infraestructura AWS RDS:** Despliegue en instancia gestionada con configuración **Multi-AZ** para alta disponibilidad y backups **PITR** (Point-in-Time Recovery).

## 💻 Stack Tecnológico

* **Base de Datos:** MySQL / MariaDB (Motor InnoDB).
* **Cloud:** AWS RDS (Relational Database Service).
* **Frontend:** Integración con WordPress para la interfaz de venta.
* **Gestión:** MySQL Workbench.

---
*Proyecto desarrollado para el TFG de ASIR2 - ASIR360 - AGL*
